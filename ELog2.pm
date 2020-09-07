package ELog2;

use BOSS::Config;
use KBS2::ImportExport;
use KBS2::Util;
use MyFRDCSA;
use PerlLib::MySQL;
use PerlLib::SwissArmyKnife;

use Data::Compare;
use Date::Parse;
use DateTime;
use Clone qw(clone);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config Database MyMySQL Seen MyImportExport /

  ];

# $UNIVERSAL::debug = 1;

sub init {
  my ($self,%args) = @_;
  $specification = "
	-u [<host> <port>]	Run as a UniLang agent
	-w			Require user input before exiting
";
  $UNIVERSAL::systemdir = ConcatDir(Dir("minor codebases"),"elog2");
  $UNIVERSAL::agent->DoNotDaemonize(1);
  $self->Config(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $UNIVERSAL::agent->Register
      (Host => defined $conf->{-u}->{'<host>'} ?
       $conf->{-u}->{'<host>'} : "localhost",
       Port => defined $conf->{-u}->{'<port>'} ?
       $conf->{-u}->{'<port>'} : "9000");
  }
  $self->Database('elog2');
  $self->MyMySQL
    (PerlLib::MySQL->new
     (DBName => $self->Database));
  $self->MyImportExport(KBS2::ImportExport->new());
  $self->Seen({});
}

sub Execute {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    # enter in to a listening loop
    while (1) {
      $UNIVERSAL::agent->Listen(TimeOut => 10);
    }
  }
  if (exists $conf->{'-w'}) {
    Message(Message => "Press any key to quit...");
    my $t = <STDIN>;
  }
}

sub ProcessMessage {
  my ($self,%args) = @_;
  my $m = $args{Message};
  my $it = $m->Contents;
  my $data = $m->Data;
  print Dumper({Data => $data});
  if ($it =~ /^(quit|exit)$/i) {
    $UNIVERSAL::agent->Deregister;
    exit(0);
  } elsif (exists $data->{Assert}) {
    my $formulaid;
    if ($self->Seen->{Dumper([$data->{Assert},$data->{Context}])}) {
      print "Seen before, reusing formulaid\n" if $UNIVERSAL::debug;
      $formulaid = $self->Seen->{Dumper([$data->{Assert},$data->{Context}])};
    } else {
      my $res1 = $UNIVERSAL::agent->QueryAgent
	(
	 Receiver => 'KBS2',
	 Data => {
		  Command => 'get-id',
		  Database => $self->Database,
		  Context => $data->{Context} || 'Org::FRDCSA::SensorNetwork',
		  Formula => $data->{Assert},
		  _DoNotLog => 1,
		 },
	);
      print Dumper({FormulaID => $res1});
      if (scalar @{$res1->{Data}{Result}}) {
	$formulaid = $res1->{Data}{Result}[0];
	$self->Seen->{Dumper([$data->{Assert},$data->{Context}])} = $formulaid;
      }
    }
    if (! $formulaid) {
      my $res2 = $UNIVERSAL::agent->QueryAgent
	(
	 Receiver => 'KBS2',
	 Data => {
		  _DoNotLog => 1,
		  Database => $self->Database,
		  Command => 'assert',
		  Context => $data->{Context} || 'Org::FRDCSA::SensorNetwork',
		  Formula => $data->{Assert},
		 },
	);
      my $res3 = $UNIVERSAL::agent->QueryAgent
	(
	 Receiver => 'KBS2',
	 Data => {
		  Command => 'get-id',
		  Database => $self->Database,
		  Context => $data->{Context} || 'Org::FRDCSA::SensorNetwork',
		  Formula => $data->{Assert},
		  _DoNotLog => 1,
		 },
	);
      if (scalar @{$res3->{Data}{Result}}) {
	$formulaid = $res3->{Data}{Result}[0];
	$self->Seen->{Dumper([$data->{Assert},$data->{Context}])} = $formulaid;
      } else {

      }
    }
    if ($formulaid) {
      my $s1 = "select ID from metadata where FormulaID = $formulaid;";
      my $res4 = $self->MyMySQL->Do
	(
	 Statement => $s1,
	 Array => 1,
	);
      my $metadataid = $res4->[0][0];
      if ($metadataid) {
	my $s2 = "insert into events values (NULL,".
	  $self->MyMySQL->Quote($m->Sender).",".
	  $self->MyMySQL->Quote($m->Receiver).",".
	  "NOW(),".
	  (defined $data->{Start} ? $self->MyMySQL->Quote($data->{Start}) : 'NULL').",".
	  (defined $data->{End} ? $self->MyMySQL->Quote($data->{End}) : 'NULL').",".
	  $self->MyMySQL->Quote($metadataid).");";
	print "<<<$s2>>>\n";
	my $res5 = $self->MyMySQL->Do
	  (
	   Statement => $s2,
	  );
	$self->EventCallback
	  (
	   Message => $m,
	   ELog2Formalog => $args{ELog2Formalog},
	  );
	$UNIVERSAL::agent->QueryAgentReply
	  (
	   Message => $m,
	   Data => {
		    Success => 1,
		    Result => $metadataid,
		   },
	  );

	return;
      }
    }
    $UNIVERSAL::agent->QueryAgentReply
      (
       Message => $m,
       Data => {
		Success => 0,
	       },
      );
  }
}

