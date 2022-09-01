-- PET Info
-- View: basic pet info
CREATE VIEW PetInfo AS
SELECT PET.Pet_ID, Pet_Type, Pet_Name,Pet_Breed,Pet_Coat, Pet_Color,Pet_Age,Pet_Gender,Pet_Size,
Pro_City,Pro_Name, Pro_Type,Pro_Email, Pro_PNum
FROM PET 
	JOIN PET_TYPE ON PET.Pet_Type_ID = PET_TYPE.Pet_Type_ID
	JOIN PET_AGE ON PET.Pet_Age_ID = PET_AGE.Pet_Age_ID
    JOIN PET_GENDER ON PET.Pet_Gender_ID = PET_GENDER.Pet_Gender_ID
    JOIN PET_COLOR ON PET.Pet_Color_ID = PET_COLOR.Pet_Color_ID
	JOIN PET_COAT ON PET.Pet_Coat_ID = PET_COAT.Pet_Coat_ID
    JOIN PET_BREED ON PET.Pet_Breed_ID = PET_BREED.Pet_Breed_ID
    JOIN PET_SIZE ON PET.Pet_Size_ID = PET_SIZE.Pet_Size_ID
    JOIN PROVIDER ON PET.Pro_ID = PROVIDER.Pro_ID
    JOIN PROVIDER_TYPE ON PROVIDER_TYPE.Pro_Type_ID = PROVIDER.Pro_Type_ID
ORDER BY Pet_ID;

SELECT * FROM petinfo;

-- CREATE VIEW Pet_Provider AS 
SELECT PET.Pet_ID, 
Pet_Type as 'Pet Type',
Pet_Name as 'Pet Name',
Pet_Age as Age,
Pet_Gender as Gender,
Pet_Color as Color,
Pet_Coat as 'Coat Length',
Pet_Breed as Breed,
Pet_Size as 'Breed Size',
Vaccination_Name as Vaccination,
Vaccination_Date,
Pet_Photo_URL as 'Photo URL',
Pro_Zip as Location,
Pro_City as City,
Pro_Name as Provider,
Pro_Email, Pro_PNum, Pro_Adrs,
Donation_Amount,
ADOPTER.Adopter_ID
FROM PET 
	JOIN PET_TYPE ON PET.Pet_Type_ID = PET_TYPE.Pet_Type_ID
	JOIN PET_AGE ON PET.Pet_Age_ID = PET_AGE.Pet_Age_ID
    JOIN PET_GENDER ON PET.Pet_Gender_ID = PET_GENDER.Pet_Gender_ID
    JOIN PET_COLOR ON PET.Pet_Color_ID = PET_COLOR.Pet_Color_ID
	JOIN PET_COAT ON PET.Pet_Coat_ID = PET_COAT.Pet_Coat_ID
    JOIN PET_BREED ON PET.Pet_Breed_ID = PET_BREED.Pet_Breed_ID
    LEFT JOIN PET_VACCINATION_STATUS on PET.Pet_ID = PET_VACCINATION_STATUS.Pet_ID
    LEFT JOIN VACCINATION ON VACCINATION.Vaccination_ID = PET_VACCINATION_STATUS.Vaccination_ID
    JOIN PET_SIZE ON PET.Pet_Size_ID = PET_SIZE.Pet_Size_ID
    JOIN PROVIDER ON PET.Pro_ID = PROVIDER.Pro_ID
    LEFT JOIN PET_PHOTO ON PET.Pet_ID = PET_PHOTO.Pet_ID
    JOIN DONATION ON DONATION.Pro_ID = PROVIDER.Pro_ID
    JOIN ADOPTER ON ADOPTER.Adopter_ID = DONATION.Adopter_ID
ORDER BY Pet_ID;

