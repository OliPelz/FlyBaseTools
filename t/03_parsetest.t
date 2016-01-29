use strict;
use warnings;

use Test::More 'no_plan';

use FlatfileDb::FlyBase;

my $fbt = FlatfileDb::FlyBase->new();

my $flyBaseVer  = $ENV{FLYBRELVER};
my $flyBaseDate = $ENV{FLYBRELDAT};

is( defined($flyBaseVer), 1,
    "check if env variable is set FLYBRELVER 'FlyBase Version number'" );
is( defined($flyBaseDate), 1,
    "check if env variable is set FLYBRELDAT 'FlyBase version date'" );

# for this big file parsing we will show some progress
#$fbt->{"debugOutput"} = 1;

my $ds = $fbt->parseAllGffFile( "./t/dmel-all-r$flyBaseVer.gff", ["exon"] );

############################# exon checks
is( defined($ds), 1, "check if parseAllGffFile returns some value" );

#the following tests are dependant on the $flyBaseVer version
if ( $flyBaseVer eq "6.09" ) {
    my %fbtrChecks;

    # define some checks

    # these exons should be found in the ds
    $fbtrChecks{"FBtr0114187"} = 0;
    $fbtrChecks{"FBtr0091491"} = 0;
    $fbtrChecks{"FBtr0344858"} = 0;
    is( defined( $ds->{"_gff"}->{"startNodes"}->{"exon"} ),
        1, "exon datastructure must be defined" );
    my $aRs = $ds->{"_gff"}->{"startNodes"}->{"exon"}; 
    foreach my $aR (@$aRs) {
        my $a = $aR->[4];
        foreach my $fbtr (@$a) {
          if ( $fbtr eq "FBtr0114187" ) {
              $fbtrChecks{"FBtr0114187"} = 1;
          }
          if ( $fbtr eq "FBtr0091491" ) {
              $fbtrChecks{"FBtr0091491"} = 1;
          }
          if ( $fbtr eq "FBtr0344858" ) {
              $fbtrChecks{"FBtr0344858"} = 1;
          }
        }

    }

    # validate all exon checks
    foreach my $fbtr ( keys %fbtrChecks ) {
        is( $fbtrChecks{$fbtr}, 1,
            "check if $fbtr could be found in the datastructure" );
    }

################################# linked nodes tests - rRNA
    $ds = $fbt->parseAllGffFile( "./t/dmel-all-r$flyBaseVer.gff", ["rRNA"] );
    is( defined( $ds->{"_gff"}->{"linkedNodes"} ),
        1, "linked nodes datastructure must be defined" );
    my %linkedChecks;
    $linkedChecks{"FBgn0085822"} = 0;
    $linkedChecks{"FBgn0085777"} = 0;
    my $hsh = $ds->{"_gff"}->{"linkedNodes_type"}->{"rRNA"};
    is(defined($hsh->{"FBtr0114280"}), 1, "linked node must contain FBtr id");
    if ($hsh->{"FBtr0114280"}->[0] eq "FBgn0085822" ) {
       $linkedChecks{"FBgn0085822"} = 1;
    }
    if ($hsh->{"FBtr0114228"}->[0] eq "FBgn0085777" ) {
       $linkedChecks{"FBgn0085777"} = 1; 
    }
    $hsh = $ds->{"_gff"}->{"linkedNodes"};
    is(defined($hsh->{"FBtr0114280"}), 1, "linked node must contain FBtr id");
    if ($hsh->{"FBtr0114280"}->[0] eq "FBgn0085822" ) {
       $linkedChecks{"FBgn0085822"} = 1;
    }
    if ($hsh->{"FBtr0114228"}->[0] eq "FBgn0085777" ) {
       $linkedChecks{"FBgn0085777"} = 1;
    }



    # validate all linked nodes checks
    foreach my $fbgn ( keys %linkedChecks ) {
        is( $linkedChecks{$fbgn}, 1,
            "check if $fbgn could be found in the datastructure" );
    }

################################ end nodes tests
    $ds = $fbt->parseAllGffFile( "./t/dmel-all-r$flyBaseVer.gff", ["gene"] );
    is( defined( $ds->{"_gff"}->{"endNodes"} ),
        1, "end nodes datastructure must be defined" );
    my %endNodesChecks;
    $endNodesChecks{""} = 0;
    $endNodesChecks{""} = 0;
    $hsh = $ds->{"_gff"}->{"endNodes"};
    is(defined($hsh->{"FBgn0031443"}), 1, "end node must contain FBgn id");
    is(defined($hsh->{"FBgn0260451"}), 1, "end node must contain FBgn id");  
}




