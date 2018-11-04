
/* DROPPING PROCS
DROP PROC dbo.AddUser
DROP PROC dbo.UserLogin
DROP PROC dbo.UpdatingUserPassword
DROP PROC dbo.AddSensor
DROP PROC dbo.ModifySensor
DROP PROC dbo.AddAdmin
DROP PROC dbo.AddRoom
DROP PROC dbo.UpdateUser
Drop Proc dbo.AverageTemp
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
	@responseMessage VARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
	DECLARE @UserID INT
	DECLARE @Salt	VARCHAR(64)
	DECLARE @SaltedPassword VARBINARY(64)
    BEGIN
		SET @UserID = (SELECT UserID FROM Users WHERE  Email = @Email)
		SET @Salt = (SELECT Salt FROM UsersPassword WHERE UserID = @UserID)
		SET @SaltedPassword = HASHBYTES('SHA2_256', @Password+CAST(@Salt AS VARCHAR(64)))
		IF  @SaltedPassword = (SELECT HashedPassword FROM UsersPassword WHERE @UserID = UserID)
			SET @responseMessage = 1
		ELSE
			SET @responseMessage = 0 
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

--Creating a new Room
CREATE PROC dbo.AddRoom
	@Name			 VARCHAR(50),
	@Description	 VARCHAR(200),
    @responseMessage VARCHAR(250) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
	DECLARE	@NewRoomID	INT
    BEGIN
		SET @NewRoomID = (SELECT COUNT(RoomID) FROM Room) + 1
        INSERT INTO Room(RoomID,Name, Description)
        VALUES(@NewRoomID, @Name, @Description)
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

-- Update User Details 
CREATE PROC dbo.UpdateUser
	@UserID			 INT,
	@fName			 VARCHAR(40), 
    @lName			 VARCHAR(40), 
	@ContactNumber	 VARCHAR(10),
	@StreetNum		 VARCHAR(10),
	@StreetName		 VARCHAR(50),
	@Postcode		 VARCHAR(5),
	@City			 VARCHAR(30),
	@State			 VARCHAR(3),
	@Country		 VARCHAR(30),
    @responseMessage VARCHAR(250) OUTPUT
AS
BEGIN
    SET NOCOUNT ON
    BEGIN
		UPDATE Users
		SET fName = @fName, lName = @lName, ContactNumber = @ContactNumber
		WHERE UserID = @UserID
		UPDATE UsersAddress
		SET StreetNum = @StreetNum, StreetName = @StreetName, City = @city, State = @State, Postcode = @Postcode, Country = @Country
		WHERE UserID = @UserID
        SET @responseMessage='Success'
    END 
END
GO

drop proc dbo.Average 

-- averaging scores
CREATE PROC dbo.Average
	@Hours				INT,
	@SensorId			INT,
	@UserId				INT,
	@responseMessage	VARCHAR(250) OUTPUT

AS 
BEGIN
	Select * 
	From Temperature t
	INNER JOIN Sensor s on s.SensorID = t.SensorID
	WHERE s.CustomerID = @UserId and t.Date >= (Current_TimeStamp - @Hours)
END



CREATE PROC dbo.Average
	@Hours				INT,
	@receiptId			INT,
	@UserId				VARCHAR,
	@responseMessage	VARCHAR(250) OUTPUT

AS 
BEGIN
	Select * 
	From Receipt r
	INNER JOIN ReceiptItem ri on ri.ReceiptId = r.ReceiptId
	WHERE r.ReceiptCustomerId = @UserId --and r.ReceiptDate >= (Current_TimeStamp - @Hours)
END


-- average temp hours
CREATE PROC dbo.AverageTemp
	@UserID				INT NOT NULL,
	@SensorID			INT NOT NULL,
	@SearchStartTime	DateTime NOT NULL,
	@SearchEndTime		DateTime NULL 

AS
Begin
	IF @SearchEndTime IS NULL 

	SELECT AVG(Temp) AS HourlyAverage, StartTime, EndTime
	From (
		SELECT TempID, StartTime, Temp, StartTime + '00:59:59' AS EndTime
		   FROM (
				 SELECT TempID, DATEADD(hh,DATEDIFF(hh,0,t.[Date]),0) AS StartTime, Temp, s.SensorID, s.UserID
				   FROM Temperature t
				   INNER JOIN Sensor s on  s.SensorID = t.SensorID
				   Where s.SensorID = @SensorID and t.[Date] between @SearchStartTime and @SearchEndTime 
				   Group By t.TempID, t.[Date], t.Temp, s.SensorID, s.UserID		  
				) 
				Temperature
				INNER JOIN Sensor s on s.SensorID = Temperature.SensorId 
		  GROUP BY TempID, StartTime, Temp 
		)
		Temperature
	Where StartTime between StartTime and EndTime
	Group BY StartTime, EndTime
	Order By EndTime
End 


-- average Humidity hours
CREATE PROC dbo.AverageHumidity
	@UserID				INT NOT NULL,
	@SensorID			INT NOT NULL,
	@SearchStartTime	DateTime NOT NULL,
	@SearchEndTime		DateTime NULL 

AS
Begin
	IF @SearchEndTime IS NULL 

	SELECT AVG(Humidity) AS HourlyAverage, StartTime, EndTime
	From (
		SELECT HumidityID, StartTime, Humidity, StartTime + '00:59:59' AS EndTime
		   FROM (
				 SELECT HumidityID, DATEADD(hh,DATEDIFF(hh,0,t.[Date]),0) AS StartTime, Humidity, s.SensorID, s.UserID
				   FROM Humidity t
				   INNER JOIN Sensor s on  s.SensorID = t.SensorID
				   Where s.SensorID = @SensorID and t.[Date] between @SearchStartTime and @SearchEndTime 
				   Group By t.HumidityID, t.[Date], t.Humidity, s.SensorID, s.UserID		  
				) 
				Humidity
				INNER JOIN Sensor s on s.SensorID = Humidity.SensorId 
		  GROUP BY HumidityID, StartTime, Humidity 
		)
		Humidity
	Where StartTime between StartTime and EndTime
	Group BY StartTime, EndTime
	Order By EndTime
End 



/* 
Running the Proc's
These are just example data being added to show that the proc's work, the real data will come from the front end/back end with user input,
so the data added will be variable names, not string input.
*/

--test average temp hours
Exec dbo.AverageTemp
	@UserID = 2,
	@SensorID = 2,
	@SearchStartTime = '2018-10-02',
	@SearchEndTime = '2018/10/03'
go

--test average Humidity hours
Exec dbo.AverageHumidity
	@UserID = 2,
	@SensorID = 2,
	@SearchStartTime = '2018-10-02',
	@SearchEndTime = '2018/10/03'
go


declare @responseMessage VARCHAR(250)

exec dbo.Average
	
		@Hours = 2,
		@receiptId = 100001,
		@UserId = 'c76',
		--@responseMessage=@responseMessage OUTPUT
GO

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

	@Email	= 'Browny@hotmail.com',
	@Password = '1234',
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