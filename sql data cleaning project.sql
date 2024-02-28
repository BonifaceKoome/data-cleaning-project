--Data cleaning project
--standardize date formart
select Saledateconverted,CONVERT(date,saledate)
from nashvillHousing

UPDATE nashvillHousing
set SaleDate=CONVERT(date,saledate)

ALTER TABLE nashvillHousing
add saledateconverted Date;

UPDATE nashvillHousing
set saledateconverted =CONVERT(date,saledate)

--populate property adress
select PropertyAddress
from nashvillHousing
where PropertyAddress is null

--populate property address data
select a.[UniqueID ], a.ParcelID, a.PropertyAddress,b.[UniqueID ], b.ParcelID, b.PropertyAddress ,ISNULL( a.PropertyAddress,b.PropertyAddress)
from sqlportfolioprojects.dbo .nashvillHousing a
JOIN sqlportfolioprojects.dbo .nashvillHousing b
    ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
 where a.PropertyAddress is null

update a
SET PropertyAddress=ISNULL( a.PropertyAddress,b.PropertyAddress)
from sqlportfolioprojects.dbo .nashvillHousing a
JOIN sqlportfolioprojects.dbo .nashvillHousing b
    ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
 where a.PropertyAddress is null

 --Breaking propertyaddress into individual columns (address,city,state)
 select PropertyAddress
 from sqlportfolioprojects.dbo.nashvillHousing

 select 
 SUBSTRING (PropertyAddress ,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
 SUBSTRING ( PropertyAddress, CHARINDEX(',',PropertyAddress)+1 ,LEN (PropertyAddress)) AS City
 from sqlportfolioprojects.dbo.nashvillHousing

 ALTER TABLE nashvillHousing
add propertysplitaddress Nvarchar(255);

UPDATE nashvillHousing
set propertysplitaddress =SUBSTRING (PropertyAddress ,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE nashvillHousing
add propertycity Nvarchar(255);

UPDATE nashvillHousing
set propertycity= SUBSTRING ( PropertyAddress, CHARINDEX(',',PropertyAddress)+1 ,LEN (PropertyAddress))


--Breaking owneraddress into individual columns (address,city,state) using PARSNAME
select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from nashvillHousing

ALTER TABLE nashvillHousing
add OwnersplitAddress Nvarchar(255);

UPDATE nashvillHousing
set OwnersplitAddress =PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE nashvillHousing
add OwnersplitCity Nvarchar(255);

UPDATE nashvillHousing
set OwnersplitCity= PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE nashvillHousing
add OwnersplitState Nvarchar(255);

UPDATE nashvillHousing
set OwnersplitState= PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

select OwnersplitCity,OwnersplitAddress,OwnersplitState
from nashvillHousing

--changing Y AND N to Yes and No ib 'sold as Vacant' field
select DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
from nashvillHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE WHEN SoldAsVacant ='y' then 'yes'
	 WHEN SoldAsVacant ='N' then 'yes'
	 ELSE SoldAsVacant
     END 
from sqlportfolioprojects.dbo.nashvillHousing

update nashvillHousing
SET SoldAsVacant=CASE WHEN SoldAsVacant ='y' then 'yes'
	 WHEN SoldAsVacant ='N' then 'yes'
	 ELSE SoldAsVacant
     END 


--removing duplicates
with rownumCTE AS(
select*,
  ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
               PropertyAddress,
			   SaleDate,
			   SalePrice,
			   LegalReference
			   ORDER BY ParcelID)
			   row_num

from sqlportfolioprojects.dbo.nashvillHousing
)
DELETE
FROM rownumCTE
WHERE row_num>1 


--Delete unwanted columns
ALTER TABLE sqlportfolioprojects.dbo.nashvillHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress;