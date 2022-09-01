-- Available pets by Location
select * from pet_distribution;

delimiter $$
create procedure GetPetListByCity(
	in city_ varchar(20),
    in pet_type_ varchar(10)
    )
begin
	select * from pet_distribution
	where Pet_Type = pet_type_ and Pro_City = city_;
end $$
delimiter ;

call GetPetListByCity('San Jose', 'Dog');


-- Available pets by Location from petsinfo VIEW
delimiter $$
create procedure GetPetsByCity(
	in city_ varchar(20),
    in pet_type_ varchar(10)
    )
begin
	select distinct Pro_City as Location, Pet_ID, Pet_Type,Pet_Name, 
		Pet_Age as Age, Pet_Gender as Gender, Pet_Color as Color, 
        Pet_Coat as Coat, Pet_Breed, Pet_Size
    from petinfo 
    where Pet_Type = pet_type_ and Pro_City = city_;
end $$
delimiter ;

call GetPetsByCity('San Jose', 'Cat');


