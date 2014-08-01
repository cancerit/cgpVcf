########## LICENCE ##########
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
########## LICENCE ##########

use strict;
use Test::More;
use warnings FATAL => 'all';
use Carp;
use Data::Dumper;

use FindBin qw($Bin);
my $script_path = "$Bin/../bin/";
my $test_data_path = "$Bin/../testData/";
my $script = $script_path."cgpVCFSplit.pl";
my $vcf_for_split = $test_data_path."vcfForSplit.vcf";
my $header_file = $test_data_path."exp_header.vcf";
my @vcf_split_out = ($vcf_for_split.".1",$vcf_for_split.".2");
my $check_mut_lines;
$check_mut_lines->[0] = "15\t22095504\t.\tG\tA\t.\tPT\tDP=22;MP=8.4e-01;GP=1.5e-01;TG=GG/AG;TP=8.1e-01;SG=AG/GG;SP=7.8e-02\tGT:AA:CA:GA:TA:PM\t0|0:0:0:9:0:0.0e+00\t0|1:4:0:9:0:3.1e-01";
$check_mut_lines->[1] = "17\t3989655\t.\tG\tC\t.\tSE;DTH\tDP=57;MP=8.2e-01;GP=2.7e-06;TG=GG/CG;TP=8.2e-01;SG=GG/GG;SP=1.8e-01\tGT:AA:CA:GA:TA:PM\t0|0:0:0:29:0:0.0e+00\t0|1:0:4:24:0:1.4e-01";
my $CMD = q{perl }.$script.q{ -l 1 -i }.$vcf_for_split.q{ -o }.$vcf_for_split;

my $exp_head = "";
my $FH;
open($FH, '<', $header_file) || die ("Error trying to open expected header file\n");
	while(<$FH>){
		$exp_head .= $_;
	}
close($FH);


subtest 'Initialisation tests' => sub{
  use_ok 'Sanger::CGP::Vcf';
};

subtest 'Split with header' => sub {
	ok(system($CMD) == 0,"Split ran correctly with header");
	my $idx = 0;
	#Check header in each split file
	foreach my $split_file(@vcf_split_out){
		my $IN;
		open($IN, '<', $split_file),'Opening split file' || die "Error trying to open $split_file: $!";
			my $got_head = "";
			while(<$IN>){
				my $line = $_;
				if($line =~ m/^#/){
					$got_head .= $line;
				}else{
					#Check lines in split files
					chomp($line);
					ok($line eq $check_mut_lines->[$idx],'Compare mutant line');
				}
			}
		close($IN);
		ok($got_head eq $exp_head,'Compare headers');
		$idx++;
	}

	#Cleanup split files
	foreach my $split_file(@vcf_split_out){
		ok(unlink($split_file));
	}
};

subtest 'split no header' => sub {
	my $cmd = $CMD;
	$cmd .= " -n ";

	ok(system($cmd) == 0,"Split ran correctly no header");
	my $idx = 0;
	#Check lines in split files
	foreach my $split_file(@vcf_split_out){
		my $IN;
		open($IN, '<', $split_file),'Opening split file' || die "Error trying to open $split_file: $!";
			my $got_head = "";
			while(<$IN>){
				my $line = $_;
				if($line =~ m/^#/){
					$got_head .= $line;
				}else{
					#Check lines in split files
					chomp($line);
					ok($line eq $check_mut_lines->[$idx],'Compare mutant line');
				}
			}
		close($IN);
		ok("" eq $got_head,'Compare headers');
		$idx++;
	}
	#Cleanup split files
	foreach my $split_file(@vcf_split_out){
		ok(unlink($split_file));
	}
};

done_testing();
