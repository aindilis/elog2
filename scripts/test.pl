#!/usr/bin/perl -w

use UniLang::Util::TempAgent;

use Data::Dumper;

my $tempagent = UniLang::Util::TempAgent->new();
my $res1 = $tempagent->MyAgent->QueryAgent
  (
   "Contents" => "",
   "Data" => [
	      "QueryAgent",
	      1,
	      "Command",
	      "record-event",
	      "EventArgs",
	      [
	       "AgentID",
	       1,
	       "Event",
	       "sensed('<REDACTED>',opened)",
	       "Quality",
	       "bad",
	       "Score",
	       49,
	       "Count",
	       1
	      ]
	     ],
   "Receiver" => "Manager"
  );

print Dumper($res1);
