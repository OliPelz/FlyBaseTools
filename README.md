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

### Start parsing


### Start answering biological questions examples

#### Get all exons

#### Get all rRNAs

#### Get all genes for all exons

#### Make it faster

### Documentation

##### FlyBase all-in-one GFF file
FlyBase introduced a new file format starting with the Dmel6 release. It contains parent-child relationships between different knd of biological
object classes such as exon-rRNA-gene. These relationships is modelled using "Parent=", "ID=" links in the GFF file.
Therefore the datastructure in the memory to construct these relationships is quite bit and takes lots of memory.
I use a recursive algorithm approach to traverse the tree and provide solutions to common biological questions such as:
"get all the associated genes for a single exon"  
