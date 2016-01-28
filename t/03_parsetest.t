use strict;
use warnings;

use Test::More 'no_plan';

use FlatfileDb::FlyBase;

my $fbt = FlatfileDb::FlyBase->new();

my $flyBaseVer  = $ENV{FLYBRELVER};
my $flyBaseDate = $ENV{FLYBRELDAT};

# for this big file parsing we will show some progress
#$fbt->{"debugOutput"} = 1;

my $ds = $fbt->parseAllGffFile("./t/dmel-all-r$flyBaseVer.gff", ["exon"]);

############################# exon checks
is(defined($ds), 1, "check if parseAllGffFile returns some value");

#the following tests are dependant on the $flyBaseVer version
if($flyBaseVer eq "6.09") {
   my %fbtrChecks;

# define some checks


# these exons should be found in the ds
   $fbtrChecks{"FBtr0114187"} = 0;
   $fbtrChecks{"FBtr0091491"} = 0;
   $fbtrChecks{"FBtr0344858"} = 0;
   is(defined($ds->{"_gff"}->{"startNodes"}->{"exon"}), 1, "exon datastructure must be defined");
   my $aRs = $ds->{"_gff"}->{"startNodes"}->{"exon"};
   foreach my $aR (@$aRs) {
      if($aR->[0] eq "FBtr0114187") {
         $fbtrChecks{"FBtr0114187"} = 1;
      }
      if($aR->[0] eq "FBtr0091491") {
         $fbtrChecks{"FBtr0091491"} = 1;
      }
      if($aR->[0] eq "FBtr0344858") { 
         $fbtrChecks{"FBtr0344858"} = 1;
      }

   }
# validate all exon checks
   foreach my $fbtr (keys %fbtrChecks) {
      is($fbtrChecks{$fbtr}, 1, "check if $fbtr could be found in the datastructure");
   }
}
################################# linked nodes tests - rRNA
$ds = $fbt->parseAllGffFile("./t/dmel-all-r$flyBaseVer.gff", ["rRNA"]);
is(defined($ds->{"_gff"}->{"linkedNodes"}), 1, "linked nodes datastructure must be defined");


################################ end nodes tests 
$ds = $fbt->parseAllGffFile("./t/dmel-all-r$flyBaseVer.gff", ["gene"]);
is(defined($ds->{"_gff"}->{"endNodes"}), 1, "end nodes datastructure must be defined");




