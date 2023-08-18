
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate 
from NashvilleHousing nh

-- Converting format of date from 'Month DD, YYYY' to YYYY-MM-DD
UPDATE NashvilleHousing 
SET SaleDate = CONVERT(DATE, REPLACE(SUBSTRING(SaleDate, CHARINDEX(' ', SaleDate) + 1, LEN(SaleDate)), ',', '') + ' ' + LEFT(SaleDate, CHARINDEX(' ', SaleDate) - 1), 107);

select SaleDate 
from NashvilleHousing nh



--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from NashvilleHousing nh 
where PropertyAddress = ''

select nh.ParcelID , nh.PropertyAddress , nh2.ParcelID , nh2.PropertyAddress ,
CASE 
	WHEN nh.PropertyAddress <> '' THEN nh.PropertyAddress
	ELSE nh2.PropertyAddress 
END as CombinedPropertyAddress
from NashvilleHousing nh
join NashvilleHousing nh2 
	on nh.ParcelID = nh2.ParcelID AND nh.UniqueID <> nh2.UniqueID 
where nh.PropertyAddress = ''


UPDATE nh
SET  PropertyAddress = CASE 
	WHEN nh.PropertyAddress <> '' THEN nh.PropertyAddress
	ELSE nh2.PropertyAddress 
END
from NashvilleHousing nh
join NashvilleHousing nh2 
	on nh.ParcelID = nh2.ParcelID AND nh.UniqueID <> nh2.UniqueID
where nh.PropertyAddress = ''



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT *
FROM NashvilleHousing nh 

-- Finding the position of the commas in PropertyAddress
SELECT PropertyAddress ,
       CHARINDEX(',', PropertyAddress) AS FirstComma,
       CHARINDEX(',', PropertyAddress, CHARINDEX(',', PropertyAddress) + 1) AS SecondComma
FROM NashvilleHousing nh

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from NashvilleHousing nh 

-- Appending 2 more columns to the table
ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress nvarchar(255)
	
UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing 
ADD PropertySplitCity nvarchar(255)

	
UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- DELETING PropertyAddress Column from table 


-- Parsing OwnerAddress
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3) as address,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) as city
, PARSENAME(REPLACE(OwnerAddress,',','.'), 1) as state
FROM NashvilleHousing nh 

-- Adding those columns and values to table
ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress nvarchar(255)
	
UPDATE NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity nvarchar(255)
	
UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


ALTER TABLE NashvilleHousing 
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

-- Trying to replicate the above with SUBSTRING instead of PARSENAME
-- Finding the position of the commas in OwnerAddress
SELECT OwnerAddress,
       CHARINDEX(',', OwnerAddress) AS FirstComma,
       CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) AS SecondComma
FROM NashvilleHousing nh
WHERE OwnerAddress <> ''


SELECT
    SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1) AS Address,
    LTRIM(SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 1)) AS City,
    LTRIM(SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) + 1, LEN(OwnerAddress) - CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1))) AS State
FROM NashvilleHousing
WHERE OwnerAddress <> ''


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
select DISTINCT(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing nh 
group by SoldAsVacant 
order by 2

select SoldAsVacant ,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
end
from NashvilleHousing nh 

-- MAKE UPDATE TO TABLE
UPDATE NashvilleHousing 
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM NashvilleHousing nh 
--ORDER BY ParcelID 
)
DELETE
FROM RowNumCTE 
WHERE row_num > 1
--ORDER BY PropertyAddress 



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

-- Drop the default constraints
ALTER TABLE NashvilleHousing
DROP CONSTRAINT DF__Nashville__Owner__797309D9,
DROP CONSTRAINT DF__Nashville__TaxDi__7B5B524B,
DROP CONSTRAINT DF__Nashville__Prope__73BA3083,
DROP CONSTRAINT DF__Nashville__SaleD__74AE54BC

-- Drop the columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

-- Removing $ symbol from saleprice column
select UniqueID , SalePrice , REPLACE(SalePrice, '$', '') 
from NashvilleHousing
WHERE SalePrice LIKE '%$%'

UPDATE NashvilleHousing 
SET SalePrice = REPLACE(SalePrice, '$', '')
WHERE SalePrice LIKE '%$%'

select *
from NashvilleHousing