-- 1. Pet info
SELECT PET.Pet_ID, 
Pet_Type as 'Pet Type',
Pet_Name as 'Pet Name',
Pet_Breed as Breed,
Pro_City as Location,
CONCAT(Pet_Coat, ", ", Pet_Color) as Coat,
CONCAT(Pet_Age, ", ", Pet_Gender, ", ", Pet_Size ) as Pet_Profile,
CONCAT(Pro_Name, ", ", Pro_Type) as Provider,
Pro_Email, Pro_PNum
FROM PET 
	JOIN PET_TYPE ON PET.Pet_Type_ID = PET_TYPE.Pet_Type_ID
	JOIN PET_AGE ON PET.Pet_Age_ID = PET_AGE.Pet_Age_ID
    JOIN PET_GENDER ON PET.Pet_Gender_ID = PET_GENDER.Pet_Gender_ID
    JOIN PET_COLOR ON PET.Pet_Color_ID = PET_COLOR.Pet_Color_ID
	JOIN PET_COAT ON PET.Pet_Coat_ID = PET_COAT.Pet_Coat_ID
    JOIN PET_BREED ON PET.Pet_Breed_ID = PET_BREED.Pet_Breed_ID
    JOIN PET_SIZE ON PET.Pet_Size_ID = PET_SIZE.Pet_Size_ID
    JOIN PROVIDER ON PET.Pro_ID = PROVIDER.Pro_ID
    JOIN PROVIDER_TYPE ON PROVIDER_TYPE.Pro_Type_ID = PROVIDER.Pro_Type_ID
ORDER BY Pet_Type;

-- 1.1. View a specified pet summary
SELECT DISTINCT PET.Pet_ID, 
Pet_Type as 'Pet Type',
Pet_Name as 'Pet Name',
CONCAT(Pet_Age, ", ", Pet_Gender, ", ",Pet_Color, ", ", Pet_Coat, Pet_Breed, Pet_Size) as Pet_Profile,
count(Vaccination_Name) over() as 'Vaccination',
Pro_Zip as Location,
Pro_Name as Provider,
Pro_Email, Pro_PNum
FROM PET 
	JOIN PET_TYPE ON PET.Pet_Type_ID = PET_TYPE.Pet_Type_ID
	JOIN PET_AGE ON PET.Pet_Age_ID = PET_AGE.Pet_Age_ID
    JOIN PET_GENDER ON PET.Pet_Gender_ID = PET_GENDER.Pet_Gender_ID
    JOIN PET_COLOR ON PET.Pet_Color_ID = PET_COLOR.Pet_Color_ID
	JOIN PET_COAT ON PET.Pet_Coat_ID = PET_COAT.Pet_Coat_ID
    JOIN PET_BREED ON PET.Pet_Breed_ID = PET_BREED.Pet_Breed_ID
    JOIN PET_VACCINATION_STATUS on PET.Pet_ID = PET_VACCINATION_STATUS.Pet_ID
    JOIN VACCINATION ON VACCINATION.Vaccination_ID = PET_VACCINATION_STATUS.Vaccination_ID
    JOIN PET_SIZE ON PET.Pet_Size_ID = PET_SIZE.Pet_Size_ID
    JOIN PROVIDER ON PET.Pro_ID = PROVIDER.Pro_ID
WHERE PET.Pet_ID = 205
ORDER BY Pet_ID;

-- 1.2 Pet 205's Vaccination Details
SELECT distinct petinfo.Pet_ID, Pet_Type, Pet_Name, Vaccination_Name, Vaccination_Date
FROM petinfo
	JOIN PET_VACCINATION_STATUS ON PET_VACCINATION_STATUS.Pet_ID = petinfo.Pet_ID
    JOIN VACCINATION ON VACCINATION.Vaccination_ID = PET_VACCINATION_STATUS.Vaccination_ID
WHERE petinfo.Pet_ID = 205;

-- 1.3 Pet Photos
SELECT distinct petinfo.Pet_ID, Pet_Name, Pet_Photo_URL
FROM petinfo
	JOIN PET_PHOTO ON PET_PHOTO.Pet_ID = petinfo.Pet_ID
where petinfo.pet_ID = 205
;

-- 1.4 Search Pets based on location
SELECT distinct 
Pro_City as Location, 
Pet_ID, Pet_Type,Pet_Name, Pet_Age as Age, Pet_Gender as Gender,
Pet_Color as Color, Pet_Coat as Coat, Pet_Breed, Pet_Size
FROM petinfo
WHERE Pro_City = 'San Jose';

-- 1.5 Filter Cats in a specified location
SELECT distinct 
Pro_City as Location, 
Pet_ID, Pet_Type,Pet_Name, Pet_Age as Age, Pet_Gender as Gender,
Pet_Color as Color, Pet_Coat as Coat, Pet_Breed, Pet_Size
FROM petinfo
WHERE Pro_City = 'San Jose' and Pet_Type = 'Cat'
;

-- What color of pet is the most preferred?
select distinct Pet_Color,
count(Pet_Color) over(partition by Pet_Color) as Num_color
from petinfo

    
-- Author: Mavis Wang
-- https://www.linkedin.com/in/maviswang
-- Ⓒ 2020 Mavis Wang
