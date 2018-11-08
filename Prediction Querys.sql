--sql query for obtaining Temperature predictions
declare @SearchEndTime datetime;
set @SearchEndTime = CURRENT_TIMESTAMP 
declare @SearchStartTime datetime;
set @SearchStartTime = DATEADD(week,-1,@SearchEndTime)

		SELECT StartTime, LAG(PredictedValue, 1, PredictedValue) OVER (ORDER BY StartTime) + (LAG(PredictedValue, 1, 0) OVER (ORDER BY StartTime) * (PercentChange)) as PredictedValue
		From 
			(
				SELECT HourlyAverage, StartTime,  PercentChange, ID, HourlyAverage as PredictedValue
				From
					(
						SELECT HourlyAverage, StartTime,- 1 * (1 - Lag(HourlyAverage, 1, 0) OVER (Order by StartTime) / HourlyAverage) AS PercentChange, ID, EndTime
						From
							(
								SELECT AVG(Temp) AS HourlyAverage, StartTime, ROW_NUMBER() OVER (ORDER BY StartTime) AS ID, EndTime
								FROM 
									(
										SELECT TempID, StartTime, Temp, StartTime + '00:59:59' AS EndTime
										FROM 
											(
												   SELECT TempID, DATEADD(hh,DATEDIFF(hh,0,t.[Date]),0) AS StartTime, Temp, s.SensorID
												   FROM Temperature t
												   INNER JOIN Sensor s ON  s.SensorID = t.SensorID
												   WHERE t.SensorID = 2 and  t.[Date] BETWEEN @SearchStartTime AND @SearchEndTime 
												   GROUP BY t.TempID, t.[Date], t.Temp, s.SensorID	  
											) 
											Temperature
											INNER JOIN Sensor s ON s.SensorID = Temperature.SensorId 
									  GROUP BY TempID, StartTime, Temp 
									)
									Temperature
								WHERE StartTime BETWEEN StartTime AND EndTime
								GROUP BY StartTime, EndTime
			
							)
							Temperature
							WHERE StartTime BETWEEN StartTime AND EndTime
							Group By HourlyAverage, StartTime, ID, EndTime
					)			
					Temperature
					GROUP BY HourlyAverage, StartTime, PercentChange, ID
					
			)
			Temperature
			Order by StartTime

				
---- sql query for obtaing humidity predictions
declare @SearchEndTime datetime;
set @SearchEndTime = CURRENT_TIMESTAMP 
declare @SearchStartTime datetime;
set @SearchStartTime = DATEADD(week,-1,@SearchEndTime)

		SELECT StartTime, LAG(PredictedValue, 1, PredictedValue) OVER (ORDER BY StartTime) + (LAG(PredictedValue, 1, 0) OVER (ORDER BY StartTime) * (PercentChange)) as PredictedValue
		From 
			(
				SELECT HourlyAverage, StartTime,  PercentChange, ID, HourlyAverage as PredictedValue
				From
					(
						SELECT HourlyAverage, StartTime,- 1 * (1 - Lag(HourlyAverage, 1, 0) OVER (Order by StartTime) / HourlyAverage) AS PercentChange, ID, EndTime
						From
							(
								SELECT AVG(Humidity) AS HourlyAverage, StartTime, ROW_NUMBER() OVER (ORDER BY StartTime) AS ID, EndTime
									FROM
										(
											SELECT HumidityID, StartTime, Humidity, StartTime + '00:59:59' AS EndTime
											FROM 
												(
													SELECT HumidityID, DATEADD(hh,DATEDIFF(hh,0,h.[Date]),0) AS StartTime, Humidity, s.SensorID
													FROM Humidity h
													INNER JOIN Sensor s ON  s.SensorID = h.SensorID
													WHERE h.SensorID = 2 and  h.[Date] BETWEEN @SearchStartTime AND @SearchEndTime 
													GROUP BY h.HumidityID, h.[Date], h.Humidity, s.SensorID	  
												)	 
												Humidity
												INNER JOIN Sensor s ON s.SensorID = Humidity.SensorId 
												GROUP BY HumidityID, StartTime, Humidity
								)
								Humidity
								WHERE StartTime BETWEEN StartTime AND EndTime
								GROUP BY StartTime, EndTime
						)
						Humidity
						WHERE StartTime BETWEEN StartTime AND EndTime
						Group By HourlyAverage, StartTime, ID, EndTime
				)			
				Humidity
				GROUP BY HourlyAverage, StartTime, PercentChange, ID
					
			)
			Humidity
			Order by StartTime
		
		

