use strict;
use warnings;

use Test::More 'no_plan';

use_ok('FlatfileDb::FlyBase');

my $flyBaseVer  = $ENV{FLYBRELVER};
my $flyBaseDate = $ENV{FLYBRELDAT}; 

is(defined($flyBaseVer), 1, "check if env variable is set 'FlyBase Version number'");
is(defined($flyBaseDate), 1, "check if env variable is set 'FlyBase version date'");

my $fbt = FlatfileDb::FlyBase->new();
my $ds = $fbt->parseAllGffFile("./t/dmel-all-r$flyBaseVer.gff", ["exon", "mRNA"]); 
is(defined($ds), 1, "check if parseAllGffFile returns some value");


# setup methods are run before every test method.
#sub make_fixture : Test(setup) {
#    is($flyBaseVer, );
#    my $self = shift;
#    $self->{"fbt"} = FlyBaseTools->new();
#    isa_ok($fbt, "Object");   
#}
#sub test_FlyBase_obj {
#   my $self = shift;
#   my $fbt  = $self->{"_"}; 
#}
#sub test_parseAllGffFile {
#  my $self = shift;
#  my $fbt  = $self->{"fbt"}; 
#  isa_ok($fbt, "Object");
#  my $ds = $fbt->parseAllGffFile("./dmel-all-r$flyBaseVer.gff");      
#  is_deeply($ds, (), 'object empty');  
#}
# teardown methods are run after every test method.
#sub teardown : Test(teardown) {
#   my $array = shift->{test_array};
#   diag("array = (@$array) after test(s)");
#}
