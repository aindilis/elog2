#!/usr/bin/perl -w

use KBS2::Client;
use KBS2::ImportExport;
use KBS2::Util;
use PerlLib::SwissArmyKnife;

# KBS2;

my $client = KBS2::Client->new
  (
   Context => 'Org::FRDCSA::SensorNetwork',
  );

print Dumper
  ($client->MyAgent->QueryAgent
   (
    Receiver => 'KBS2',
    Data => {
	     _DoNotLog => 1,
	     Database => 'elog2',
	     Command => 'assert',
	     Context => 'Org::FRDCSA::SensorNetwork',
	     Formula => ['isa','andrewDougherty','person'],
	    },
   ));

print Dumper
  ($client->MyAgent->QueryAgent
   (
    Receiver => 'KBS2',
    Data => {
	     _DoNotLog => 1,
	     Database => 'elog2',
	     Command => 'assert',
	     Context => 'Org::FRDCSA::SensorNetwork',
	     Formula => ['isa','<REDACTED>','person'],
	    },
   ));

my $res1 = $client->MyAgent->QueryAgent
  (
   Receiver => 'KBS2',
   Data => {
	    Command => 'query',
	    Database => 'elog2',
	    Context => 'Org::FRDCSA::SensorNetwork',
	    Formula => ['isa',Var('?X'),Var('?Y')],
	    _DoNotLog => 1,
	   },
  );
print Dumper($res1);

my $res1 = $client->MyAgent->QueryAgent
  (
   Receiver => 'KBS2',
   Data => {
	    Command => 'get-id',
	    Database => 'elog2',
	    Context => 'Org::FRDCSA::SensorNetwork',
	    Formula => ['isa','<REDACTED>','person'],
	    _DoNotLog => 1,
	   },
  );
print Dumper($res1);
