:- dynamic prolog_files/2.
:- dynamic prolog_files/3.

:- dynamic md/2, possible/1, atTime/2.
:- multifile genlsDirectlyList/2, performAction/1, viewIf/1.
:- discontiguous are/2, isa/2.

%% %% swipl -G100g -T20g -L2g

%% %% is same as:

%% :- set_prolog_stack(global, limit(100 000 000 000)).
%% :- set_prolog_stack(trail,  limit(20 000 000 000)).
%% :- set_prolog_stack(local,  limit(2 000 000 000)).

:- set_prolog_stack(global, limit(1 000 000 000)).
:- set_prolog_stack(trail,  limit(200 000 000)).
:- set_prolog_stack(local,  limit(20 000 000)).

:- use_module(library(make)).
:- use_module(library(listing)).

:- module(user).

%% see also /var/lib/myfrdcsa/codebases/minor/free-life-planner/free_life_planner.pl
:- assert(prolog_files(elog2Formalog,'/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util.pl')).
:- consult('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util.pl').

:- prolog_consult('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/multifile-and-dynamic-directives.pl').
:- prolog_consult('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/calendaring/calendaring-new.pl').

:- prolog_consult('/var/lib/myfrdcsa/codebases/minor/dates/frdcsa/sys/flp/autoload/dates.pl').

:- prolog_consult('/var/lib/myfrdcsa/codebases/minor/elog2/elog2_helper.pl').
:- prolog_consult('/var/lib/myfrdcsa/codebases/minor/elog2/elog2_logic.pl').
:- prolog_consult('/var/lib/myfrdcsa/codebases/minor/elog2/elog2_missing.pl').

:- prolog_consult('/var/lib/myfrdcsa/sandbox/rtec-swi-20190114/rtec-swi-20190114/frdcsa.pl').
:- prolog_consult('/var/lib/myfrdcsa/codebases/minor/interactive-execution-monitor/frdcsa/sys/flp/autoload/at_time.pl').

:- prolog_consult('/var/lib/myfrdcsa/codebases/minor/elog2/rules/elog2_rules.pl').
:- prolog_consult('/var/lib/myfrdcsa/codebases/minor/location-logic/rules/ll-rules.pl').

:- prolog_consult('/var/lib/myfrdcsa/codebases/minor/formalog-pengines/formalog_pengines/formalog_pengines_client').
:- prolog_consult('/var/lib/myfrdcsa/codebases/minor/formalog-pengines/formalog_pengines/formalog_pengines_server').
:- start_agent(eLog2).

eLog2Flag(not(debug)).

viewIf(Item) :-
 	(   eLog2Flag(debug) -> 
	    view(Item) ;
	    true).

testELog2 :-
	true.
	
:- log_message('DONE LOADING ELOG2.').
formalogModuleLoaded(eLog2).

