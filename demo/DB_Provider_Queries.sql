-- 2. Provider Info
CREATE VIEW providerInfo AS
SELECT Pro_ID, 
Pro_Name,Pro_Email,Pro_PNum,
concat(Pro_Adrs, ", ", Pro_City, ", ", Pro_Zip) as Address,
round((Adopt_Fee_Min+Adopt_Fee_Max)/2) as Avg_Fee,
Pro_Type as 'Org Type'
FROM PROVIDER
	JOIN PROVIDER_TYPE ON PROVIDER.Pro_Type_ID = PROVIDER_TYPE.Pro_Type_ID
ORDER BY Pro_ID;
select * from providerinfo;

-- 2.2 Available pets in each Organization
SELECT DISTINCT PROVIDER.Pro_ID, Pro_Name,
count(Pet_ID) over(partition by PROVIDER.Pro_ID) as Available_Pets
FROM PROVIDER
	JOIN PET ON PET.Pro_ID = PROVIDER.Pro_ID
ORDER BY Pro_ID
;
-- Verify total number of available pets
select count(*) from PET;

-- 2.3 Pet list by provider
SELECT DISTINCT PROVIDER.Pro_ID, Pro_Name,
Pet_ID,
concat(Pet_Type, ", ", Pet_Name, ", ", Pet_Breed,", ", Pet_Gender, ", ",Pet_Age) as Pet_Info,
rank() over(partition by PROVIDER.Pro_ID order by Pet_ID) as Num_of_Pet
FROM PROVIDER
	JOIN PET ON PET.Pro_ID = PROVIDER.Pro_ID
    JOIN PET_TYPE ON PET.Pet_Type_ID = PET_TYPE.Pet_Type_ID
	JOIN PET_AGE ON PET.Pet_Age_ID = PET_AGE.Pet_Age_ID
    JOIN PET_GENDER ON PET.Pet_Gender_ID = PET_GENDER.Pet_Gender_ID
    JOIN PET_COLOR ON PET.Pet_Color_ID = PET_COLOR.Pet_Color_ID
	JOIN PET_COAT ON PET.Pet_Coat_ID = PET_COAT.Pet_Coat_ID
    JOIN PET_BREED ON PET.Pet_Breed_ID = PET_BREED.Pet_Breed_ID
WHERE Pro_Name = 'Toy Breed Rescue'
ORDER BY Pro_ID
;


-- 2.4 Pets distribution by provider
SELECT distinct PROVIDER.Pro_ID,Pro_Name as Provider, Pro_City,Pet_Type,
count(Pet_ID) over(partition by PROVIDER.Pro_ID, Pet_type.Pet_type) as 'Available Type',
count(Pet_ID) over(partition by PROVIDER.Pro_ID) as 'Total Pets'
FROM PROVIDER
	JOIN PET ON PET.Pro_ID = PROVIDER.Pro_ID
    JOIN PET_TYPE ON PET.Pet_Type_ID = PET_TYPE.Pet_Type_ID
ORDER BY 'Total Pets' desc;

-- 2.5 donation info
Select PROVIDER.Pro_ID, Pro_Name,
	Donation_Amount,
    Concat(Adopter_Fname, " ", Adopter_Lname) as Donor,
    Adopter_Email as Donor_Contact
FROM PROVIDER
    JOIN DONATION ON DONATION.Pro_ID = PROVIDER.Pro_ID
    JOIN ADOPTER ON ADOPTER.Adopter_ID = DONATION.Adopter_ID
;

-- total amount of donation and number of donor
Select PROVIDER.Pro_ID, Pro_Name,
	Donation_Amount,
    concat(Adopter_Fname, " ", Adopter_Lname) as Donor,
    Adopter_Email as Donor_Contact,
    sum(Donation_Amount) over(partition by Pro_Name) as Total_Donation_Amt,
    count('Donor') over(partition by Donation_Amount) as Num_Donor
FROM PROVIDER
    JOIN DONATION ON DONATION.Pro_ID = PROVIDER.Pro_ID
    JOIN ADOPTER ON ADOPTER.Adopter_ID = DONATION.Adopter_ID
;
