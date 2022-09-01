
-- -------------------------- --
-- Petfinder Database Design. --
-- Schema                     --
-- By Mavis Wang              --
-- 11/20/2020                 --
-- -------------------------- --


CREATE TABLE PET_TYPE (
	Pet_Type_ID int not null unique,
    Pet_Type varchar(15),
    primary key (Pet_Type_ID)
);

CREATE TABLE PET_COAT (
	Pet_Coat_ID int not null unique,
    Pet_Coat varchar(15),
    primary key (Pet_Coat_ID)
);

CREATE TABLE PET_AGE (
	Pet_Age_ID int not null unique,
    Pet_Age varchar(15),
    primary key (Pet_Age_ID)
);

CREATE TABLE PET_SIZE (
	Pet_Size_ID int not null unique,
    Pet_Size varchar(50),
    primary key (Pet_Size_ID)
);

CREATE TABLE PET_GENDER (
	Pet_Gender_ID int not null unique,
    Pet_Gender varchar(15),
    primary key (Pet_Gender_ID)
);

CREATE TABLE PET_COLOR (
	Pet_Color_ID int not null unique,
    Pet_Color varchar(15),
    primary key (Pet_Color_ID)
);

CREATE TABLE PET_BREED (
	Pet_Breed_ID int not null unique,
    Pet_Breed varchar(35),
    Pet_Type_ID int,
    primary key (Pet_Breed_ID),
    foreign key (Pet_Type_ID) references PET_TYPE(Pet_Type_ID)
);

CREATE TABLE PROVIDER_TYPE (
	Pro_Type_ID int not null unique,
    Pro_Type varchar(35),
    primary key (Pro_Type_ID)
);

CREATE TABLE PROVIDER (
	Pro_ID int not null unique,
    Pro_Name varchar(50),
    Pro_Email varchar(30),
    Pro_PNum tinytext,
    Pro_Zip char(5),
    Pro_Adrs tinytext,
    Pro_City varchar(20),
    Pro_State char(2),
    Adopt_Fee_Range varchar(20),
    Pro_Verification_Status tinyint(1),
    Pro_Type_ID int,
    primary key (Pro_ID),
	foreign key (Pro_Type_ID) references PROVIDER_TYPE(Pro_Type_ID)
);

CREATE TABLE ADOPTER (
	Adopter_ID int not null unique,
    Adopter_Fname varchar(30),
    Adopter_Lname varchar(30),
    Adopter_Email varchar(30),
    Adopter_PNum tinytext,
    Zip_Code char(5),
    Pet_Owner_Status tinyint(1),
    Notification tinyint(1),
    primary key (Adopter_ID)
);

CREATE TABLE CREDENTIAL (
	Login_ID varchar(15) not null unique,
    Password varchar(15),
    Adopter_ID int,
	primary key (Login_ID),
    foreign key (Adopter_ID) references ADOPTER(Adopter_ID)
);

CREATE TABLE ADOPTER_PREFERENCE (
	Adopter_ID int not null,
    Pet_Type_ID int not null,
	Pet_Gender_ID int, 
	Pet_Breed_ID int,
    Pet_Size_ID int,
    Pet_Age_ID int,
    Pet_Coat_ID int,
    Pet_Color_ID int,
    primary key (Adopter_ID),
	foreign key (Adopter_ID) references ADOPTER(Adopter_ID),
	foreign key (Pet_Type_ID) references PET_TYPE(Pet_Type_ID),
    foreign key (Pet_Gender_ID) references PET_GENDER(Pet_Gender_ID),
    foreign key (Pet_Breed_ID) references PET_BREED(Pet_Breed_ID),
    foreign key (Pet_Size_ID) references PET_SIZE(Pet_Size_ID),
    foreign key (Pet_Age_ID) references PET_AGE(Pet_Age_ID),
    foreign key (Pet_Coat_ID) references PET_COAT(Pet_Coat_ID),
    foreign key (Pet_Color_ID) references PET_COLOR(Pet_Color_ID)
);

CREATE TABLE PET (
	Pet_ID int not null unique,
	Pro_ID int,
	Pet_Type_ID int,
    Pet_Coat_ID int,
    Pet_Color_ID int,
    Pet_Breed_ID int,
    Pet_Size_ID int,
    Pet_Gender_ID int,
    Pet_Age_ID int(2),
	Spay_Neuter tinyint(1),
	Pet_Name varchar(30),
    Pet_Background text,
    primary key (Pet_ID),
    foreign key (Pet_Type_ID) references PET_TYPE(Pet_Type_ID),
    foreign key (Pet_Coat_ID) references PET_COAT(Pet_Coat_ID),
    foreign key (Pet_Color_ID) references PET_COLOR(Pet_Color_ID),
	foreign key (Pet_Breed_ID) references PET_BREED(Pet_Breed_ID),
	foreign key (Pet_Size_ID) references PET_SIZE(Pet_Size_ID),
	foreign key (Pet_Gender_ID) references PET_GENDER(Pet_Gender_ID),
	foreign key (Pet_Age_ID) references PET_AGE(Pet_Age_ID),
	foreign key (Pro_ID) references PROVIDER(Pro_ID)
);

CREATE TABLE FAVORITE_PET (
	Adopter_ID int not null,
    Pet_ID int,
	primary key (Adopter_ID, Pet_ID),
    foreign key (Adopter_ID) references ADOPTER(Adopter_ID),
	foreign key (Pet_ID) references PET(Pet_ID)
);

CREATE TABLE DONATION (
	Donation_ID int not null unique,
    Donation_Amount int,
    Donation_Type varchar(30),
    Adopter_ID int,
    Pro_ID int,
    primary key (Donation_ID),
    foreign key (Adopter_ID) references ADOPTER(Adopter_ID), 
    foreign key (Pro_ID) references PROVIDER(Pro_ID) 
);

CREATE TABLE ACTIVITY_LOG (
	Log_ID int not null,
	Adopter_ID int not null,
    Activity_Type varchar(20),
    Request_URL varchar(255),
    Log_Data varchar(255),
	primary key (Log_ID),
    foreign key (Adopter_ID) references ADOPTER(Adopter_ID)
);

CREATE TABLE PET_PHOTO (
	Pet_Photo_ID int not null unique,
    Pet_ID int,
    Pet_Photo_URL varchar(255),
    primary key (Pet_Photo_ID),
    foreign key (Pet_ID) references PET(Pet_ID)
);

CREATE TABLE VACCINATION (
    Vaccination_ID int not null unique,
    Vaccination_Name varchar(30),
	Vaccination_Description varchar(50),
    primary key (Vaccination_ID)
);

CREATE TABLE PET_VACCINATION_STATUS (
	Pet_ID int not null,
    Vaccination_ID int not null,
    Vaccination_Date date,
    primary key (Pet_ID, Vaccination_ID),
    foreign key (Pet_ID) references PET(Pet_ID),
    foreign key (Vaccination_ID) references VACCINATION(Vaccination_ID)
);
