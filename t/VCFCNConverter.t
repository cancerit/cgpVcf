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
use Test::More;
use Test::Fatal;
use FindBin qw($Bin);
use Data::Dumper;
use File::Spec;

use Sanger::CGP::Vcf::VcfProcessLog;
use Sanger::CGP::Vcf::Contig;
use Sanger::CGP::Vcf::Sample;
use Sanger::CGP::Vcf::VcfUtil;

my $MODULE = 'Sanger::CGP::Vcf::VCFCNConverter';

subtest 'Initialisation tests' => sub{
  use_ok 'Sanger::CGP::Vcf::VcfUtil';
  use_ok 'Sanger::CGP::Vcf';
  use_ok 'Sanger::CGP::Vcf::VCFCNConverter';
};

subtest 'Generate Header tests' => sub{
  #First build the contigs
  my ($contigs, $process_logs);
  push @$contigs, Sanger::CGP::Vcf::Contig->new(  -name => '1',
                                                  -length => '12345',
                                                  -species => 'TEST_SPP',
                                                  -assembly => 'TEST_ASS');
  my $opts;
  $opts->{'TEST_OPTS_1'} = 'TEST_1';
  $opts->{'TEST_OPTS_2'} = 'TEST_2';
  #Now add a process_log
  push @$process_logs, new Sanger::CGP::Vcf::VcfProcessLog(
                                    -input_vcf_source => 'TEST_SOURCE',
                                    -input_vcf_ver => Sanger::CGP::Vcf->VERSION,
                                    -input_vcf_param => $opts,
                                  );
  #Setup samples
  my $mt_sample = new Sanger::CGP::Vcf::Sample(
        -name => 'TEST_MUT',
        -study => 3,
        -platform => 'HISEQ',
        -seq_protocol => 'PROT',
        -accession => 4,
        -accession_source => 'SRC'
  );

  my $wt_sample = new Sanger::CGP::Vcf::Sample(
        -name => 'TEST_NORM',
        -study => 2,
        -platform => 'HISEQ',
        -seq_protocol => 'PROT',
        -accession => 5,
        -accession_source => 'SRC'
  );

  my $ref_name = 'reference.fa';
  my $source = "TEST_SOURCE";
  my $EXP_HEADER =  "##fileformat=VCFv4.1\n".
                    "##fileDate=".Sanger::CGP::Vcf::VcfUtil->get_date()."\n".
                    "##source_".Sanger::CGP::Vcf::VcfUtil->get_date().".1=".$source."\n".
                    "##reference=".$ref_name."\n".
                    "##contig=<ID=1,assembly=TEST_ASS,length=12345,species=TEST_SPP>\n".
                    "##INFO=<ID=END,Number=1,Type=Integer,Description=\"End position of this structural variant\">\n".
                    "##INFO=<ID=SVTYPE,Number=1,Type=String,Description=\"Type of structural variant\">\n".
                    "##ALT=<ID=CNV,Description=\"Copy number variable region\">\n".
                    "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">\n".
                    "##FORMAT=<ID=TCN,Number=1,Type=Integer,Description=\"Total copy number\">\n".
                    "##FORMAT=<ID=MCN,Number=1,Type=Integer,Description=\"Minor allele copy number\">\n".
                    "##vcfProcessLog_".Sanger::CGP::Vcf::VcfUtil->get_date().".1=<InputVCFSource=<$source>,InputVCFVer=<".Sanger::CGP::Vcf->VERSION.">>\n".
                    "##SAMPLE=<ID=NORMAL,Accession=5,Platform=HISEQ,Protocol=PROT,SampleName=TEST_NORM,Source=SRC,Study=2>\n".
                    "##SAMPLE=<ID=TUMOUR,Accession=4,Platform=HISEQ,Protocol=PROT,SampleName=TEST_MUT,Source=SRC,Study=3>\n".
                    "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tNORMAL\tTUMOUR\n";

  my $converter = Sanger::CGP::Vcf::VCFCNConverter->new(-contigs => $contigs);
  my $head = $converter->generate_header($wt_sample, $mt_sample, $process_logs, $ref_name, $source);
  ok($head eq $EXP_HEADER, 'Compare headers');

};

subtest 'Generate Record tests' => sub{
  #First build the contigs
  my $contigs;
  push @$contigs, Sanger::CGP::Vcf::Contig->new(  -name => '1',
                                                  -length => '12345',
                                                  -species => 'TEST_SPP',
                                                  -assembly => 'TEST_ASS');

  my $converter = Sanger::CGP::Vcf::VCFCNConverter->new(-contigs => $contigs);
  my $chr = "X";
  my $start = 1;
  my $end = 10;
  my $start_allele = 'C';
  my $wt_cn_tot = 3;
  my $wt_cn_min = 2;
  my $mt_cn_tot = 5;
  my $mt_cn_min = 4;

  my $EXP_RECORD = "$chr\t$start\t.\t$start_allele\t<CNV>\t.\t.\t".
                    "SVTYPE=CNV;END=$end\t".
                    "GT:TCN:MCN\t./.:3:2\t./.:5:4\n";

  my $record = $converter->generate_record($chr,$start,$end,$start_allele,$wt_cn_tot,$wt_cn_min,$mt_cn_tot,$mt_cn_min);

  ok($record eq $EXP_RECORD, 'Compare record');
};

done_testing();
