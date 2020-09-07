atTime([Y-M-D,H:Mi:S],X) :-
	atTimeTmp([Y-M-D,(H:Mi):S],X).

inLastNSeconds(N,Query) :-
	getCurrentDateTime(DateTime),
	julian:delta_time(TmpPreviousDateTime,s(N),DateTime),
	form_time([TmpPreviousDateTime,[Year-Month-DOM,Hour:Minute:TmpSecond]]),
	Second is round(TmpSecond),
	PreviousDateTime = [Year-Month-DOM,Hour:Minute:Second],
	view([previousDateTime,PreviousDateTime]),
	findall(X,(atTime(X,Query),view([x,X]),julian:compare_time(>,X,PreviousDateTime)),Xs),
	view([xs,Xs]),
	length(Xs,L),
	L > 0.

test111(Result) :-
	hasTruthValue(inLastNSeconds(60,sensed(_,_)),Result).

distance(Lat1, Lon1, Lat2, Lon2, Dis):-
	P is 0.017453292519943295,
	A is (0.5 - cos((Lat2 - Lat1) * P) / 2 + cos(Lat1 * P) * cos(Lat2 * P) * (1 - cos((Lon2 - Lon1) * P)) / 2),
	Dis is (12742 * asin(sqrt(A))).

distanceFromHome(Lat,Lon,Distance) :-
	atom_number(Lat,NLat),
	atom_number(Lon,NLon),
	distance(55.5555555,-55.5555555,NLat,NLon,DistanceKM),
	Distance is 0.621371 * DistanceKM.

functionalInArgs(location/2,2).

awayFromHome(Person) :-
	findall(Y,atTime(X,location(Person,Y)),Ys),
	view([ys,Ys]),
	reverse(Ys,RYs),
	view([rys,RYs]),
	nth1(1,RYs,geoCoordinates(Lat,Lon)),
	view([lat,Lat,lon,Lon]),
	distanceFromHome(Lat,Lon,Distance),
	view([distance,Distance]),
	Distance > 0.10.

%% checkSecurity :-
%% 	sensed('<REDACTED>',motion).

checkPermission(DateTime,Event,Result) :-
	query_agent(flp,'localhost',checkPermission(DateTime,Event,_Permission),Result1),
	Result1 = [checkPermission(DateTime,Event,Result)].

%% logScore(List) :-
%% 	view([running,logScore(List)]),
%% 	%% query_agent(flp,'localhost',logScore(List),Result1),
%% 	view([result1,Result1]).
	
logScore(List) :-
	AgentName = 'ELog2-Agent1',
	FormalogName = 'ELog2-Yaswi1',
	connectToUniLang(AgentName,FormalogName,Connection),
	queryAgentPerl(AgentName,FormalogName,'Manager','',['_perl_hash','QueryAgent',1,'Command','record-event','EventArgs',List],Result),
	view([result,Result]).

%% logScore(['_perl_hash','AgentID',1,'Event','sensed(<REDACTED>,opened)','Quality',bad,'Score',-50.0,'Count',1]).

soundAlarm(DateTime,Assertion) :-
	true.