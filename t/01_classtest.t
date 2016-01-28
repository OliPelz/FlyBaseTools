use strict;
use warnings;

use Test::More 'no_plan';

use_ok('FlatfileDb::FlyBase');

my $flyBaseVer  = $ENV{FLYBRELVER};
my $flyBaseDate = $ENV{FLYBRELDAT}; 


is(defined($flyBaseVer), 1, "check if env variable is set FLYBRELVER 'FlyBase Version number'");
is(defined($flyBaseDate), 1, "check if env variable is set FLYBRELDAT 'FlyBase version date'");

my $fbt = FlatfileDb::FlyBase->new();
is($fbt->{"_fields"}->{"chrom"}, 0, "check if we constructor is working as expected");


