processTriggersForAssertions(Assertion,Results) :-
	assertAndGetResults(Assertion,Results),
	forall(member(addToPendingTasks(Action),Results),
	       (   
		   view([doingAction,Action]),
		   (   call(Action) -> true ; true)
	       )).

assertAndGetResults(Assertion,Results) :-
	assert(Assertion),
	Assertion = atTimeTmp(Date,Fact),
	view([date,Date]),
	findall(Action,performAction(Date,Assertion,Action),Results1),
	findall(Action,performAction(Date,Action),Results2),
	append(Results1,Results2,Results),
	view([results,Results]).

testDoorOpen :-
	getCurrentDateTime(Now),
	assertAndGetResults(atTimeTmp(Now,sensed('<REDACTED>',opened)),Results),
	view([results,Results]).