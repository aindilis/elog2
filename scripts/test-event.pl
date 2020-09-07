#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use UniLang::Util::TempAgent;

my $agent = UniLang::Util::TempAgent->new();

my $res1 = $agent->MyAgent->QueryAgent
  (
   Receiver => 'ELog2',
   Contents => '',
   Data => {
	    Assert => ['test','event'],
	    # Start => '2019-01-03 01:14:38',
	    # End => '2019-01-03 01:14:42',
	   },
  );
print Dumper({Res1 => $res1});
