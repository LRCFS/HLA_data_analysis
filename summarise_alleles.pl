#! /usr/bin/perl

use strict;
use warnings;

use Getopt::Long qw(:config auto_version);
use Pod::Usage;

my $file = '';
my $out = 'out.summary';
my $filter = 2;
my $format = 'fasta';
my $VERBOSE = 1;
my $DEBUG = 0;
my $help;
my $man;
our $VERSION = '0.1';

GetOptions (
   'file=s'    => \$file,
   'out=s'     => \$out,
   'percent=i' => \$filter,
   'out-format|O=s' => \$format,
   'verbose!'  => \$VERBOSE,
   'debug!'    => \$DEBUG,
   'man'       => \$man,
   'help|?'    => \$help,
) or pod2usage();

pod2usage(-msg => 'Please supply a valid filename.') if (!$file or !-e $file);
pod2usage(-verbose => 2) if ($man);
pod2usage(-verbose => 1) if ($help);

# open input fasta file
open(my $fh, "<", $file) or die "ERROR - unable to open input file.\n";

# read file and store and count unique sequence strings in a hash
print "Reading file...\n" if $VERBOSE;
my %seqs;
my $n = 0;
while(<$fh>) {
    chomp();
 
    # check file is in fasta format
    if ($. == 1) {
        die "ERROR - input file is not in fasta format.\n" unless (/^>/)
    }
    # skip defline
    next if (/^>/);
    # check seq is nucleic
    die "ERROR - not nucleic acid at line $.\n" if  (/[^ACGTN]/);

    $seqs{$_}++; 
    $n++; 

}
close($fh);
print "Read $n sequences\n" if $VERBOSE;

print "Summarising ". scalar(keys(%seqs)) ." unique sequences\n" if $VERBOSE;
open(my $OUT, ">", $out) or die "ERROR - unable to open output file.\n";
# sort sequences by most frequent first
my $i = 1;
foreach my $seq (reverse sort {$seqs{$a} <=> $seqs{$b}} keys %seqs) { 
    # print the sequence, it's count and it's percentage (that passed the filter)
    next unless (100*$seqs{$seq}/$n > $filter);
    if ($format eq 'fasta') {
        printf $OUT ">seq$i count:%d percent:%.1f\n$seq\n", $seqs{$seq}, 100*$seqs{$seq}/$n;
    } else {
        printf $OUT "%s %6d %4.1f\n", $seq, $seqs{$seq}, 100*$seqs{$seq}/$n;
    }
    ++$i;
}
close($OUT)

