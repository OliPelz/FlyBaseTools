# this script prints out all the exon, utr, pre_miRNA, miRNA, snoRNA, rRNA, ncRNA
# tRNA, snRNA TO gene relationships there is in the drosophila dmel-all-rXXX gff file
use strict;
use warnings;
use FlatfileDb::FlyBase;
 
my $fbt = FlatfileDb::FlyBase->new();

my $flyBaseVer  = $ENV{FLYBRELVER};
my $flyBaseDate = $ENV{FLYBRELDAT};


my $ds = $fbt->parseAllGffFile( "./t/dmel-all-r$flyBaseVer.gff", [] );


# get associated genes for exon and UTRs
my %startNode_features = ( 
  exon => '', 
  five_prime_UTR => '', 
  three_prime_UTR => '', 
);
foreach my $type (keys %startNode_features) {
   my $ars = $ds->{_gff}->{"startNodes"}->{$type};
   foreach my $ar (@$ars) {
      my ($chrom, $start, $stop, $strand, $id_ar ) = @$ar;
      print(join("\t", ($type, $chrom, $start, $stop, $strand)));
      my @rootIds;
      foreach my $id (@$id_ar) {
         my $rootId = $fbt->returnLeafElementTraverseGffTree($id, $ds);
         if(!defined($rootId)) {
           print "debug me"
         }
         my $rootDs = defined($ds->{_gff}->{"endNodes"}->{$rootId}) ? $ds->{_gff}->{"endNodes"}->{$rootId} : [];
         if(scalar @$rootDs > 0 && $rootDs->[0] eq "gene") {
             push(@rootIds, $rootId);
         }   
      }   
      print("\t" . join(",", @rootIds). "\n");
  }
} 
# get associated genes for some other biological objects

my %intermediateNode_features = (
    pre_miRNA => '',
    miRNA => '',
    snoRNA => '',
    rRNA => '',
    ncRNA => '',
    tRNA => '',
    snRNA => ''
);
foreach my $type (keys %intermediateNode_features) {
   my $ftrs = $ds->{_gff}->{"linkedNodes_type"}->{$type};
   foreach my $id (keys %$ftrs) {
      my $ar = $ftrs->{$id}; 
      my ($pId, $type, $chrom, $start, $stop, $strand ) = @$ar;
      print(join("\t", ($type, $chrom, $start, $stop, $strand)));
      my $rootId = $fbt->returnLeafElementTraverseGffTree($pId, $ds);
      my $rootDs = defined($ds->{_gff}->{"endNodes"}->{$rootId}) ? $ds->{_gff}->{"endNodes"}->{$rootId} : [];
      if($rootDs->[0] eq "gene") {
         print("\t" . join(",", $rootId . "\n"));
      }
   }  
}


