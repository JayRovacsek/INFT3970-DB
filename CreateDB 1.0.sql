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
CustomerID	INT NOT NULL,
PasswordID	INT PRIMARY KEY NOT NULL IDENTITY(1,1),
Password	VARCHAR(25) NOT NULL
)
GO

CREATE TABLE Customer (
CustomerID		INT PRIMARY KEY NOT NULL IDENTITY(1,1),
fName			VARCHAR(30) NOT NULL,
lName			VARCHAR(20) NOT NULL,
ContactNumber	VARCHAR(10),
Email			VARCHAR(50) NOT NULL,
PasswordID		INT NOT NULL,
AddressID		INT NOT NULL,
Foreign Key (AddressID) References CustomerAddress (AddressID) ON UPDATE CASCADE ON DELETE NO ACTION,
Foreign Key (PasswordID) References CustomerPassword (PasswordID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Sensor (
CustomerID	INT NOT NULL,
SensorID	INT PRIMARY KEY NOT NULL IDENTITY(1,1),
Name		VARCHAR(50) NOT NULL,
Description VARCHAR(200) NOT NULL,
Foreign Key (CustomerID) References Customer (CustomerID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Temperature (
SensorID	INT NOT NULL,
Temp		DECIMAL(3,2),
Date		TIMESTAMP,
Foreign Key (SensorID) References Sensor (SensorID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Humidity (
SensorID	INT NOT NULL,
Humidity	DECIMAL(3,2),
Date		TIMESTAMP,
Foreign Key (SensorID) References Sensor (SensorID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Motion (
SensorID	INT NOT NULL,
Motion		BIT,
Date		TIMESTAMP,
Foreign Key (SensorID) References Sensor (SensorID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO