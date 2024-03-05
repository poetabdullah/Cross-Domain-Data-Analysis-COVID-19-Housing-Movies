-- Housing Data Queries:


-- Selecting the data:

SELECT * FROM dbo.HousingData;

-- We want to remove the timeslot from the SaleDate column

UPDATE HousingData SET SaleDate = CONVERT(DATE, SaleDate);
-- For some random reason, it does not work, so we are just gonna add another column into the table

ALTER TABLE HousingData ADD SaleConvertedDate DATE;

UPDATE HousingData SET SaleConvertedDate = CONVERT(DATE, SaleDate);

SELECT SaleConvertedDate FROM HousingData; -- Conversion Successful

-- Some of the columns of PropertyAddress don't have any data in them. So, we are going to populate them.

-- Upon looking at the data, we see that ParcelID is repeated many times. So, we are going to see if those
-- parcel ids have null PropertyAddress, we are going to populate that values.

-- This displays those columns having NULL PropertyAddress:
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..HousingData a JOIN PortfolioProject..HousingData b ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ] WHERE a.PropertyAddress IS NULL;

UPDATE a SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..HousingData a JOIN PortfolioProject..HousingData b ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ] WHERE a.PropertyAddress IS NULL; -- Query Successful

-- We notice that 1NF thing is defied in the address columns, that the city, state, etc are in same column.

SELECT PropertyAddress, OwnerAddress FROM PortfolioProject..HousingData;

-- Getting only the property address:

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
FROM PortfolioProject..HousingData;

-- What we are doing above is that we are only getting the property address till the comma value which
-- in our case is the Property's address and then ommitting the last index which is comma.

-- Now, we wanna see the city, so we are going at the area where the comma ends. Then we also don't
-- wanna see the comma so we add a place index (+1):

SELECT SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..HousingData;

-- Now, adding cloumns in the table as per 1NF & updating the data:

-- Address:
ALTER TABLE HousingData ADD PropertySplitAddress NVARCHAR(255);

UPDATE HousingData SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, 
CHARINDEX(',', PropertyAddress) - 1) FROM PortfolioProject..HousingData;


-- City:
ALTER TABLE HousingData ADD PropertySplitCity NVARCHAR(255);

UPDATE HousingData SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, 
LEN(PropertyAddress)) FROM PortfolioProject..HousingData;


SELECT * FROM HousingData; -- Both queries successful


-- Now the Owner's address:

-- We will be using parsename this time. Now parsename only replaces the '.' and not commas.

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM PortfolioProject..HousingData;



-- Owner's Address:
ALTER TABLE HousingData ADD OwnerSplitAddress NVARCHAR(255);
UPDATE HousingData SET OwnerSplitAddress = 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) FROM PortfolioProject..HousingData;


-- City:
ALTER TABLE HousingData ADD OwnerSplitCity NVARCHAR(255);

UPDATE HousingData SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 
FROM PortfolioProject..HousingData;

-- State:
ALTER TABLE HousingData ADD OwnerSplitState NVARCHAR(255);

UPDATE HousingData SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..HousingData;

SELECT * FROM HousingData; -- All three queries successful


-- Changing Y to Yes and N to No in SoldAsVacant:

SELECT SoldAsVacant, 
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes' 
        WHEN SoldAsVacant = 'N' THEN 'No' 
        ELSE SoldAsVacant 
    END 
FROM PortfolioProject..HousingData;

UPDATE PortfolioProject..HousingData SET SoldAsVacant = CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes' 
        WHEN SoldAsVacant = 'N' THEN 'No' 
        ELSE SoldAsVacant 
    END;

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) FROM PortfolioProject..HousingData GROUP BY
SoldAsVacant ORDER BY 2; -- Query Successful


-- Removing Duplicates:

WITH RowNumCTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
            ORDER BY UniqueID
        ) AS row_num
    FROM 
        PortfolioProject..HousingData
)

-- So where the row_num is more than 1, aka a duplicate data, we are gonna remove it.

--DELETE FROM RowNumCTE WHERE row_num > 1;
SELECT * FROM RowNumCTE WHERE row_num > 1; -- Query Successful, duplicates have been removed.


-- Removing the unused data:

-- So we already have divided the Owner & Property Address into multiple columns as per 1NF, so, we don't
-- need original columns now. We also have a ConvertedSaleDate, so will drop the original one.

ALTER TABLE PortfolioProject..HousingData DROP COLUMN OwnerAddress, PropertyAddress;
ALTER TABLE PortfolioProject..HousingData DROP COLUMN SaleDate;

SELECT * FROM PortfolioProject..HousingData; -- Query Successful





