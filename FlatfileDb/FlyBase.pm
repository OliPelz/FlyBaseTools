package FlatfileDb::FlyBase;

# this module contains various Flybase related parsers, manglers, stuff for their flatfile databases

use strict;
use warnings;

sub new {
    my $class  = shift;
    my $self   = {};
    my $fields = {};

    $fields->{"chrom"}  = 0;
    $fields->{"type"}   = 2;
    $fields->{"start"}  = 3;
    $fields->{"stop"}   = 4;
    $fields->{"strand"} = 6;
    $fields->{"info"}   = 8;
    $self->{"_fields"}  = $fields;

    my $gff = {};
    $gff->{"startNodes"}  = {};
    $gff->{"linkedNodes"} = {};
    $gff->{"endNodes"}    = {};
    $self->{"_gff"}       = $gff;

    # debug output, please note this has a negative impact on the runtime
    # as we will count the line numbers in the input file first
    $self->{_debugOutput} = 0;
    
    # store complete information field in the datastructure
    # this takes up a lot of RAM, so by default we will disable it
    # but if you need to further process additional information
    # do enable it
    # TODO: not implemented yet
    $self->{_storeInfoField} = 0;

    return bless $self, $class;
}

# this method parses the "All Gff file" e.g.  dmel-all-r6.08.gff
# for a specified list of features -> as an array ref
# please note, they changed the entire file format starting with r6.01
# this parses the latest available format

# the new fileformat contains a "dependant" structure and you need to be aware of that
# e.g.
# grep FBtr0114187  ~/GenomeRNAi-Db-builds/db_build_v15/14_generate-flybase-amplicons-relationship/anno/dmel-all-r6.08.gff
# 211000022278158       FlyBase exon    592     1036    .       +       .       Parent=FBtr0114187
# 211000022278158       FlyBase rRNA    592     1036    .       +       .       ID=FBtr0114187;Name=CR40502-RA;Parent=FBgn0085737;Dbxref=FlyBase_Annotation_IDs:CR40502-RA,REFSEQ:NR_004043;score_text
#211000022278158	FlyBase	gene	592	1036	.	+	.	ID=FBgn0085737;Name=CR40502;Alias=FBan0040502;Ontology_term=SO:0000011,SO:0000087,SO:0000573;Dbxref=FlyBase_Annotation_IDs:CR40502,EntrezGene:5740665,GenomeRNAi:5740665

# build a regular expression dynamically, which checks that the type column
# is one of the type array elements
sub buildTypeRegExp {
    my $self   = shift;
    my @typesA = @{ $_[0] };
     
    if(scalar @typesA < 1) {
       return undef;
    }
   
# for building the regular expression we need to know which column the type column is
    my $regexp = "^";
    for ( my $i = 0 ; $i < $self->{"_fields"}->{"type"} ; $i++ ) {
        $regexp .= "[^\\t]+\\t";
    }
    return $regexp . "(" . join( "|", @typesA ) . ")\\t";

}

