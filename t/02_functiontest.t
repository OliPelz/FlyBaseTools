use strict;
use warnings;

use Test::More;

use FlatfileDb::FlyBase;

my $fbt = FlatfileDb::FlyBase->new();

my $regex = $fbt->buildTypeRegExp(["exon"]);

is($regex, "^[^\\t]+\\t(exon)", "check if dynamic regular expression building method is correct $regex");

$regex = $fbt->buildTypeRegExp(["exon", "mRNA"]);

is($regex, "^[^\\t]+\\t(exon\|mRNA)", "check if dynamic regular expression building method is correct $regex");
