#!/usr/bin/perl -w

use Test::More tests => 29;
use Data::BT::PhoneBill;

my $filename = "data/phone.csv";
my $bill = Data::BT::PhoneBill->new($filename);
isa_ok $bill => Data::BT::PhoneBill;

{
  ok my $call = <$bill>, "Get first call";
  isa_ok $call => Data::BT::PhoneBill::Call;
  isa_ok $call->date => Date::Simple;
  is $call->date->format, "2001-09-05", "date";
  is $call->time, "16:49", "time";
  is $call->destination, "Belfast", "destination";
  is $call->number, "028 9037 2237", "number";
  is $call->type, "DD Local", "type";
  is $call->duration, 295, "duration";
  is $call->cost, 16.5, "cost";
}

{
  my $call = <$bill>;
  isa_ok $call => Data::BT::PhoneBill::Call;
  is $call->date->format, "2001-09-17", "date";
  is $call->time, "11:06", "time";
  ok !$call->destination, "no destination";
  is $call->number, "123", "number";
  is $call->type, "DD Other", "type";
  is $call->duration, 1, "duration";
  is $call->cost, 8.5, "cost";
}

{
  ok my $call = $bill->next_call, "Get third call";
  isa_ok $call => Data::BT::PhoneBill::Call;
  is $call->date->format, "2001-09-19", "date";
  is $call->time, "17:51", "time";
  is $call->destination, "Nat Rate", "no destination";
  is $call->number, "0870 6070222", "number";
  is $call->type, "DD Other", "type";
  is $call->duration, 4082, "duration";
  is $call->cost, 354, "cost";
}

ok !<$bill>, "No more calls";
