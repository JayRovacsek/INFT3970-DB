/*

DROP TABLE UsersAddress
DROP TABLE UsersPassword
DROP TABLE Temperature
DROP TABLE Humidity
DROP TABLE Motion
DROP TABLE Sensor
DROP TABLE Room 
DROP TABLE Users

*/

--This creates the User table for both Admins and Customers
CREATE TABLE Users (
UserID		INT PRIMARY KEY NOT NULL IDENTITY(1,1),
fName			VARCHAR(40) NOT NULL,
lName			VARCHAR(40) NOT NULL,
ContactNumber	VARCHAR(10) NOT NULL,
Email			VARCHAR(50) NOT NULL,
Status			VARCHAR(15) NOT NULL DEFAULT('Active'),
IsAdmin			CHAR(1) NOT NULL DEFAULT('N')
)
GO

CREATE TABLE UsersAddress (
UserID	    INT PRIMARY KEY NOT NULL,
StreetNum		VARCHAR(10) NOT NULL,
StreetName		VARCHAR(50) NOT NULL,
City			VARCHAR(30) NOT NULL,
State			VARCHAR(3)  NOT NULL,
Postcode		VARCHAR(5)  NOT NULL,
Country			VARCHAR(30) NOT NULL,
foreign key (UserID) references Users (UserID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE UsersPassword (
UserID		INT PRIMARY KEY NOT NULL,
HashedPassword	BINARY(256) NOT NULL,
Salt			UNIQUEIDENTIFIER,
foreign key (UserID) references Users (UserID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Room (
RoomID INT PRIMARY KEY NOT NULL,
Name VARCHAR(50),
Description VARCHAR(200)
)
GO

CREATE TABLE Sensor (
SensorID	INT PRIMARY KEY NOT NULL IDENTITY(1,1),
UserID		INT,
Name		VARCHAR(50) NOT NULL,
Description VARCHAR(200) NOT NULL,
RoomID		INT, 
Foreign Key (UserID) References Users (UserID) ON UPDATE CASCADE ON DELETE NO ACTION,
Foreign Key (RoomID) References Room (RoomID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Temperature (
TempID INT PRIMARY KEY NOT NULL,
SensorID	INT NOT NULL,
Temp		DECIMAL(3,2),
Date		DATETIME,
Foreign Key (SensorID) References Sensor (SensorID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE Humidity (
HumidityID INT PRIMARY KEY NOT NULL,
SensorID	INT NOT NULL,
Humidity	DECIMAL(3,2),
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

INSERT INTO Room VALUES ('1', 'Kitchen', 'This is the main kitchen room for a household')
INSERT INTO Room VALUES ('2', 'Study', 'This is the main Study room for a household')
INSERT INTO Room VALUES ('3', 'Lounge', 'This is the main Lounge room for a household')