sub EventCallback {
  my ($self,%args) = @_;
  my $m = $args{Message};
  my $data = $m->Data;
  if (defined $data->{Assert}) {
    if (! (Compare($data->{Assert},['sensed','<REDACTED>','motion']) or
	   Compare($data->{Assert},['sensed','<REDACTED>','motion']) or
	   Compare($data->{Assert},['sensed','<REDACTED>','motion']) or
	   $data->{Assert}[2][0] eq 'temperatureFn')) {
      my $res1 = $self->ConvertAssertionToText
	(
	 Formula => $data->{Assert},
	);
      if ($res1->{Success}) {
	$self->Say
	  (
	   Recipient => 'WorkTunes',
	   Text => $res1->{Result},
	  );
      }
    }
    # if (Compare($data->{Assert},['sensed','<REDACTED>','opened'])) {
    #   my $results = $UNIVERSAL::agent->QueryAgent
    # 	(
    # 	 Receiver => 'Manager',
    # 	 Data => {
    # 		  Command => 'record-event',
    # 		  EventArgs => {
    # 				AgentID => 1,
    # 				Event => 'sensed(<REDACTED>,opened)',
    # 				Quality => 'bad',
    # 				Score => -10,
    # 				Count => 1,
    # 			       },
    # 		  _DoNotLog => 1,
    # 		 },
    # 	);
    # }
    if (Compare($data->{Assert},['sensed','<REDACTED>','problem'])) {
      # send a message to the user
      my $results = $self->Query
    	(
    	 Eval => [
    		  ['_prolog_list',
    		   Var('?Result'),
    		   ['tellAndSendInstantMessageToAgent','andrewDougherty',['_prolog_list','alarm: <REDACTED> needs attention'],Var('?Result')],
    		  ],
    		 ],
    	);
    }
    if (Compare($data->{Assert},['sensed','<REDACTED>','<REDACTED>'])) {
      # send a message to the user
      my $results = $self->Query
	(
	 Eval => [
		  ['_prolog_list',
		   Var('?Result'),
		   ['tellAndSendInstantMessageToAgent','andrewDougherty',['_prolog_list','<REDACTED>'],Var('?Result')],
		  ],
		 ],
	);
    }
    if (1 or $args{ELog2Formalog}) {
      # send a message asserting this into the KB
      my $timestamp;
      if ($data->{Start} !~ /^(\d{4})-(\d{1,2})-(\d{1,2}) (\d{1,2}):(\d{1,2}):(\d{1,2})$/) {
	$data->{Start} = `date "+%Y-%m-%d %H:%M:%S"`;
      }
      if ($data->{Start} =~ /^(\d{4})-0?(\d{1,2})-0?(\d{1,2}) 0?(\d{1,2}):0?(\d{1,2}):0?(\d{1,2})$/) {
	$timestamp = ['_prolog_list',['-',['-',int($1),int($2)],int($3)],[':',[':',int($4),int($5)],int($6)]];
      } else {
	  print "ERROR: Date not parsing\n";
      }
      my $interlingua = ['processTriggersForAssertions',['atTimeTmp',$timestamp,$data->{Assert}],Var('?Results')];
      # my $interlingua = ['assert',['atTime',$timestamp,$data->{Assert}]];
      my $variables = ListVariablesInFormula(Formula => $interlingua);
      unshift @$variables, '_prolog_list';
      my $query = [['_prolog_list',$variables,$interlingua]];
      # print Dumper({Query => $query});
      my $res2 = $UNIVERSAL::agent->QueryAgent
	(
	 Receiver => $conf->{'-a'} || "ELog2-Agent1",
	 Data => {
		  _DoNotLog => 1,
		  Eval => $query,
		 },
	);
      print Dumper({Res2 => $res2}) if $UNIVERSAL::debug;
      shift @$variables;
      my $assertions = $res2->{Data}{Result};
      my $cleardumper = ClearDumper({StartReplAssertions => $assertions});
      my @cleardumper = split /\n/, $cleardumper;
      if (scalar @cleardumper < 1000) {
	print $cleardumper if $UNIVERSAL::debug;
      }
      foreach my $assertion (@$assertions) {
	# print Dumper({Assertion => $assertion});
	my $ref = ref($assertion);
	if ($ref eq 'ARRAY') {
	  shift @$assertion;
	  my $i = 0;
	  while (defined $variables->[$i] and
		 defined $assertion->[$i]) {
	    my $clone = clone($assertion->[$i]);
	    my $res3 = $self->MyImportExport->Convert
	      (
	       Input => [$clone],
	       InputType => 'Interlingua',
	       OutputType => 'Prolog',
	      );
	    my @res;
	    my $var = TermIsVariable($variables->[$i]);
	    if ($res3->{Success}) {
	      my $output = $res3->{Output};
	      chomp $output;
	      push @res, [$var, $output];
	    } else {
	      push @res, [$var, "---ERROR---"];
	    }
	    my $it = $res[0];
	    print $it->[0]." = ".$it->[1]."\n";
	    print Dumper({Command => $assertion->[$i]});
	    if ($assertion->[$i][1][0] eq 'addToPendingTasks') {
	      # $assertion->[$i][1][1]
	    }
	    ++$i;
	  }
	}
	print "\n";
      }
    }
  }
}

