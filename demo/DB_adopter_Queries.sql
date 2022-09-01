-- 3. User/Adopter Info
-- View: user/adopter pet preference
CREATE VIEW user_preference AS
SELECT AD.Adopter_ID,
Concat(Adopter_Fname, " ", Adopter_Lname) as Usr_Name,
Pet_Type, Pet_Gender, Pet_Size, PET_Color, Pet_Coat, Pet_Breed
FROM ADOPTER AD
    JOIN ADOPTER_PREFERENCE ON ADOPTER_PREFERENCE.Adopter_ID = AD.Adopter_ID
    JOIN PET_TYPE ON ADOPTER_PREFERENCE.Pet_Type_ID = PET_TYPE.Pet_Type_ID
	JOIN PET_GENDER ON ADOPTER_PREFERENCE.Pet_Gender_ID = PET_Gender.Pet_Gender_ID
    JOIN PET_SIZE ON ADOPTER_PREFERENCE.Pet_Size_ID = PET_SIZE.Pet_Size_ID
    JOIN PET_COLOR ON ADOPTER_PREFERENCE.Pet_Color_ID = PET_COLOR.Pet_Color_ID
    JOIN PET_COAT ON ADOPTER_PREFERENCE.Pet_Coat_ID = PET_COAT.Pet_Coat_ID
	JOIN PET_BREED ON ADOPTER_PREFERENCE.Pet_Breed_ID = PET_Breed.Pet_Breed_ID
ORDER BY AD.Adopter_ID;

SELECT * FROM Adopter;

-- 3.1. Customized loggin page for Ellis Watts
-- based on preference + user location
SELECT user_preference.*, Zip_Code AS location
FROM user_preference
	JOIN ADOPTER ON ADOPTER.Adopter_ID = user_preference.Adopter_ID
WHERE Usr_name = "Ellis Watts";

-- View: user/adopter's saved pets
CREATE VIEW user_favorite AS
SELECT AD.Adopter_ID,
Concat(Adopter_Fname, " ", Adopter_Lname) as Usr_Name,
Pet_ID
FROM ADOPTER AD
	JOIN FAVORITE_PET ON FAVORITE_PET.Adopter_ID = AD.Adopter_ID
ORDER BY AD.Adopter_ID;
select * from user_favorite;


-- User act log for BI to predict user's preference
-- CREATE VIEW user_log AS
SELECT Log_ID, ACTIVITY_LOG.Adopter_ID,
Concat(Adopter_Fname, " ", Adopter_Lname) as Usr_Name,
Activity_Type, Request_URL,Log_Data,Pet_ID as Extracted_PetID
FROM ACTIVITY_LOG
	JOIN ADOPTER ON ADOPTER.Adopter_ID = ACTIVITY_LOG.Adopter_ID
;

-- 1. What does Ellis Watts may like based on activity log?
SELECT Extracted_PetID FROM user_log
WHERE Usr_Name = "Ellis Watts";

SELECT Pet_ID,
Pet_Type,Pet_Breed,Pet_Age,Pet_Gender,Pet_Color,Pet_Size,Pro_City
FROM petinfo
WHERE Pet_ID in (SELECT Extracted_PetID FROM user_log
WHERE Usr_Name = "Ellis Watts");

-- 2. What does Ellis Watts may like based on her preference setting?
select * from user_preference
WHERE Usr_Name like "Ellis Watts"

-- 3. Email notification based on (act log + preference setting + favorites) analysis
