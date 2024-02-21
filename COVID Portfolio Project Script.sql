SELECT *
from CovidDeaths cd 
where continent is not null
ORDER BY 1,2

SELECT location, date_column, total_cases, new_cases, total_deaths, population
from CovidDeaths cd
where continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
Select location, date_column, total_cases, total_deaths , (CAST(total_deaths AS FLOAT)/total_cases)*100 as DeathPercentage
from CovidDeaths cd 
--WHERE LOCATION LIKE '%states%'
where continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date_column, population  , total_cases,  (CAST(total_cases AS FLOAT)/population)*100 as CasePercentage
from CovidDeaths cd 
--WHERE LOCATION LIKE '%states%' AND total_cases IS NOT NULL
where continent is not null
order by 1,2


-- Looking at countries highest infection rates compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount , MAX((CAST(total_cases as float)/population))*100 as InfectionPercentage
from CovidDeaths cd 
group by location, population
where continent is not null
order by InfectionPercentage DESC 

-- BREAKING THINGS DOWN BY CONTINENT
 -- CRITICAL TABLE START*******************
-- Showing continents with the highest death count per population
SELECT location  , max(CAST(total_deaths AS int)) AS totalDeathCount
FROM CovidDeaths cd
WHERE continent IS NOT NULL AND location IN ('World', 'Europe', 'Asia', 'North America', 'South America', 'Africa', 'Oceania', 'European Union')
GROUP BY location  
ORDER BY 2 DESC 
-- CRITICAL TABLE END*******************

SELECT continent  , max(CAST(total_deaths AS int)) AS totalDeathCount
FROM CovidDeaths cd
WHERE continent IS NOT NULL 
GROUP BY continent  
ORDER BY 2 DESC 


-- GLOBAL NUMBERS
Select date_column, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, 
CASE
	WHEN SUM(new_cases) <> 0 THEN CAST(SUM(new_deaths) AS FLOAT)/SUM(new_cases)*100
	ELSE CAST(SUM(new_deaths) AS FLOAT)/1*100
END AS  DeathPercentage
from CovidDeaths cd 
--WHERE location LIKE '%states%'
where continent is not null
group by date_column 
order by 1,2


-- >>>>>>>>>>>>>>>>.

-- USE CTE
WITH PopvsVac (continent, location, date_column, population, new_vaccinations, RollingPeopleVaccinated)
as
(
-- LOOKING AT TOTAL POPULATION VS VACCINATIONS
SELECT CD.continent , CD.location , CD.date_column , CD.population , CV.new_vaccinations , SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date_column) AS RollingPeopleVaccinated --(RollingPeopleVaccinated)/(cv.population)*100 AS PercentagePeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
	ON CD.location = CV.location AND CD.date_column = CV.date_column 
WHERE CD.continent <> ''
--ORDER BY 2,3	
)
Select *, (CAST(RollingPeopleVaccinated AS FLOAT)/population)*100
from PopvsVac
order by 2,3



-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date_column date,
	population bigint,
	new_vaccinations int,
	RollingPeopleVaccinated bigint
)

INSERT INTO #PercentPopulationVaccinated
SELECT CD.continent , CD.location , CD.date_column , CD.population , CV.new_vaccinations , SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date_column) AS RollingPeopleVaccinated --(RollingPeopleVaccinated)/(cv.population)*100 AS PercentagePeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
	ON CD.location = CV.location AND CD.date_column = CV.date_column 
WHERE CD.continent <> ''
--ORDER BY 2,3	

Select *, (CAST(RollingPeopleVaccinated AS FLOAT)/population)*100 AS PercentPopVac
from #PercentPopulationVaccinated
order by 2,3


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated
AS
SELECT CD.continent , CD.location , CD.date_column , CD.population , CV.new_vaccinations , SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date_column) AS RollingPeopleVaccinated --(RollingPeopleVaccinated)/(cv.population)*100 AS PercentagePeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
	ON CD.location = CV.location AND CD.date_column = CV.date_column 
WHERE CD.continent <> ''
 
SELECT *
FROM PercentPopulationVaccinated ppv 
