package Data::BT::PhoneBill;

$VERSION = '0.91';

=head1 NAME

Data::BT::PhoneBill - Parse a BT Phone Bill from their web site

=head1 SYNOPSIS

  my $bill = Data::BT::PhoneBill->new($filename);

  while (my $call = $bill->next_call) {
    print $call->date, $call->time, $call->destination,
          $call->number, $call->duration, $call->cost;
    }
  }

=head1 DESCRIPTION

This module provides an interface for querying your BT phone bill,
as produced from their "View My Bill" service at www.bt.com

You should use their "Download Calls" option to save your bill as a CSV
file, and then feed it to this module.

=head1 CONSTRUCTOR

=head2 new

  my $bill = Data::BT::PhoneBill->new($filename);

Parses the bill stored in $filename.

=head1 FETCHING DATA

  while (my $call = $bill->next_call) {
    print $call->date, $call->time, $call->destination,
          $call->number, $call->duration, $call->cost;
    }
  }

Each time you call $bill->next_call it will return a
Data::BT::PhoneBill::Call object representing a telephone call (or false
when there are no more to read)

Each Call object has the following methods defined:

=head2 date

A Date::Simple object represeting the date of the call.

=head2 time

A string representing the time of the call in the 24-hr format 'hh:mm'.

=head2 destination

A string that for local and national calls this will usually be the
town. However this can also contain things like "Premium Rate", "Local
Rate" etc for 'non-geogrpahic' calls.

=head2 number

A string representing the telephone number dialled, formatted as it
appears on the bill.

=head2 duration

The length of the call in seconds.

=head2 cost

The cost of the call, before any discounts are applied, in pence.

=cut

use strict;
use HTML::TableExtract;
use Text::CSV_XS;
use IO::File;

use overload '<>' => \&next_call;

sub new {
  my ($class, $file) = @_;
  my $fh = new IO::File $file, "r"  or die "Can't read $file: $!\n";
  my $headers = <$fh>;
  bless {
    _fh => $fh,
    _parser => Text::CSV_XS->new,
  }, $class;
}

sub fh  { shift->{_fh}     }
sub csv { shift->{_parser} }

sub next_call {
  my $self = shift;
  my $fh = $self->fh;
  my $line = <$fh>;
  return unless defined $line;
  if ($self->csv->parse($line)) {
    return Data::BT::PhoneBill::Call->new($self->csv->fields)
  } else {
    warn "Cannot parse: " . $self->csv->error_input . "\n";
    return;
  }
}

# ==================================================================== #

package Data::BT::PhoneBill::Call;

use Date::Simple;

sub new {
  my ($class, @data) = @_;
  bless \@data => $class;
}

sub date {
  my @parts = split /\//, shift->_date;
  return Date::Simple->new(@parts[2,1,0]);
}

sub duration { 
  my ($h, $m, $s) = split /:/, shift->_duration;
  return ($h * 60 * 60) + ($m * 60) + $s;
}

sub cost { shift->_cost * 100 }

sub _date       { shift->[0] }
sub time        { shift->[1] }
sub destination { shift->[2] }
sub number      { shift->[3] }
sub type        { shift->[4] }
sub _duration   { shift->[5] }
sub _cost       { shift->[6] }

1;

=head1 FEEDBACK

If you find this module useful, or have any comments, suggestions or
improvements, please let me know.

=head1 AUTHOR

Tony Bowden, E<lt>kasei@tmtm.comE<gt>.

=head1 COPYRIGHT

Copyright (C) 2001 Tony Bowden. All rights reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
