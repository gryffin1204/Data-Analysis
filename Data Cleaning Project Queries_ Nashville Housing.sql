-- Cleaning Data in SQL Queries
-----------------------------------------------------------------------

SELECT *
FROM VaibhavSQL.dbo.Housing


-----------------------------------------------------------------------
-- Standardise Date Format


ALTER TABLE VaibhavSQL.dbo.Housing
ADD UpdatedSaleDate Date;

Update VaibhavSQL.dbo.Housing
SET UpdatedSaleDate = CONVERT(Date,SaleDate)

SELECT UpdatedSaleDate, SaleDate
FROM VaibhavSQL.dbo.Housing


-----------------------------------------------------------------------
-- Populate Property Address Data


SELECT *
FROM VaibhavSQL.dbo.Housing
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM VaibhavSQL.dbo.Housing a
JOIN VaibhavSQL.dbo.Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM VaibhavSQL.dbo.Housing a
JOIN VaibhavSQL.dbo.Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

SELECT PropertyAddress
FROM VaibhavSQL.dbo.Housing
WHERE PropertyAddress is NULL


-------------------------------------------------------------------------
-- Breaking out Full Address into individual Columns (Address, City, State)

--Property Address

SELECT PropertyAddress
FROM VaibhavSQL.dbo.Housing


ALTER TABLE VaibhavSQL.dbo.Housing
ADD PropertyAddressStreet NVARCHAR(255);

UPDATE VaibhavSQL.dbo.Housing
SET PropertyAddressStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


ALTER TABLE VaibhavSQL.dbo.Housing
ADD PropertyAddressCity NVARCHAR(255);

UPDATE VaibhavSQL.dbo.Housing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) 

SELECT PropertyAddressStreet, PropertyAddressCity
FROM VaibhavSQL.dbo.Housing


-- Owner Address

SELECT OwnerAddress
FROM VaibhavSQL.dbo.Housing


ALTER TABLE VaibhavSQL.dbo.Housing
ADD OwnerAddressStreet NVARCHAR(255);

UPDATE VaibhavSQL.dbo.Housing
SET OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE VaibhavSQL.dbo.Housing
ADD OwnerAddressCity NVARCHAR(255);

UPDATE VaibhavSQL.dbo.Housing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE VaibhavSQL.dbo.Housing
ADD OwnerAddressState NVARCHAR(255);

UPDATE VaibhavSQL.dbo.Housing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


------------------------------------------------------------------------------
-- Change "Y" to "Yes" and "N" to "No" in the "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant
FROM VaibhavSQL.dbo.Housing


UPDATE VaibhavSQL.dbo.Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


	
-------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				   UniqueID
				   ) row_num

FROM VaibhavSQL.dbo.Housing
)
--SELECT *
DELETE
FROM RowNUMCTE
WHERE row_num > 1
--ORDER BY PropertyAddress



----------------------------------------------------------------
-- Delete Unused Columns


SELECT *
FROM VaibhavSQL.dbo.Housing

ALTER TABLE VaibhavSQL.dbo.Housing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress

