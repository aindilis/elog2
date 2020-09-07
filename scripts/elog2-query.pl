#!/usr/bin/perl -w

use KBS2::ImportExport;
use PerlLib::MySQL;

use Data::Dumper;

my $importexport = KBS2::ImportExport->new();
my $mysql = PerlLib::MySQL->new
  (
   DBName => 'elog2',
  );

my $datequery = `date "+%Y-%m-%d"`;
chomp $datequery;
my $res1 = $mysql->Do
  (
   Statement => "select e.*, m.FormulaID as FormulaID from events e, metadata m where e.RecordDate like '$datequery%' and e.Event=m.ID;",
  );

my $rendercache = {};
# print Dumper($res);
foreach my $key (sort {$res1->{$a}{RecordDate} cmp $res1->{$b}{RecordDate}} keys %{$res1}) {
  my $event = $res1->{$key}{FormulaID};
  my $res0 = Retrieve(ID => $event);
  if (! exists $rendercache->{$event}) {
    my $res1 = $importexport->Convert
      (
       Input => [$res0],
       InputType => 'Interlingua',
       OutputType => 'Prolog',
      );
    if ($res1->{Success}) {
      $rendercache->{$event} = $res1->{Output};
      chomp $rendercache->{$event};
    } else {
      $rendercache->{$event} = '';
    }
  }
  print $res1->{$key}{RecordDate}.' '.$rendercache->{$event}."\n";
}

# KBS2

sub Retrieve {			# V2
  my (%args) = @_;
  # print Dumper({RetrieveArgs => \%args});
  my $r2 = $mysql->Do(Statement => "select * from arguments where ParentFormulaID=$args{ID}");
  # now reconstruct it
  my @rec;
  foreach my $aid (keys %$r2) {
    if ($r2->{$aid}->{ValueType} eq "formula") {
      $rec[$r2->{$aid}->{KeyID}] = Retrieve
	(ID => $r2->{$aid}->{Value});
    } elsif ($r2->{$aid}->{ValueType} eq "variable") {
      $rec[$r2->{$aid}->{KeyID}] = \*{"::".$r2->{$aid}->{Value}};
    } else {
      $rec[$r2->{$aid}->{KeyID}] = $r2->{$aid}->{Value};
    }
  }
  return \@rec;
}
