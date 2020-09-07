sensorProps('<REDACTED>',
	    [
	     isa(doorWindowSensor),
	     hasLocation('<REDACTED>'),
	     hasName('<REDACTED>'),
	     verb(opened)
	    ]).


getSensorTypes(Types) :-
	setof(Type,ID^SensorProps^(sensorProps(ID,SensorProps),member(isa(Type),SensorProps)),Types).

determineProbabilitySensorIsUnresponsive(Frequency,Seconds,Probability) :-
	true.

getEstimatedMaximumPeriodicity(_,86400).

getAssertionForm(Name,Form) :-
	findall(ID,(sensorProps(ID,SensorProps),member(hasName(Name),SensorProps)),IDs),
	IDs = [ID],
	Form = sensed(sensorIDFn(ID),_).

%% getTimestampOnLastReportedSensingEvent(Name,Timestamp) :-
%% 	getAssertionForm(Name,Form),
%% 	findall(atTimeTmp(

%% detectMissingSensors(Results) :-
%% 	getSensorTypes(SensorTypes),
%% 	findall([Name,SensorProps,Frequency,Duration,Probability],
%% 		(   
%% 		    member(SensorType,SensorTypes),
%% 		    findall(Name,
%% 			    (	sensorProps(ID,SensorProps),member(isa(SensorType),SensorProps),member(hasName(Name),SensorProps)),
%% 			    Names),
%% 		    getTimestampOnLastReportedSensingEvent(Name,Timestamp),
%% 		    getEstimatedMaximumPeriodicity(Name,Frequency),
%% 		    getCurrentDateTime(Now),
%% 		    getDurationInSeconds(Timestamp,Now,Seconds),
%% 		    determineProbabilitySensorIsUnresponsive(Frequency,Seconds,Probability)
%% 		),
%% 		Results).

%% take into account how long the data has been being collected.

%% look into elog2 data to see if we have historical data on the sensors





%% detectMissingSensors(genericWirelessMotionSensor)

%% 

%% detect motion sensors
%% atTimeTmp(Date,sensed(X,motion)).

%% detect door sensors
%% atTimeTmp(Date,sensed(X,opened))

%% detect temperature sensors
%% atTimeTmp(Date,sensed(X,opened))

%% detect stale or off Owntracks GPS reporting
%% atTimeTmp(Date,location(X,geoCoordinates('55.5555555','-55.5555555')))
