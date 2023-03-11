SELECT *
FROM PorftolioProject.dbo.NashvilleHousing

--Standardizing Date Format--
SELECT SaleDate,SaleDateConverted
FROM dbo.NashvilleHousing;

SELECT SaleDate,CONVERT(Date,SaleDate)
FROM PorftolioProject.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

--Populate Property address--
SELECT *
FROM PorftolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PorftolioProject.dbo.NashvilleHousing a
JOIN PorftolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID<> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PorftolioProject.dbo.NashvilleHousing a
JOIN PorftolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID<> b.UniqueID
WHERE a.PropertyAddress IS NULL

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
FROM PorftolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PorftolioProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PorftolioProject.dbo.NashvilleHousing 

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PorftolioProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM PorftolioProject.dbo.NashvilleHousing 

--Change the Y and N to YES and No in the "Sold as Vacant" field--

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PorftolioProject.dbo.NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
   CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'NO'
   ELSE SoldAsVacant
   END
FROM PorftolioProject.dbo.NashvilleHousing 

UPDATE NashVilleHousing
  SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'NO'
   ELSE SoldAsVacant
   END
 
 ---Removing Duplicates---
 SELECT *,
 ROW_NUMBER() OVER (
 PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY UniqueID
			) row_num
FROM PorftolioProject.dbo.NashvilleHousing 
ORDER BY ParcelID

--Identifying Duplicates----
WITH Row_NumCTE AS (
SELECT *,
 ROW_NUMBER() OVER (
 PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY UniqueID
			) row_num
FROM PorftolioProject.dbo.NashvilleHousing 
--ORDER BY ParcelID
)
SELECT* 
FROM Row_NumCTE
WHERE row_num > 1
---ORDER BY Propertyaddress

---Deleting Duplicates---
--Identifying Duplicates----
WITH Row_NumCTE AS (
SELECT *,
 ROW_NUMBER() OVER (
 PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY UniqueID
			) row_num
FROM PorftolioProject.dbo.NashvilleHousing 
--ORDER BY ParcelID
)
DELETE 
FROM Row_NumCTE
WHERE row_num > 1
---ORDER BY Propertyaddress

SELECT*		  
FROM PorftolioProject.dbo.NashvilleHousing

----Delete Unused Table---
ALTER TABLE PorftolioProject.dbo.NashvilleHousing
DROP COLUMN Owneraddress,Propertyaddress,TaxDistrict

ALTER TABLE PorftolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate


