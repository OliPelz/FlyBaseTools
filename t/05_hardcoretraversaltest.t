# This test needs BIG RAM and takes quite a while

use strict;
use warnings;
 
use Test::More 'no_plan';

use FlatfileDb::FlyBase;

my $fbt = FlatfileDb::FlyBase->new();

# for this big file parsing we will show some progress
#$fbt->{"debugOutput"} = 1;


# test recursive tree fetch method
 
my $flyBaseVer  = $ENV{FLYBRELVER};
my $flyBaseDate = $ENV{FLYBRELDAT};
 
is( defined($flyBaseVer), 1,
    "check if env variable is set FLYBRELVER 'FlyBase Version number'" );
is( defined($flyBaseDate), 1,
    "check if env variable is set FLYBRELDAT 'FlyBase version date'" );

 
my $ds = $fbt->parseAllGffFile( "./t/dmel-all-r$flyBaseVer.gff", [] );

# calc all types using BASH: 
# grep -v '#' t/dmel-all-r6.09.gff | grep -v ">" |  cut -f3   | sort | uniq | wc

foreach my $type (('intron', 'match_part', 'three_prime_UTR', 'exon', 'five_prime_UTR', 'CDS')) {
  is( defined( $ds->{"_gff"}->{"startNodes"}->{$type} ),
             1, "$type type must be defined in startNodes" );
}

# advanced test
my %startNode_features = (
    exon => '',
    five_prime_UTR => '',
    three_prime_UTR => '',
);

my %intermediateNode_features = (
    pre_miRNA => '',
    miRNA => '',
    snoRNA => '',
    rRNA => '',
    ncRNA => '',
    tRNA => '',
    snRNA => ''
);

# these are some real life scenarios
#
# test if we can traverse from startNodes to the root
foreach my $type (keys %startNode_features) {
   my $ars = $ds->{_gff}->{"startNodes"}->{$type};
   foreach my $ar (@$ars) {
      my ($chrom, $start, $stop, $strand, $id_ar ) = @$ar;
      my $found = 0;
      foreach my $id (@$id_ar) {
        my $rootId = $fbt->returnLeafElementTraverseGffTree($id, $ds); 
        my $rootDs = $ds->{_gff}->{"endNodes"}->{$rootId};
        if($id eq "FBtr0114187") {
# some exon tests
            is($rootId eq "FBgn0085737" && $rootDs->[0] eq "gene", 1, "exon to gene association must match $id , $rootId, " . $rootDs->[0] );
          $found = 1; 
       }
       is($found, 1, "cannot find searched gene");
# some five prime tests

# some three prime tests
      } 
   }
}
# test if we can traverse from linkedNodes to the root
foreach my $type (keys %intermediateNode_features) {
   my $ars = $ds->{_gff}->{"linkedNodes_type"}->{$type};
   foreach my $ar (@$ars) {
       my ($chrom, $start, $stop, $strand, $id_ar ) = @$ar;
       foreach my $id (@$id_ar) { 
         my $rootId = $fbt->returnLeafElementTraverseGffTree($id, $ds);
         my $rootDs = $ds->{_gff}->{"endNodes"}->{$rootId};
# some mRNAi test
         if($id eq "FBtr0077999") {
            is($rootId eq "FBgn0031273" && $rootDs->[1] eq "625652", 1,  "exon to gene association must match $id , $rootId, " . $rootDs->[0] );
         } 
# some five prime tests
 
 # some three prime tests
       }
    }
}


 
