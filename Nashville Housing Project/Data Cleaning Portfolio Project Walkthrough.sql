/*

Cleaning Data in SQL Queries

*/

-- Standardize Date Format

-- Method 1
SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

-- Method 2
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

-- ParcelID corresponds with only one address
-- If ParcelID has an address and another ParcelID does not have an address, populate the null with the address
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- demonstrate what column ISNULL will produce
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

-- update the table with the correct Property Address using ISNULL
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

-- Use SUBSTRING Method to utilize delimeter
-- Use -1 and +1 to account for the comma
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
    , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- query to verify added columns (shown at the end)
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------
-- Breaking out Owner Address into Individual Columns (Address, City, State)


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "SoldAsVacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END

-----------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

-- CTE or common table expression used with ROW_NUMBER to capture duplicates
WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
                    UniqueID
    ) row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate