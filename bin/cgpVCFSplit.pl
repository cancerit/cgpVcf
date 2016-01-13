#!/usr/bin/perl

##########LICENCE##########
# Copyright (c) 2014,2015 Genome Research Ltd.
#
# Author: David Jones <cgpit@sanger.ac.uk>
#
# This file is part of cgpVcf.
#
# cgpVcf is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation; either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# 1. The usage of a range of years within a copyright statement contained within
# this distribution should be interpreted as being equivalent to a list of years
# including the first and last year specified and all consecutive years between
# them. For example, a copyright statement that reads ‘Copyright (c) 2005, 2007-
# 2009, 2011-2012’ should be interpreted as being identical to a statement that
# reads ‘Copyright (c) 2005, 2007, 2008, 2009, 2011, 2012’ and a copyright
# statement that reads ‘Copyright (c) 2005-2012’ should be interpreted as being
# identical to a statement that reads ‘Copyright (c) 2005, 2006, 2007, 2008,
# 2009, 2010, 2011, 2012’."
########## LICENCE ##########

use strict;
use warnings FATAL => 'all';

use Getopt::Long;
use Pod::Usage;
use English qw( -no_match_vars );
use Carp;
use Vcf;

use Sanger::CGP::Vcf;

my $VERSION = Sanger::CGP::Vcf->VERSION;

my $opts = option_builder();
validateInput($opts);


my $lineCounter = 0;
my $fileCounter = 1;
my $headRead = 0;
my $maxLines = $opts->{'l'};
my $outFileName = $opts->{'o'}.".";

#Open the file
#my $IN;
my $OUT = undef;
#Open VCF input file
my $vcf = Vcf->new(file=>$opts->{'f'}, -version=>'4.1');
#First run through to validate.
if(!$opts->{'s'}){
	eval{
		$vcf->run_validation();
	};
	if($@){
		croak($@);
	}
}
#Reopen the vcf file so the module works!
$vcf = Vcf->new(file=>$opts->{'f'}, -version=>'4.1');
#Read header first into the headerstore
$vcf->parse_header();
#Iterate through each mutant line and print up to the max number of lines
my $outFile;
$outFile = $outFileName.$fileCounter;
open($OUT, '>', $outFile) || die("Error trying to open output file $outFile: $!\n");
#Ensure we print a single header file first in case there are no mutations.
if(!defined($opts->{'n'}) || $opts->{'n'} != 1){
	print $OUT ($vcf->format_header()) || croak("Error writing header to file $outFile: $!\n");
}

#Iterate through the mutations, assigning an ID as we go.
while(my $x = $vcf->next_line()){
	#Open an output file if we need one
	if(!defined($OUT)){
		$fileCounter++;
		$outFile = $outFileName.$fileCounter;
		open($OUT, '>', $outFile) || croak("Error trying to open output file $outFile: $!\n");
		if(!defined($opts->{'n'}) || $opts->{'n'} != 1){
			print $OUT ($vcf->format_header()) || croak("Error writing header to file $outFile: $!\n");
		}
	}

	#While we still have mutant lines.
	print $OUT $x || croak("Error writing vcf line to file: $!\n");
	$lineCounter++;
	#If we've reached the limit of lines for this file, close the FH and move onto the next file.
	if($lineCounter == $opts->{'l'}){
		$lineCounter = 0;
		#Close this output file (another is opened at the top).
		close($OUT) || croak("Error writing line to file: $!\n");
		$OUT = undef;
	}
}
#Close output file, if not already closed in loop
if(defined $OUT) {
  close($OUT) || croak("Error closing file $outFile: $!\n");
}
print "Split file into into $fileCounter\n";

###################
#
#	SUBROUTINES
#
###################


sub option_builder {
	my ($factory) = @_;

	my %opts = ();

	my $result = &GetOptions (
		'h|help' => \$opts{'h'},
		'l|linecount=n' => \$opts{'l'},
		'i|file=s' => \$opts{'f'},
		'n|nohead' => \$opts{'n'},
		'o|outFile=s' => \$opts{'o'},
		's|skip-validate' => \$opts{'s'},
		'v|version' => \$opts{'v'},
	);

	return \%opts;
}

sub validateInput {
  my $opts = shift;
  if(defined($opts->{'h'})){
  	pod2usage("Usage\n");
  }

  if(defined $opts->{'v'}){
    print "Version: $VERSION\n";
    exit;
  }
  pod2usage("Incorrect parameters:") unless(defined($opts->{'f'}) && defined($opts->{'l'}) && defined($opts->{'o'}));
  unless(-e $opts->{'f'} && -r $opts->{'f'}){
  	pod2usage("VCF file to split does not exist or has incorrect permissions: ".$opts->{'f'}."\n");
  }
  

  return;
}

__END__

=head1 NAME

cgpVCFSplit.pl - Splits a VCF file into files of [l] lines, will include the head lines in ever file unless -n is specified.

=head1 SYNOPSIS

cgpVCFSplit.pl [-h]  -l 1000 -f vcfToSplit.vcf

  General Options:

  --help      (-h)       Brief documentation

	--linecount (-l)       The number of mutant lines to put in each split file.

	--nohead    (-n)       Switch to ignore the header of the file when creating split files.

	--file      (-i)       The file to split.

	--outFile   (-o)       The base output file name will be <fileName>.[1-n] where n is the number of files created by the split.

	--skip-validate (-s)   Skip the validation step.

	Optional parameters:

	--version   (-v)       Prints version information.

  Examples:

    cgpVCFSplit.pl -l 2000 -f thisVCF.vcf -g 1

=cut
