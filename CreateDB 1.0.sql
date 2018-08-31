/*
DROP TABLE Sensor
DROP TABLE CustomerAddress
DROP TABLE CustomerPassword
DROP TABLE Customer
DROP TABLE Temperature
DROP TABLE Humidity
DROP TABLE Motion
DROP TABLE Room 
DROP TRIGGER New_Customer_Address_and_Salt
*/


CREATE TABLE Customer (
CustomerID		INT PRIMARY KEY NOT NULL IDENTITY(1,1),
fName			VARCHAR(30) NOT NULL,
lName			VARCHAR(20) NOT NULL,
ContactNumber	VARCHAR(10),
Email			VARCHAR(50) NOT NULL
)
GO

CREATE TABLE CustomerAddress (
CustomerID	    INT NOT NULL PRIMARY KEY,
StreetNum		VARCHAR(10),
StreetName		VARCHAR(50),
Postcode		VARCHAR(5),
City			VARCHAR(30),
State			VARCHAR(3),
Country			VARCHAR(30)	
foreign key (CustomerID) references Customer (CustomerID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE CustomerPassword (
CustomerID	INT NOT NULL PRIMARY KEY,
Password	VARCHAR(256) NOT NULL,
Salt		VARCHAR(32)
foreign key (CustomerID) references Customer (CustomerID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Room (
RoomID INT PRIMARY KEY NOT NULL,
Name VARCHAR(50),
Description VARCHAR(200)
)
GO

CREATE TABLE Sensor (
CustomerID	INT NOT NULL,
SensorID	INT PRIMARY KEY NOT NULL IDENTITY(1,1),
Name		VARCHAR(50) NOT NULL,
Description VARCHAR(200) NOT NULL,
RoomID		INt NOT NULL, 
Foreign Key (CustomerID) References Customer (CustomerID) ON UPDATE CASCADE ON DELETE NO ACTION,
Foreign Key (RoomID) References Room (RoomID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Temperature (
TempID INT PRIMARY KEY NOT NULL,
SensorID	INT NOT NULL,
Temp		DECIMAL(10,2),
Date		DATETIME,
Foreign Key (SensorID) References Sensor (SensorID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Humidity (
HumidityID INT PRIMARY KEY NOT NULL,
SensorID	INT NOT NULL,
Humidity	DECIMAL(10,2),
Date		DATETIME,
Foreign Key (SensorID) References Sensor (SensorID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Motion (
MotionID INT PRIMARY KEY NOT NULL,
SensorID	INT NOT NULL,
Motion		BIT,
Date		DATETIME,
Foreign Key (SensorID) References Sensor (SensorID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

/* this trigger upon insert into customer grabs the new id and inserts it into address and password tables to ensure consistancy that the id is the same accross records. 
Creates a salt and inserts a temp password because the password field is notnull. this password will imediatly be updated with the password teh user entered. 
*/ 
CREATE TRIGGER New_Customer_Address_and_Salt on Customer
AFTER INSERT
as
Begin 
 set nocount on 
 declare @ID int;
 declare @salt varchar(32);
 set @salt = (SELECT CRYPT_GEN_RANDOM(32)) ;
 select @ID= i.CustomerID from inserted i;
 insert into CustomerAddress (CustomerID)
 values (@ID);
 insert into CustomerPassword (CustomerID, Password, Salt)
 Values (@ID,'temporarypassword', @salt);
End
go

CREATE TRIGGER Hash_Password on CustomerPassword
AFTER UPDATE 
as
Begin
 Set nocount on 
 Declare @salt varchar(32);
 Declare @tempPassword char(64);
 set @tempPassword = i.password from inserted i;
 set @salt = i.Salt from inserted i;
 Insert into CustomerPassword (Password)
 Values (HASHBYTES('SHA2_256', @tempPassword+CAST(@salt AS VARCHAR(32));
End
go


insert into Customer (fName, lName, Email)
values ('ed', 'lons', 'edward@gmail.com');

select * from customer
select * from CustomerPassword
select * from CustomerAddress

