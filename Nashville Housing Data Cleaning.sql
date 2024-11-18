-- Basic cleaning of housing data in the Nashville, TN area

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;


-- Standardizing the date from original format to year, month, day format


SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

SELECT SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing;


-- Populating the Property Address Data


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--Where PropertyAdress IS NULL
ORDER BY ParcelID;

SELECT table_a.ParcelID, table_a.PropertyAddress, table_b.ParcelID, table_b.PropertyAddress, ISNULL(table_a.PropertyAddress, table_b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS table_a
JOIN PortfolioProject.dbo.NashvilleHousing AS table_b
	ON table_a.ParcelID = table_b.ParcelID
	AND table_a.UniqueID != table_b.UniqueID
WHERE table_a.PropertyAddress IS NULL;

UPDATE table_a
SET PropertyAddress = ISNULL(table_a.PropertyAddress, table_b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS table_a
JOIN PortfolioProject.dbo.NashvilleHousing AS table_b
	ON table_a.ParcelID = table_b.ParcelID
	AND table_a.UniqueID != table_b.UniqueID
WHERE table_a.PropertyAddress IS NULL;


-- Breaking the address into individual columns for the street address, city, and state

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing;

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) AS Address,
	SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress));

Select OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1);


-- Updating the SoldAsVacant column from 1 and 0 to Yes and No respectively


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant;

Select SoldAsVacant,
CASE WHEN SoldAsVacant = '0' THEN 'No'
	 WHEN SoldAsVacant = '1' THEN 'Yes'
	 ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = '0' THEN 'No'
	 WHEN SoldAsVacant = '1' THEN 'Yes'
	 ELSE SoldAsVacant
END;


-- Removing any duplicates from the data

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) AS Row_Num
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE Row_Num > 1;


-- Deleting unusable or unnecesary columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict;

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;