# filter parameter filters for specific "type" lines which helps in faster parsing
# if you want to use all lines, submit the [] empty value here
sub parseAllGffFile {
    my $self     = shift;
    my $filename = $_[0];

    # the types to filter, if submit the empty array [], there will be no fiter
    my @typesA = @{ $_[1] };

    # the ds to return
    my $ds = {};
    my $FH;
    open( $FH, "<", $filename ) || die "cannot open input file $filename";
    my $line;
    my $lineCnt;
    my $totalCnt;
    if ( $self->{debugOutput} ) {
        $lineCnt = 0;
        print STDERR "counting total lines in file...";
        $totalCnt = ( split( ' ', `wc $filename` ) )[0];
        print STDERR "...done!\n";
    }
    my $f = $self->{"_fields"};

    # build regexp for faster checks
    my $typeRegExp = $self->buildTypeRegExp( \@typesA );

    while ( $line = <$FH> ) {
        if ( $self->{"debugOutput"} ) {
            print "lines parsed: $lineCnt  / $totalCnt\n"
              if ( ++$lineCnt % 10000 == 0 );
        }

        #skip lines starting with a #
        next if $line =~ /^#/;
	next if $line =~ /^>/;
        next if defined($typeRegExp) && $line !~ /$typeRegExp/;
        my @a      = split( "\t", $line );
        next if (scalar @a < $f->{info} + 1);
        my $chrom  = $a[ $f->{"chrom"} ];
        my $type   = $a[ $f->{"type"} ];
        my $start  = $a[ $f->{"start"} ];
        my $stop   = $a[ $f->{"stop"} ];
        my $strand = $a[ $f->{strand} ];
        my $info   = $a[ $f->{info} ];
#  differentiate between three different kind of nodes: startNodes (e.g. mRNA, exons, rRNA - have only parent)
#  linkedNodes (have ID and parent), endNodes (have only ID)
# start node have only Parent information
        if ( $info !~ /ID=/ && $info =~ /Parent=(.+)\n/ ) {
            my $pIds = $1;
            my @a = split( ",", $pIds );
            foreach my $pId (@a) {
                push @{ $ds->{_gff}->{"startNodes"}->{$type} },
                  [ $pId, $chrom, $start, $stop, $strand ];
            }
	    # TODO: if needed store the info field as well
	    # Pseudo code:
	    # if $self->{_storeInfoField} then push @@{ $ds->{_gff}->{"startNodes"}->{$type} }, $info
        }

# linked nodes or intermediate nodes have both ID and Parent information
        elsif ( $info =~ /^ID=([^;]+).*Parent=([^;]+)/ ) {
            my $id  = $1;
            my $pId = $2;
            $ds->{_gff}->{"linkedNodes"}->{$id}  = 
              [ $pId, $type, $chrom, $start, $stop, $strand ];
	    #TODO: # if $self->{_storeInfoField} then push @@{ $ds->{_gff}->{"startNodes"}->{$type} }, $info
	    
            # this is a helper structure as this is requested lot of time: get the linkedNodes by types
            $ds->{_gff}->{"linkedNodes_type"}->{$type}->{$id} = $ds->{_gff}->{"linkedNodes"}->{$id}; 
        }

# end nodes have only ID information
        elsif ( $info =~ /ID=([^;]+)/ && $info !~ /Parent=/ ) {
            my $id = $1;
            $ds->{_gff}->{"endNodes"}->{$id} = 
              [ $type, $chrom, $start, $stop, $strand ];
            # TODO: # if $self->{_storeInfoField} then push @@{ $ds->{_gff}->{"startNodes"}->{$type} }, $info

        }
    }
    return $ds;
}
# This method traverses the Gff tree and prints out the first and last node  
# expects a datastructure (ds) coming from parseAllGffFile sub
# traverseGffTree($ds, "gene") would traverse the gff datastructure recursively
# and stop when hitting an associated gene for every start node
# the result would be e.g. exon1 -> associated gene1, exon2 ->associated gene2
sub printTraverseEndNodeGffTree {
   my $self     = shift;
   my $ds = $_[0];
## the "end" node types to filter
   my $targetEndNode = $_[1];

# for every start node
   foreach my $type ( @{ $ds->{"_gff"}->{"startNodes"} } ) {
      foreach my $ar ( @{ $ds->{"_gff"}->{"startNodes"}->{$type} } ) {
          print join("\t", @$ar);
          my $ar2 = $self->returnLeafElementTraverseGffTree($ar->[0], $ds);
          if(defined($ar2)) {
             if($ar2->[1] eq "gene") {
                print "\tassociated gene: " . $ar2->[0] . "\n";
             }
          }
      }
   }
}
# this works recursively and returns the last leaf element of a root element
sub returnLeafElementTraverseGffTree {
   my $self = shift;
   my $id = $_[0];
   my $ds = $_[1];

   if(defined($ds->{"_gff"}->{"linkedNodes"}->{$id})) {
      $self->returnLeafElementTraverseGffTree($ds->{"_gff"}->{"linkedNodes"}->{$id}->[0], $ds);
   }
   elsif(defined($ds->{"_gff"}->{"endNodes"}->{$id})) {
      return $id;
   }
   else {
      return undef;
   }
}

1;
