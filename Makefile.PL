use ExtUtils::MakeMaker;

WriteMakefile(
  NAME		=> 'Data::BT::PhoneBill',
  VERSION_FROM	=> 'lib/Data/BT/PhoneBill.pm', 
  PREREQ_PM		=> { 
    Test::More => 0.17,
    LWP::UserAgent => undef,
    HTTP::Request  => undef,
    HTML::TableExtract => 1.07,
  }, 
  ($] > 5.005 ? () : (
    ABSTRACT_FROM => 'lib/Data/BT/PhoneBill.pm', 
    AUTHOR        => 'Tony Bowden <kasei@tmtm.com>',
  )),
);
