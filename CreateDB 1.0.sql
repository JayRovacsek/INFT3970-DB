/*
DROP TABLE Sensor
DROP TABLE CustomerAddress
DROP TABLE CustomerPassword
DROP TABLE Customer
DROP TABLE Temperature
DROP TABLE Humidity
DROP TABLE Motion
*/

CREATE TABLE CustomerAddress (
AddressID		INT PRIMARY KEY NOT NULL,
StreetNum		VARCHAR(10),
StreetName		VARCHAR(50),
Postcode		VARCHAR(5),
City			VARCHAR(30),
State			VARCHAR(3),
Country			VARCHAR(30)	
)
GO

CREATE TABLE CustomerPassword (
CustomerID	INT NOT NULL PRIMARY KEY,
Password	VARCHAR(64) NOT NULL,
foreign key (CustomerID) references Customer (CustomerID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Customer (
CustomerID		INT PRIMARY KEY NOT NULL IDENTITY(1,1),
fName			VARCHAR(30) NOT NULL,
lName			VARCHAR(20) NOT NULL,
ContactNumber	VARCHAR(10),
Email			VARCHAR(50) NOT NULL,
AddressID		INT NOT NULL,
Foreign Key (AddressID) References CustomerAddress (AddressID) ON UPDATE CASCADE ON DELETE NO ACTION,
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
Temp		DECIMAL(3,2),
Date		TIMESTAMP,
Foreign Key (SensorID) References Sensor (SensorID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Humidity (
HumidityID INT PRIMARY KEY NOT NULL,
SensorID	INT NOT NULL,
Humidity	DECIMAL(3,2),
Date		TIMESTAMP,
Foreign Key (SensorID) References Sensor (SensorID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Motion (
MotionID INT PRIMARY KEY NOT NULL,
SensorID	INT NOT NULL,
Motion		BIT,
Date		TIMESTAMP,
Foreign Key (SensorID) References Sensor (SensorID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Room (
RoomID INT PRIMARY KEY NOT NULL,
Name VARCHAR(50),
Description VARCHAR(200)
)
GO
