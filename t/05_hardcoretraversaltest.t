# This test needs BIG RAM and takes quite a while

use strict;
use warnings;
 
use Test::More 'no_plan';

use FlatfileDb::FlyBase;

my $fbt = FlatfileDb::FlyBase->new();


# test recursive tree fetch method
 
my $flyBaseVer  = $ENV{FLYBRELVER};
my $flyBaseDate = $ENV{FLYBRELDAT};
 
is( defined($flyBaseVer), 1,
    "check if env variable is set FLYBRELVER 'FlyBase Version number'" );
is( defined($flyBaseDate), 1,
    "check if env variable is set FLYBRELDAT 'FlyBase version date'" );

 
my $ds = $fbt->parseAllGffFile( "./t/dmel-all-r$flyBaseVer.gff", [] );

# calc all types using BASH: 
# grep -v '#' t/dmel-all-r6.09.gff | cut -f3   | sort | uniq | wc

foreach my $type (('intron', 'match_part', 'three_prime_UTR', 'exon', 'five_prime_UTR', 'CDS')) {
  is( defined( $ds->{"_gff"}->{"startNodes"}->{$type} ),
             1, "$type type must be defined in startNodes" );
} 
