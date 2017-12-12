use warnings;
use strict;
use Getopt::Std;

our ($opt_l, $opt_t, $opt_r,$opt_o);
print "\nINFO - script to merge the expression counts\n";
print "RAW paramters: @ARGV\n";
getopt('ltro');
if ( (!defined $opt_l) && (!defined $opt_t) && (!defined $opt_r) && (!defined $opt_o) ) {
    die ("Usage: $0 \n\t -l [ list of expression files ]  \n\t -t [ type of count (gene/exon) ] \n\t -r [ reference file with gene chr ] \n\t -o [ utput merged expression count ]\n");
}
else    {
    my $list=$opt_l;
    my $type=$opt_t;
    my $output=$opt_o;
    my $ref=$opt_r;
    open LIST, "$list" or die "";
    open OUT, ">$output" or die "";
    my %gene=();
    open GENE, "$ref" or die "";
    while (my $l = <GENE>)	{
	chomp $l;
	 my ($chr,$gene,$name,$start,$stop,$len)=split('\s+',$l);
	 my $value="$chr\t$gene\t$name\t$start\t$stop\t$len";

	$gene{$gene}=$value;
    }
    close GENE;
#    my $header="ChrID\tStart\tStop\tCoding-Length\tStrand\tEnsembl_GeneID\tGene_Type\tGene_Status\tRefSeq_GeneID\tValidation_Status";
   my $header="Chr\tGeneID\tGeneName\tStart\tStop\tCodingLength";

    my %gene1=();
	while(my $l = <LIST>){
        chomp $l;
        my @path=split(/\//,$l);
        my @sample=split(/\./,$path[$#path]);
        my $s1=$sample[0];
        $header.="\t${s1}_${type}Count";
        open COUNT, "$l" or die "";
        while (my $k = <COUNT>){
            chomp $k;
            my ($id,$value)=split(/\t/,$k);
             push(@{$gene1{$id}},$value);
        }
        close COUNT;        
    }
    close LIST;
    print OUT "$header\n";
    my %report;
    foreach my $key (sort keys %gene){	
		print OUT "$gene{$key}\t" . join ("\t",@{$gene1{$key}}) . "\n";
	}
 
}   
    


    
