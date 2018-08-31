/*
DROP TABLE Sensor
DROP TABLE CustomerAddress
DROP TABLE CustomerPassword
DROP TABLE Customer
DROP TABLE Temperature
DROP TABLE Humidity
DROP TABLE Motion
DROP TABLE Room 
*/


CREATE TABLE Customer (
CustomerID		INT PRIMARY KEY NOT NULL IDENTITY(1,1),
fName			VARCHAR(40) NOT NULL ,
lName			VARCHAR(40) NOT NULL ,
ContactNumber	VARCHAR(10) NOT NULL,
Email			VARCHAR(50) NOT NULL
)
GO

CREATE TABLE CustomerAddress (
CustomerID	    INT PRIMARY KEY NOT NULL,
StreetNum		VARCHAR(10) NOT NULL,
StreetName		VARCHAR(50) NOT NULL,
City			VARCHAR(30) NOT NULL,
State			VARCHAR(3)  NOT NULL,
Postcode		VARCHAR(5)  NOT NULL,
Country			VARCHAR(30) NOT NULL,
foreign key (CustomerID) references Customer (CustomerID) ON UPDATE CASCADE ON DELETE NO ACTION
)
GO

CREATE TABLE CustomerPassword (
CustomerID		INT PRIMARY KEY NOT NULL,
HashedPassword	BINARY(256) NOT NULL,
Salt			UNIQUEIDENTIFIER,
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

/* DROPPING PROCS

DROP PROC dbo.uspAddUser

 */

CREATE PROC dbo.uspAddUser
	@fName			 VARCHAR(40), 
    @lName			 VARCHAR(40), 
	@ContactNumber	 VARCHAR(10),
	@Email			 VARCHAR(50),
	@StreetNum		 VARCHAR(10),
	@StreetName		 VARCHAR(50),
	@Postcode		 VARCHAR(5),
	@City			 VARCHAR(30),
	@State			 VARCHAR(3),
	@Country		 VARCHAR(30),
	@HashedPassword	 VARCHAR(256),
    @responseMessage VARCHAR(250) OUTPUT


AS
BEGIN
    SET NOCOUNT ON

	DECLARE @salt UNIQUEIDENTIFIER=NEWID()
    BEGIN TRY

        INSERT INTO Customer(fName, lName, ContactNumber, Email)
        VALUES(@fName, @lName, @ContactNumber, @Email)
		DECLARE	@ID int;
		set @ID = (select CustomerID from Customer WHERE Email = @Email);
		INSERT INTO CustomerAddress(CustomerID, StreetNum, StreetName, City, State, Postcode, Country)
        VALUES(@ID, @StreetNum, @StreetName,  @City, @State, @Postcode, @Country)
		INSERT INTO CustomerPassword(CustomerID,HashedPassword, Salt)
        VALUES(@ID, HASHBYTES('SHA2_256', @HashedPassword+CAST(@salt AS VARCHAR(36))), @salt)

        SET @responseMessage='Success'

    END TRY
    BEGIN CATCH
        SET @responseMessage=ERROR_MESSAGE() 
    END CATCH

END
GO

DECLARE @responseMessage VARCHAR(250)

EXEC dbo.uspAddUser

		@fName = 'Josh', 
		@lName = 'Brown', 
		@ContactNumber = '123456789',
		@Email = 'mr_123@hotmail.com',
		@StreetNum = '10',
		@StreetName	 = 'dad',
		@City = 'newy',
		@State = 'nsw',
		@Postcode = '2233',
		@Country = 'aust',
		@HashedPassword	= 'browny20323',
        @responseMessage=@responseMessage OUTPUT



























	@HashedPassword	VARCHAR(256),
    @responseMessage NVARCHAR(250) OUTPUT
SELECT * FROM CustomerPassword

DECLARE @responseMessage NVARCHAR(250)

EXEC dbo.uspAddUser
	@HashedPassword	= 'TempPassword',
    @responseMessage=@responseMessage OUTPUT




