use strict;
use warnings;

use Test::More 'no_plan';

use FlatfileDb::FlyBase;

my $fbt = FlatfileDb::FlyBase->new();

# Testing method buildTypeRegExp

# first make the test more independant of possible hardcode changes
$fbt->{"_fields"}->{"type"} = 1;
my $regex = $fbt->buildTypeRegExp( ["exon"] );
is( $regex, "^[^\\t]+\\t(exon)\\t",
    "check if dynamic regular expression building method is correct $regex" );

$regex = $fbt->buildTypeRegExp( [ "exon", "mRNA" ] );
is( $regex, "^[^\\t]+\\t(exon\|mRNA)\\t",
    "check if dynamic regular expression building method is correct $regex" );

$regex = $fbt->buildTypeRegExp( [ "exon", "mRNA", "rRNAiX", "rRNAi" ] );
is(
    $regex,
    "^[^\\t]+\\t(exon\|mRNA\|rRNAiX\|rRNAi)\\t",
    "check if dynamic regular expression building method is correct $regex"
);

$fbt->{"_fields"}->{"type"} = 2;
$regex = $fbt->buildTypeRegExp( [ "exon", "mRNA", "rRNAiX", "rRNAi" ] );
is(
    $regex,
    "^[^\\t]+\\t[^\\t]+\\t(exon\|mRNA\|rRNAiX\|rRNAi)\\t",
    "check if dynamic regular expression building method is correct $regex"
);

# test with empty array = which means do not filter by anything
$fbt->{"_fields"}->{"type"} = 1;
$regex = $fbt->buildTypeRegExp( [] );
is(!defined($regex), 1, "empty regexp array argument should result in undef value");


