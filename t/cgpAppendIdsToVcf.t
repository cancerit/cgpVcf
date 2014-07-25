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
my $script = $script_path."cgpAppendIdsToVcf.pl";
my $vcf_for_ids = $test_data_path."vcfForSplit.vcf";
my $id_file = $test_data_path."vcfIds.vcf";
my $header_file = $test_data_path."exp_header.vcf";
my $exp_head = "";

my $FH;
open($FH, '<', $header_file) || die ("Error trying to open expected header file\n");
	while(<$FH>){
		$exp_head .= $_;
	}
close($FH);


my $CMD = q{perl }.$script.q{ -i }.$vcf_for_ids.q{ -o }.$id_file;

subtest 'Initialisation tests' => sub{
  use_ok 'Sanger::CGP::Vcf';
};

subtest 'Add IDS as numeric' => sub{
	my $cmd1 = $CMD." -g 1";
	ok(system($cmd1) == 0,"Add IDs script ran correctly with header");
	my $FH;
	my $got_head = "";
	open($FH,'<',$id_file) || die ("Error trying to open $id_file for reading: $!");
		my $exp_id = 1;
		while(<$FH>){
			my $line = $_;
			if($line =~ m/^#/){
				$got_head .= $line;
			}else{
				#Check lines in split files
				chomp($line);
				my ($chr,$pos,$id,$other) = split(/\t/,$line);
				ok($id eq $exp_id,'Compare mutant line');
				$exp_id++;
			}
		}
		ok($exp_head eq $got_head,'Compare header');
	close($FH);
	unlink($id_file);
};

subtest 'Add UUIDs' => sub{
	ok(system($CMD) == 0,"Add UUIDs script ran correctly with header");
	my $FH;
	my $got_head = "";
	open($FH,'<',$id_file) || die ("Error trying to open $id_file for reading: $!");
		while(<$FH>){
			my $line = $_;
			if($line =~ m/^#/){
				$got_head .= $line;
			}else{
				#Check lines in split files
				chomp($line);
				my ($chr,$pos,$id,$other) = split(/\t/,$line);
				ok($id ne ".",'Compare mutant line');
			}
		}
		ok($exp_head eq $got_head,'Compare header');
	close($FH);
	unlink($id_file);
};

done_testing();
