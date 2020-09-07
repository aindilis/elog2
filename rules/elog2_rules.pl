%% performAction(DateTime,addToPendingTasks(soundAlarm)) :-
%% 	once(atTimeTmp(DateTime,sensed('<REDACTED>',opened))).

performAction(DateTime,Assertion,addToPendingTasks(logScore(['_perl_hash','AgentID',1,'Event','sensed(<REDACTED>,opened)','Quality',Quality,'Score',Score,'Count',1]))) :-
	view([1]),
	Assertion = atTimeTmp(DateTime,Action),
	Action = sensed('<REDACTED>',opened),
	view([2]),
	once(atTimeTmp(DateTime,Action)),
	view([3,Action]),
	(   DateTime = [Y-M-D,(H:Mi):S] -> NewDateTime = [Y-M-D,H:Mi:S] ; NewDateTime = DateTime),
	view([checkPermission,checkPermission(NewDateTime,Action,Result)]),
	checkPermission(NewDateTime,Action,Result),
	view([4,Result]),
	(   Result = yes -> (Score = -25.0, Quality = bad) ; (Score = -100.0, Quality = bad) ).

performAction(DateTime,Assertion,addToPendingTasks(soundAlarm(DateTime,Assertion))) :-
	once(   
		(   
		    Assertion = sensed('<REDACTED>',motion) ;
		    Assertion = sensed('<REDACTED>',opened)
		) ->
		(   
		    awayFromHome(andrewDougherty) ->
		    true ;
		    fail
		) ;
		fail
	    ).