sub Query {
  my ($self,%args) = @_;
  my @items;
  print "okay\n";
  my $res1 = $UNIVERSAL::agent->QueryAgent
    (
     Receiver => 'Agent1',
     Data => {
	      Eval => $args{Eval},
	     },
    );
  # print Dumper({Res1 => $res1});
  if (exists $res1->{Data}) {
    if (exists $res1->{Data}{Result}) {
      my @list;
      if (defined $res1->{Data}{Result}) {
	@list = @{$res1->{Data}{Result}};
      }
      return \@list;
    } else {
      # throw Error();
    }
  } else {
    # throw Error();
  }
}

sub ConvertAssertionToText {
  my ($self,%args) = @_;
  my $ref = ref($args{Formula});
  my $result;
  if ($ref eq 'ARRAY') {
    my @tmpresults;
    foreach my $formula (@{$args{Formula}}) {
      my $tmpresult = $self->ConvertAssertionToText(Formula => $formula);
      if (! $tmpresult->{Success}) {
	return
	  {
	   Success => 0,
	  };
      } else {
	push @tmpresults, $tmpresult->{Result};
      }
    }
    $result = '('.join(' ',@tmpresults).')';
  } elsif ($ref eq '') {
    $result = shell_quote($args{Formula});
  }
  if ($result) {
    return
      {
       Success => 1,
       Result => $result,
      };
  }
}

sub Say {
  my ($self,%args) = @_;
  my $message = $args{Text};
  my $file = $message;
  $file =~ s/[^a-zA-Z0-9]/_/sg;
  my $command1 = "/tmp/$file";
  print "Message: $message\n";
  if (! -f "$command1.wav") {
    WriteFile
      (
       File => "$command1.txt",
       Contents => $message,
      );
    system "text2wave $command1.txt -o $command1.wav";
  }
  # system "echo `whoami` > whoami";
  my $command2 = "(mplayer $command1.wav >/dev/null 2>/dev/null &)";
  ApproveCommands
    (
     Commands => [$command2],
     AutoApprove => 1,
    );
}

1;
