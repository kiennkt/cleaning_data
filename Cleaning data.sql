
USE Portfolio;
SELECT * FROM SaleHousing
WHERE ParcelID = '081 15 0 263.00';
/*
Cleaning data
*/

-------------------------Standard Date Format-----------------------------------------------

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM SaleHousing;

UPDATE SaleHousing
SET SaleDate = CONVERT(Date, SaleDate)

AlTER TABLE SaleHousing
ADD SaleDateConverted Date;

UPDATE SaleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

--------------------------------Check Null data, dupplicate data----------------------------

SELECT * FROM SaleHousing
ORDER BY ParcelID -- Observe Some dupplicate row

SELECT * FROM SaleHousing
WHERE PropertyAddress IS NULL -- Observe 29 row have null values

SELECT *
FROM SaleHousing a
JOIN SaleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] -- Observe lots of duplicate data, i have to remove rows that have duplictae ParcelID and NULL PropertyAddress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SaleHousing a
JOIN SaleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SaleHousing a
JOIN SaleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

---------------------Changing SoldAsVacant Column: From Yes, No to Y, N--------------------------------


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS CNT_SoldAsVacant
FROM SaleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
		 WHEN SoldAsVacant = 'N' Then 'No'
		 ELSE SoldAsVacant
		 END
FROM SaleHousing

UPDATE SaleHousing
SET SoldAsVacant = 	CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
						 WHEN SoldAsVacant = 'N' Then 'No'
						 ELSE SoldAsVacant
						 END

-------------------------Remove Duplicate---------------------------------------------

SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
		ORDER BY UniqueID) AS row_num
FROM SaleHousing;


WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
	FROM SaleHousing
)

SELECT * FROM RowNumCTE
WHERE row_num > 1

-- Delete
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
	FROM SaleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
