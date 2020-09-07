checkPermission(DateTime,sensed('<REDACTED>',opened),Result) :-
	julian:delta_time(NowMinusInterval,s(600),DateTime),
	(   holdsAtLeastOnceDuringInclusive(NowMinusInterval,DateTime,hasPermission(andrewDougherty,'<REDACTED>')) -> (Result = yes) ; (Result = no)).

%% for now just make it simple.

%% hasTruthValue(requestPermissionTo(andrewDougherty,[2020-07-16,12:55:02],'<REDACTED>'),X).

requestPermissionTo(Agent,Now,COA) :-
	%% check if we've received permission to leave in the last 10
	%% minutes (make this variable)
	getFLUXPlan([playing_movie('<REDACTED>')],Plan),
	view([plan,Plan]),
	nonvar(Plan),
	fassert('Agent1','Yaswi1',atTime(Now,hasPermission(Agent,COA)),Result).
