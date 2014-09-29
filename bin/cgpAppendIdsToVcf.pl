#!/usr/bin/perl

##########LICENCE##########
# Copyright (c) 2014 Genome Research Ltd.
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
##########LICENCE##########

use strict;
use warnings FATAL => 'all';

use Getopt::Long;
use Pod::Usage;
use English qw( -no_match_vars );
use Carp;
use Vcf;

use Sanger::CGP::Vcf;
use Sanger::CGP::Vcf::OutputGen::UuIdGenerator;
use Sanger::CGP::Vcf::OutputGen::SequentialIdGenerator;

my $VERSION = Sanger::CGP::Vcf->VERSION;

my $opts = option_builder();
validateInput($opts);

my $outFile = $opts->{'o'};

#Open the file
my $OUT;
#Open VCF input file
my $vcf = Vcf->new(file=>$opts->{'f'}, -version=>'4.1');
#Read header first into the headerstore
$vcf->parse_header();
#Iterate through each mutant line and print up to the max number of lines
open($OUT, '>', $outFile) || die("Error trying to open output file $outFile: $!\n");

	#Ensure we print a single header file first in case there are no mutations.
	print $OUT ($vcf->format_header()) || croak("Error writing header to file $outFile: $!\n");


	my $id_gen;
	if(defined $opts->{'g'}){
		$id_gen = new Sanger::CGP::Vcf::OutputGen::SequentialIdGenerator(-start => $opts->{'g'});
	}else{
		$id_gen = new Sanger::CGP::Vcf::OutputGen::UuIdGenerator();
	}

	#Iterate through the mutations, assigning an ID as we go.
	while(my $x = $vcf->next_data_array()){
		#While we still have mutant lines.
		#Put the ID in the line
		$$x[2] = $id_gen->next;
		print $OUT $vcf->format_line($x) || croak("Error writing vcf line to file: $!\n");
	}
#Close output file, if not already closed in loop
close($OUT) || croak("Error closing file $outFile: $!\n");

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
		'i|file=s' => \$opts{'f'},
		'o|outFile=s' => \$opts{'o'},
		'g|idstart=i' => \$opts{'g'},
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
  unless(-e $opts->{'f'} && -r $opts->{'f'}){
  	pod2usage("input VCF file does not exist or has incorrect permissions: ".$opts->{'f'}."\n");
  }
  pod2usage("Incorrect parameters:") unless(defined($opts->{'f'}) && defined($opts->{'o'}));

  return;
}

__END__

=head1 NAME

cgpAppendIdsToVcf.pl - Appends IDs to VCF files in the form of a sequencial increment or UUID generated.

=head1 SYNOPSIS

cgpAppendIdsToVcf.pl [-h] -i this.vcf -o this_with_ids.vcf

  General Options:

  --help      (-h)       Brief documentation

	--file      (-i)       The file to append IDs to.

	--outFile   (-o)       The output filename

	Optional parameters:

	--idstart   (-g)       Will set a sequential id generator to the given integer value. If not present will assign UUIDs to each variant.

	--version   (-v)       Prints version information.

  Examples:

    cgpAppendIdsToVcf.pl -f this.vcf -o this_with_ids.vcf -g 1

=cut
