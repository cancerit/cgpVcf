package Sanger::CGP::Vcf::BamUtil;

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
use Sanger::CGP::Vcf;
use Carp;

our $VERSION = Sanger::CGP::Vcf->VERSION;

sub parse_contigs{
  my($self,$header_txt, $man_species, $man_assembly) = @_;

  my $contigs = {};

  foreach my $line (split(/\n/,$header_txt)){
    if($line =~ /^\@SQ/){
      my ($name) = $line =~ /SN:([^\t]+)/;
      my ($length) = $line =~ /LN:([^\t]+)/;
      my ($assembly) = $line =~ /AS:([^\t]+)/;
      my ($species) = $line =~ /SP:([^\t]+)/;

      if(defined $man_species) {
        if(defined $species) {
          die "ERROR: Manually entered species ($man_species) doesn't match BAM file header ($species)\n"
            if($man_species ne $species);
        }
        else { $species = $man_species; }
      }
      die "ERROR: Species must be defined, check options/BAM header\n" unless(defined $species);

      if(defined $man_assembly) {
        if(defined $assembly) {
          die "ERROR: Manually entered assembly ($man_assembly) doesn't match BAM file header ($assembly)\n"
            if($man_assembly ne $assembly);
        }
        else { $assembly = $man_assembly; }
      }
      die "ERROR: Assembly must be defined, check options/BAM header\n" unless(defined $assembly);

      my $contig = new Sanger::CGP::Vcf::Contig(
        -name => $name,
        -length => $length,
        -assembly => $assembly,
        -species => $species
      );

      if(exists $contigs->{$name}){
      	croak "ERROR: Trying to merge contigs with conflicting data:\n".Dumper($contigs->{$name})."\n".Dumper($contig)
          unless $contig->compare($contigs->{$name});
      } else {
      	$contigs->{$name} = $contig;
      }
    }
  }
  return $contigs;
}

sub parse_samples{
  my($self,$header_txt,$study,$protocol,$accession,$accession_source,$description,$platform_in) = @_;

  my $samples = {};

  foreach my $line (split(/\n/,$header_txt)){
    if($line =~ /^\@RG/){
      my ($name) = $line =~ /SM:([^\t]+)/;
      my $platform;
      if($line =~ /PL:([^\t]+)/) {
        $platform = $1;
        die "ERROR: Manually entered platform ($platform_in) doesn't match BAM file header ($platform)" if(defined $platform && $platform ne $platform_in);
      }
      else {
        $platform = $platform_in;
      }

      $samples->{$name} = new Sanger::CGP::Vcf::Sample(
        -name => $name,
        -study => $study,
        -platform => $platform,
        -seq_protocol => $protocol,
        -accession => $accession,
        -accession_source => $accession_source,
        -description => $description
      ) unless exists $samples->{$name};
    }
  }
  return $samples;
}

return 1;
