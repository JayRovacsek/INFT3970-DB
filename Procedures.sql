/* DROPPING PROCS

DROP PROC dbo.AddUser
DROP PROC dbo.UserLogin
DROP PROC dbo.UpdatingUserPassword
DROP PROC dbo.AddSensor
DROP PROC dbo.ModifySensor
DROP PROC dbo.AddAdmin

*/

 /* Creating a new user */
CREATE PROC dbo.AddUser
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
    BEGIN
        INSERT INTO Users(fName, lName, ContactNumber, Email)
        VALUES(@fName, @lName, @ContactNumber, @Email)
		DECLARE	@ID int;
		set @ID = (select UserID from Users WHERE Email = @Email);
		INSERT INTO UsersAddress(UserID, StreetNum, StreetName, City, State, Postcode, Country)
        VALUES(@ID, @StreetNum, @StreetName, @City, @State, @Postcode, @Country)
		INSERT INTO UsersPassword(UserID, HashedPassword, Salt)
        VALUES(@ID, HASHBYTES('SHA2_256', @HashedPassword+CAST(@salt AS VARCHAR(64))), @salt)
        SET @responseMessage='Success'
    END 
END
GO

--Updating a users Password
CREATE PROC dbo.UpdatingUserPassword
	@Email			 VARCHAR(50),
	@Password		 VARCHAR(256),
    @responseMessage VARCHAR(250) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
	DECLARE @salt UNIQUEIDENTIFIER=NEWID()
	DECLARE	@ID int;
    BEGIN
		set @ID = (select UserID from Users WHERE Email = @Email);
		IF (@ID IS NULL)
			SET @responseMessage='Invalid email'
		ELSE
			UPDATE UsersPassword
			SET HashedPassword = (HASHBYTES('SHA2_256', @Password+CAST(@salt AS VARCHAR(64)))), Salt = @salt
			WHERE UserID = @ID
			SET @responseMessage='Success'
    END 
END
GO

--Updating a User to be an Admin
CREATE PROC dbo.AddAdmin
	@Email			 VARCHAR(50),
	@IsAdmin		 CHAR(1),
    @responseMessage VARCHAR(250) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
	DECLARE	@ID int;
    BEGIN
		set @ID = (select UserID from Users WHERE Email = @Email);
		IF (@ID IS NULL)
			SET @responseMessage='Invalid email'
		ELSE
			UPDATE Users
			SET isAdmin = @IsAdmin
			WHERE UserID = @ID
			SET @responseMessage='Success'
    END 
END
GO

--Logging in a user 
CREATE PROC dbo.UserLogin
	@Email			 VARCHAR(50),
	@Password		 VARCHAR(256),
	@responseMessage VARCHAR(250) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
	DECLARE @UserID INT
	DECLARE @Salt	VARCHAR(64)
    BEGIN
		SET @UserID = (SELECT UserID FROM Users WHERE email = @Email)
		SET @Salt = (SELECT Salt FROM UsersPassword WHERE UserID = @UserID)
		IF (@UserID IS NULL)
			SET @responseMessage='Invalid login Details'
		ELSE IF (HASHBYTES('SHA2_512', @Password+CAST(@Salt AS NVARCHAR(64)))) = (SELECT HashedPassword FROM UsersPassword WHERE @UserID = UserID)
			SET @responseMessage = 'Login Successful'
		ELSE
			SET @responseMessage = 'Wrong Password' 
	END
END
GO

--Creating a new sensor 
CREATE PROC dbo.AddSensor
	@UserID			 INT,
	@Name			 VARCHAR(50),
	@Description	 VARCHAR(200),
	@RoomID			 INT,
    @responseMessage VARCHAR(250) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    BEGIN
        INSERT INTO Sensor(UserID, Name, Description,RoomID)
        VALUES(@UserID, @Name, @Description, @RoomID)
        SET @responseMessage='Success'
    END 
END
GO

-- Modifying a Sensor
CREATE PROC dbo.ModifySensor
	@sensorID		 INT,
	@UserID			 INT,
	@Name			 VARCHAR(50),
	@Description	 VARCHAR(200),
	@RoomID			 INT,
	@responseMessage VARCHAR(250) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN	       
		UPDATE Sensor
		SET UserID = @UserID, Name = @Name, Description = @Description, RoomID = @RoomID
        WHERE sensorID = @SensorID
	END
END
GO





/* 
Running the Proc's
These are just example data being added to show that the proc's work, the real data will come from the front end/back end with user input,
so the data added will be variable names, not string input.
*/

-- executing the add user proc
DECLARE @responseMessage VARCHAR(250)

EXEC dbo.AddUser

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
GO

--executing the login proc
DECLARE @responseMessage VARCHAR(250)

EXEC dbo.UserLogin

	@Email = 'mr_123@hotmail.com',
	@Password = 'browny20323',	 
	@responseMessage=@responseMessage OUTPUT
GO

--Executing the Update password proc
DECLARE @responseMessage VARCHAR(250)

EXEC dbo.UpdatingUserPassword

	@Email	= 'mr_123@hotmail.com',
	@Password = 'Browny1',
	@responseMessage=@responseMessage OUTPUT
GO

--Executing the Adding Sensor proc
DECLARE @responseMessage VARCHAR(250)

EXEC dbo.AddSensor
	@UserID	='1',		 
	@Name = 'Sensor 1',
	@Description = 'This is the first sensor, being placed in the study room',
	@RoomID	= '2',
	@responseMessage=@responseMessage OUTPUT
GO

--Executing the Update Sensor proc
DECLARE @responseMessage VARCHAR(250)

EXEC dbo.ModifySensor
	@SensorID = '1',	
	@UserID	='1',		 
	@Name = 'Sensor 1',
	@Description = 'This is the first sensor, being placed in the Lounge Room',
	@RoomID	= '3',
	@responseMessage=@responseMessage OUTPUT
GO

--Executing the Add Admin proc
DECLARE @responseMessage VARCHAR(250)

EXEC dbo.AddAdmin
	@Email = 'mr_123@hotmail.com',
	@IsAdmin = 'Y',
	@responseMessage=@responseMessage OUTPUT
GO