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

 
my $ds = $fbt->parseAllGffFile( "./t/dmel-all-r$flyBaseVer.gff", ["exon","mRNA", "gene"] );

my $startNodeId = "FBtr0077980"; 

my $id = $fbt->returnLeafElementTraverseGffTree($startNodeId, $ds);
is($id, "FBgn0024314", "must print out the correct associated gene $id" );

