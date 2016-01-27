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
export FLYBRELVER="6.09"
export FLYBRELDAT="2016_01"


To run tests, you need to download some flatfiles:
```bash
cd ./FlyBaseTools
eval "curl -o ./t/dmel-all-r${FLYBRELVER}.gff.gz ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r${FLYBRELVER}_FB${FLYBRELDAT}/gff/dmel-all-r${FLYBRELVER}.gff.gz"
gunzip ./t/dmel-all-r$FLYBRELVER.gff.gz
```
Now run the full test suite using:
```bash
prove ./t/runTestSuite.pl

```

### Start parsing
