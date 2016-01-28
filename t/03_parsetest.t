my $ds = $fbt->parseAllGffFile("./t/dmel-all-r$flyBaseVer.gff", ["exon", "mRNA"]);
is(defined($ds), 1, "check if parseAllGffFile returns some value");



#the following tests are dependant on the $flyBaseVer version
if($flyBaseVer eq "6.09") {
   my %fbtrChecks;
   $fbtrChecks{"FBtr0114187"} = 0;
   my $aRs = @{$ds->{"startNodes"}->{"exon"}};
   foreach my $aR (@$aRs) {
      if($aR->[0] eq "FBtr0114187") {
         $fbtrChecks{"FBtr0114187"} = 1;
      }
   }

   foreach my $fbtr (keys %fbtrChecks) {
      is($fbtrChecks{$fbtr}, 1, "check if $fbtr could be found in the ds");
   }

}

