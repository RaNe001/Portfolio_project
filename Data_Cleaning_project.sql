use project
select * from housing_data

/*
Standarization of date format
*/

select saledate_converted, cast(saledate as date) from housing_data

update housing_data
set saledate = convert(date, saledate);


alter table housing_data 
add saledate_converted date;


update housing_data set
saledate_converted = cast(saledate as date);


/*
Populate property address data
*/


select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
from housing_data a
join housing_data b
on a.parcelid = b.parcelid and a.uniqueid <> b.uniqueid
where a.propertyaddress is null


update a
set
propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from housing_data a
join housing_data b
on a.parcelid = b.parcelid and a.uniqueid <> b.uniqueid
where a.propertyaddress is null


-- Breaking out address into individual columns (address, city, state)


select propertyaddress from housing_data

select SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) as address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1 , len(propertyaddress)) as address
from housing_data

alter table housing_data
add propertysplit_address nvarchar(255);

update housing_data
set propertysplit_address = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1)

alter table housing_data
add propertysplit_city nvarchar(255);

update housing_data
set propertysplit_city = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1 , len(propertyaddress))



select owneraddress from housing_data -- Gonna split the owneraddress into (address, city, state)


select 
PARSENAME(replace(owneraddress, ',', '.'), 3),
PARSENAME(replace(owneraddress, ',', '.'), 2),
PARSENAME(replace(owneraddress, ',', '.'), 1)
from housing_data

alter table housing_data
add ownersplit_address nvarchar(255);

update housing_data
set ownersplit_address = PARSENAME(replace(owneraddress, ',', '.'), 3)

alter table housing_data
add ownersplit_city nvarchar(255);

update housing_data
set ownersplit_city = PARSENAME(replace(owneraddress, ',', '.'), 2)

alter table housing_data
add ownersplit_state nvarchar(255);

update housing_data
set ownersplit_state = PARSENAME(replace(owneraddress, ',', '.'), 1)


-- Change Y and N to Yes and No in SoldAsVacant	

select soldasvacant, count(soldasvacant) from housing_data group by soldasvacant order by count(SoldAsVacant) asc

select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end
from housing_data

update housing_data
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end


-- Delete Duplicates

with row_num_cte as(
select *, ROW_NUMBER()
over(partition by parcelid, propertyaddress, saledate, legalreference order by uniqueid) row_num
from housing_data)
select * from row_num_cte
where row_num>1

with row_num_cte as(
select *, ROW_NUMBER()
over(partition by parcelid, propertyaddress, saledate, legalreference order by uniqueid) row_num
from housing_data)
delete from row_num_cte
where row_num>1


-- Delete Unused Columns

alter table housing_data
drop column propertyaddress, owneraddress, saledate
