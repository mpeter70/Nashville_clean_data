--Cleaning Data.

--Change date format, add new column SalesDateConverted with new format

SELECT saleDate, 
       CONVERT(DATE, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing;



SELECT saleDate, 
       CONVERT(DATE, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted DATE;


UPDATE PortfolioProject.dbo.NashvilleHousing
  SET 
      SaleDateConverted = CONVERT(DATE, SaleDate);

-- Populate Property Address data with a SELF JOIN

SELECT a.ParcelID, 
       a.PropertyAddress, 
       b.ParcelID, 
       b.PropertyAddress, 
       ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
     JOIN PortfolioProject.dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID
                                                     AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


UPDATE a
  SET 
      PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
     JOIN PortfolioProject.dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID
                                                     AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;




--Dividing address into three columns (adress, city, state)


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);


UPDATE PortfolioProject.dbo.NashvilleHousing
  SET 
      OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE PortfolioProject.dbo.NashvilleHousing
  SET 
      OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE PortfolioProject.dbo.NashvilleHousing
  SET 
      OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);





-- Change Y and N to Yes and No in "Sold as Vacant" field with a CASE statement

SELECT SoldAsVacant,
       CASE
           WHEN SoldAsVacant = 'Y'
           THEN 'Yes'
           WHEN SoldAsVacant = 'N'
           THEN 'No'
           ELSE SoldAsVacant
       END
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE PortfolioProject.dbo.NashvilleHousing
  SET 
      SoldAsVacant = CASE
                         WHEN SoldAsVacant = 'Y'
                         THEN 'Yes'
                         WHEN SoldAsVacant = 'N'
                         THEN 'No'
                         ELSE SoldAsVacant
                     END;

-- Remove Duplicates, be careful. Use CTE to check for duplicates.

WITH RowNumCTE
     AS (SELECT *, 
                ROW_NUMBER() OVER(PARTITION BY ParcelID, 
                                               PropertyAddress, 
                                               SalePrice, 
                                               SaleDate, 
                                               LegalReference
         ORDER BY UniqueID) row_num
         FROM PortfolioProject.dbo.NashvilleHousing
    
	
     )
     SELECT *
     FROM RowNumCTE
     WHERE row_num > 1
     ORDER BY PropertyAddress;


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

--Then delete duplicate rows.

WITH RowNumCTE
     AS (SELECT *, 
                ROW_NUMBER() OVER(PARTITION BY ParcelID, 
                                               PropertyAddress, 
                                               SalePrice, 
                                               SaleDate, 
                                               LegalReference
         ORDER BY UniqueID) row_num
         FROM PortfolioProject.dbo.NashvilleHousing
    
	
     )
     DELETE
     FROM RowNumCTE
     WHERE row_num > 1;
     

-- Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;








