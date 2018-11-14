
/* These drop each of the different Procedures from the database

DROP PROC dbo.AddUser
DROP PROC dbo.UserLogin
DROP PROC dbo.UpdatingUserPassword
DROP PROC dbo.AddSensor
DROP PROC dbo.ModifySensor
DROP PROC dbo.AddAdmin
DROP PROC dbo.AddRoom
DROP PROC dbo.UpdateUser
Drop Proc dbo.AverageTemp
Drop Proc dbo.MotionCount

*/

/* This Proc creates a new user into the database
all the required information is gathered from the webpage and then this Proc is run to insert it into the database
It first inserts into the User and UserAddress table, then changes the password given to be salted and hashed before being saved into the database
The User's unencrypted password is never saved into the database for security 
*/
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

/* This Proc Changes a User or Admins password and changes it in the database
It first checks to see if the email address provided matches any in the database, if not it will display an error.
If the email address is in the database, This Proc takes the new password and salt's and hashes it before saving it into the database
*/
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

--This Proc Changes a User to be an admin
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

/* This Proc Log's in a User to the website
It checks to see if the email provided is in the database,
if so, it salts and hashes the password given and checks to see if its the same as the password in the database,
if so, it logs the user in.
*/
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

--This Proc Add's a new Sensor to the database
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

--This Proc Add's a new Room to the database
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

--This Proc Modifies a Sensor's details in the database
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

--This Proc Modifies a User's details in the database
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


-- AVERAGE TEMP HOURS
CREATE PROC dbo.AverageTemp
	@SensorID			INT,
	@SearchStartTime	DateTime,
	@SearchEndTime		DateTime 

AS
BEGIN

	SELECT AVG(Temp) AS HourlyAverage, StartTime, EndTime
	FROM (
		SELECT TempID, StartTime, Temp, StartTime + '00:59:59' AS EndTime
		   FROM (
				 SELECT TempID, DATEADD(hh,DATEDIFF(hh,0,t.[Date]),0) AS StartTime, Temp, s.SensorID
				   FROM Temperature t
				   INNER JOIN Sensor s ON  s.SensorID = t.SensorID
				   WHERE s.SensorID = @SensorID AND t.[Date] BETWEEN @SearchStartTime AND @SearchEndTime 
				   GROUP BY t.TempID, t.[Date], t.Temp, s.SensorID	  
				) 
				Temperature
				INNER JOIN Sensor s ON s.SensorID = Temperature.SensorId 
		  GROUP BY TempID, StartTime, Temp 
		)
		Temperature
	WHERE StartTime BETWEEN StartTime AND EndTime
	GROUP BY StartTime, EndTime
	ORDER BY EndTime
END 

EXEC dbo.AverageTemp
	@SensorID = 2,
	@SearchStartTime = '2018-10-02',
	@SearchEndTime = '2018/10/03'
GO


-- average Humidity hours
CREATE PROC dbo.AverageHumidity
	@SensorID			INT,
	@SearchStartTime	DateTime,
	@SearchEndTime		DateTime 
AS
BEGIN
	SELECT AVG(Humidity) AS HourlyAverage, StartTime, EndTime	FROM (
		SELECT HumidityID, StartTime, Humidity, StartTime + '00:59:59' AS EndTime		   FROM (
				 SELECT HumidityID, DATEADD(hh,DATEDIFF(hh,0,t.[Date]),0) AS StartTime, Humidity, s.SensorID, s.UserID
				   FROM Humidity t
				   INNER JOIN Sensor s ON  s.SensorID = t.SensorID
				   WHERE s.SensorID = @SensorID AND t.[Date] BETWEEN @SearchStartTime AND @SearchEndTime 
				   GROUP BY t.HumidityID, t.[Date], t.Humidity, s.SensorID, s.UserID		  
				) 
				Humidity				INNER JOIN Sensor s ON s.SensorID = Humidity.SensorId 
		  GROUP BY HumidityID, StartTime, Humidity 
		)
		Humidity
	WHERE StartTime BETWEEN StartTime AND EndTime
	GROUP BY StartTime, EndTime
	ORDER BY EndTime
END 

-- Count of motion per hour
CREATE PROC dbo.MotionCount
	@SensorID			INT,
	@SearchStartTime	DateTime,
	@SearchEndTime		DateTime
AS
BEGIN
	SELECT Count(Motion) AS HourlyCount, StartTime, EndTime
	FROM (
		SELECT MotionID, StartTime, Motion, StartTime + '00:59:59' AS EndTime
		   FROM (
				 SELECT MotionID, DATEADD(hh,DATEDIFF(hh,0,m.[Date]),0) AS StartTime, Motion, s.SensorID, s.UserID
				   FROM Motion m
				   INNER JOIN Sensor s ON  s.SensorID = m.SensorID
				   WHERE s.SensorID = @SensorID AND m.[Date] BETWEEN @SearchStartTime and @SearchEndTime 
				   GROUP BY m.MotionID, m.[Date], m.Motion, s.SensorID, s.UserID		  
				) 
				Motion
				INNER JOIN Sensor s ON s.SensorID = Motion.SensorId 
		  GROUP BY MotionID, StartTime, Motion 
		)
		Motion
	WHERE StartTime between StartTime and EndTime
	GROUP BY StartTime, EndTime
	ORDER BY EndTime
END 