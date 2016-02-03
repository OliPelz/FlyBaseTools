# FlyBaseTools
some FlyBase Tools for parsing and processing FlyBase flat files written in Perl

## Install by cloning this repository
Checkout as usual, e.g. using ssh
```bash
git clone git@github.com:OliPelz/FlyBaseTools.git
```

### Run tests
FlyBaseTools has been tested against FlyBase flatfile databases release 6.09/FB2016_01

First step is to define the following environment variables on the command line
```bash
export FLYBRELVER="6.09"
export FLYBRELDAT="2016_01"
```

To run the tests, you need to download some flatfiles:
```bash
cd ./FlyBaseTools
eval "curl -o ./t/dmel-all-r${FLYBRELVER}.gff.gz ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r${FLYBRELVER}_FB${FLYBRELDAT}/gff/dmel-all-r${FLYBRELVER}.gff.gz"
gunzip ./t/dmel-all-r${FLYBRELVER}.gff.gz
```
Now run the full test suite using:
```bash
./t/runTestSuite.sh

```

### To init new parsing session (object) for a given dmel-all gff file
```perl
use FlatfileDb::FlyBase;
 
my $fbt = FlatfileDb::FlyBase->new();

my $flyBaseVer  = $ENV{FLYBRELVER};
my $flyBaseDate = $ENV{FLYBRELDAT};
 
```
### start parsing the gff file (Note: takes massive RAM amount)
```perl
my $ds = $fbt->parseAllGffFile( "./t/dmel-all-r$flyBaseVer.gff", [] );
```

### Start answering biological questions examples

#### Get all exon objects
```perl
my $exons = $ds->{_gff}->{"startNodes"}->{"exon"}
```

#### Get all rRNAs
```perl
my $rRna = $ds->{_gff}->{"linkedNodes_type"}->{"rRNA"}
```

#### Print all genes for all exons, UTR's
```perl
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
```
#### Print all genes for miRNA etc. (intermediate biological objects)
```perl
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

```


#### Make it faster
To make it faster you can set a filter. This will be set by using an array parameter with all the biological
types you want to extract into a datastructure. 
Please note and be aware that if you want to get rootNodes from the extracted datastructure, you must take into
account any intermediate types along the tree traversing. For example if you want to get all the genes for all given
exons, you cannot just filter the datastructure by ['exon', 'gene'] but you need to add also the intermediate 'rRNA'
because exon->rRNA->gene
As said before if you want to extract all genes for given exons you would use the following structure
```perl
my $ds = $fbt->parseAllGffFile( "./t/dmel-all-r$flyBaseVer.gff", ["exon", "rRNA", "gene"] );
```
### Documentation

##### FlyBase all-in-one GFF file
FlyBase introduced a new file format starting with the Dmel6 release. It contains parent-child relationships between different knd of biological
object classes such as exon-rRNA-gene. These relationships is modelled using "Parent=", "ID=" links in the GFF file.
Therefore the datastructure in the memory to construct these relationships is quite bit and takes lots of memory.
I use a recursive algorithm approach to traverse the tree and provide solutions to common biological questions such as:
"get all the associated genes for a single exon"  
