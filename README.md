# FlyBaseTools
some FlyBase Tools for parsing and processing FlyBase flat files written in Perl

## Install by cloning this repository
Checkout as usual, e.g. using ssh
```bash
git clone git@github.com:OliPelz/FlyBaseTools.git
```

### Run tests
FlyBaseTools has been tested against FlyBase flatfile databases release 6.09/FB2016_01

First step is to define the following environment variables
```bash
export FLYBRELVER="6.09"
export FLYBRELDAT="2016_01"
```


To run tests, you need to download some flatfiles:
```bash
cd ./FlyBaseTools
eval "curl -o ./t/dmel-all-r${FLYBRELVER}.gff.gz ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r${FLYBRELVER}_FB${FLYBRELDAT}/gff/dmel-all-r${FLYBRELVER}.gff.gz"
gunzip ./t/dmel-all-r${FLYBRELVER}.gff.gz
```
Now run the full test suite using:
```bash
./t/runTestSuite.sh

```

### Init new parsing session
```perl
use strict;
use warnings;
 
use Test::More 'no_plan';
use FlatfileDb::FlyBase;
 
my $fbt = FlatfileDb::FlyBase->new();

```
### start parsing everything (Note: takes massive RAM amount)
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
      my $found = 0;
      print(join("\t", ($chrom, $start, $stop, $strand)));
      my @rootIds;
      foreach my $id (@$id_ar) {
         my $rootId = $fbt->returnLeafElementTraverseGffTree($id, $ds);
         my $rootDs = $ds->{_gff}->{"endNodes"}->{$rootId};
         if($rootDs->[0] eq "gene") {
             join(@rootIds, $rootId);
         } 
     }
      print("\t" . join(",", @rootIds). "\n");
  }
} 
```



#### Make it faster

### Documentation

##### FlyBase all-in-one GFF file
FlyBase introduced a new file format starting with the Dmel6 release. It contains parent-child relationships between different knd of biological
object classes such as exon-rRNA-gene. These relationships is modelled using "Parent=", "ID=" links in the GFF file.
Therefore the datastructure in the memory to construct these relationships is quite bit and takes lots of memory.
I use a recursive algorithm approach to traverse the tree and provide solutions to common biological questions such as:
"get all the associated genes for a single exon"  
