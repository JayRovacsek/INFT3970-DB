/* These drop each of the different Tables from the database

DROP TABLE UsersAddress
DROP TABLE UsersPassword
DROP TABLE Temperature
DROP TABLE Humidity
DROP TABLE Motion
DROP TABLE Sensor
DROP TABLE Room 
DROP TABLE Users

*/

--This creates the User's personal information table for both Admins and Customers
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

--This creates the address table for both Admins and Customers
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

--This creates the Password table for both Admins and Customers
CREATE TABLE UsersPassword (
UserID		INT PRIMARY KEY NOT NULL,
HashedPassword	BINARY(256) NOT NULL,
Salt			UNIQUEIDENTIFIER,
foreign key (UserID) references Users (UserID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

--This creates the Room table, each room is a category that can be linked to a sensor
CREATE TABLE Room (
RoomID INT PRIMARY KEY NOT NULL,
Name VARCHAR(50),
Description VARCHAR(200)
)
GO

--This creates the Sensor table, all information about the sensor and the user it is assigned to is stored here
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

--This creates the Temperature table, This stores all the temperature data from each different sensor
CREATE TABLE Temperature (
TempID INT IDENTITY(1,1) NOT NULL,
SensorID	INT NOT NULL,
Temp		DECIMAL(4,2),
Date		DATETIME,
Foreign Key (SensorID) References Sensor (SensorID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

--This creates the Humidity table, This stores all the Humidity data from each different sensor
CREATE TABLE Humidity (
HumidityID INT IDENTITY(1,1) NOT NULL,
SensorID	INT NOT NULL,
Humidity	DECIMAL(4,2),
Date		DATETIME,
Foreign Key (SensorID) References Sensor (SensorID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

--This creates the Motion table, This stores all the Motion data from each different sensor
CREATE TABLE Motion (
MotionID INT IDENTITY(1,1) NOT NULL,
SensorID	INT NOT NULL,
Motion		BIT,
Date		DATETIME,
Foreign Key (SensorID) References Sensor (SensorID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

