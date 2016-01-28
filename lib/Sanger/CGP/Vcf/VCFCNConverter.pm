package Sanger::CGP::Vcf::VCFCNConverter;

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
use Sanger::CGP::Vcf::VcfUtil;
use Sanger::CGP::Vcf;
use Const::Fast qw(const);

const my $SEP => "\t";
const my $NL => "\n";
const my $BLANK => ".";
const my $CNV => 'CNV';
const my $FORMAT => 'GT:TCN:MCN';


our $VERSION = Sanger::CGP::Vcf->VERSION;

1;

sub new{
	my $proto = shift;
	my (%args) = @_;
	my $class = ref($proto) || $proto;

	my $self = {};
	bless $self, $class;

	$self->init(%args);

	return $self;
}

sub init{
	my($self,%args) = @_;
	$self->{_contigs} = $args{-contigs};
	$self->{'_extended_format'} = 0;
}

sub extended_cn {
  my ($self, $val) = @_;
  $self->{'_extended_format'} = $val if(defined $val);
  return $self->{'_extended_format'};
}

=head generate_header

Generates a Vcf header String for NORMAL/TUMOUR comparisons.

@param1 wt_sample      - a Sanger::CGP::Vcf::Sample object representing the normal sample.

@param2 mt_sample      - a Sanger::CGP::Vcf::Sample object representing the mutant sample.

@param3 process_logs   - an array-ref of Sanger::CGP::Vcf::VcfProcessLog objects.

@param5 reference_name - a String containing the name of the reference used in the VCF.

@param6 input_source   - a String containing the name and version of the application or source of the VCF data.

=cut
sub generate_header{
	my($self,$wt_sample, $mt_sample, $process_logs, $reference_name, $input_source) = @_;

	my $contigs = $self->{_contigs};

	my $info = [
		{key => 'INFO', ID => 'END', Number => 1, Type => 'Integer', Description => 'End position of this structural variant'},
		{key => 'INFO', ID => 'SVTYPE', Number => 1, Type => 'String', Description => 'Type of structural variant'},
		{key => 'ALT', ID => 'CNV', Description => 'Copy number variable region'},
	];

	my $format = [
		{key => 'FORMAT', ID => 'GT', Number => 1, Type => 'String', Description => 'Genotype'},
		{key => 'FORMAT', ID => 'TCN', Number => 1, Type => 'Integer', Description => 'Total copy number'},
		{key => 'FORMAT', ID => 'MCN', Number => 1, Type => 'Integer', Description => 'Minor allele copy number'},
	];
  if($self->extended_cn) {
    push @{$format},  {key => 'FORMAT', ID => 'FCF', Number => 1, Type => 'Float', Description => 'Fraction Cells first state'},
                      {key => 'FORMAT', ID => 'TCS', Number => 1, Type => 'Integer', Description => 'Total copy number second state'},
                      {key => 'FORMAT', ID => 'MCS', Number => 1, Type => 'Integer', Description => 'Minor allele copy number second state'},
                      {key => 'FORMAT', ID => 'FCS', Number => 1, Type => 'Float', Description => 'Fraction Cells second state'},
  }

	return Sanger::CGP::Vcf::VcfUtil::gen_tn_vcf_header( $wt_sample, $mt_sample, $contigs, $process_logs, $reference_name, $input_source, $info, $format, []);
}


sub generate_record{
  my ($self,$chr,$start,$end,$start_allele,$wt_cn_tot,$wt_cn_min,$mt_cn_tot,$mt_cn_min, $extended) = @_;
  # CHR POS ID REF ALT QUAL FILTER INFO FORMAT GENOSTUFF GENOSTUFF
  my $ret = $chr.$SEP; #chromsome
	$ret .= $start.$SEP; #Position (start for CNV)
	$ret .= $BLANK.$SEP; #ID
  $ret .= $start_allele.$SEP; #Allele at start position
  $ret .= '<'.$CNV.'>'.$SEP; #CNV marker for alt allele
  $ret .= $BLANK.$SEP; #Quality - unset for this
  $ret .= $BLANK.$SEP; #Filter

  #Info section
  $ret .= 'SVTYPE='.$CNV.';';
  $ret .= 'END='.$end.$SEP;

  # format string
  $ret .= $FORMAT;
  if($self->extended_cn) {
    $ret .= ':FCF:TCS:MCS:FCS';
  }
  $ret .= $SEP;

  #Normal sample section
  $ret .= './.:'.$wt_cn_tot.':'.$wt_cn_min;
  if($self->extended_cn) {
    die "ERROR: extended_cn option set but no extended data provided\n" unless(defined $extended);
    $ret .= ':.';
    $ret .= ':.';
    $ret .= ':.';
    $ret .= ':.';
  }
  $ret .= $SEP;

  #Tumour sample section
  $ret .= './.:'.$mt_cn_tot.':'.$mt_cn_min;
  if($self->extended_cn) {
    die "ERROR: extended_cn option set but no extended data provided\n" unless(defined $extended);
    $ret .= ':'.$extended->{'mt_fcf'};
    $ret .= ':'.$extended->{'mt_tcs'};
    $ret .= ':'.$extended->{'mt_mcs'};
    $ret .= ':'.$extended->{'mt_fcs'};
  }
  $ret .= $NL;
  return $ret;
}
return 1;
