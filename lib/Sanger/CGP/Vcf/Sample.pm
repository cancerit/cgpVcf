package Sanger::CGP::Vcf::Sample;

##########LICENCE##########
# Copyright (c) 2014,2015 Genome Research Ltd.
#
# Author: Jon Hinton <cgpit@sanger.ac.uk>
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


use Sanger::CGP::Vcf;
our $VERSION = Sanger::CGP::Vcf->VERSION;

use strict;
use warnings FATAL => 'all';

1;

sub new{
	my $proto = shift;
	my (%args) = @_;
	my $class = ref($proto) || $proto;

	my $self = {
		_name => $args{'-name'},
		_study => $args{'-study'},
		_accession => $args{'-accession'},
		_accession_source => $args{'-accession_source'},
		_platform => $args{'-platform'},
		_seq_protocol => $args{'-seq_protocol'},
		_description => $args{'-description'},
	};
    bless $self, $class;
    return $self;
}

sub name{
	my($self,$value) = @_;
	$self->{_name} = $value if defined $value;
	return $self->{_name};
}

sub study{
	my($self,$value) = @_;
	$self->{_study} = $value if defined $value;
	return $self->{_study};
}

sub accession{
	my($self,$value) = @_;
	$self->{_accession} = $value if defined $value;
	return $self->{_accession};
}

sub accession_source{
	my($self,$value) = @_;
	$self->{_accession_source} = $value if defined $value;
	return $self->{_accession_source};
}

sub platform{
	my($self,$value) = @_;
	$self->{_platform} = $value if defined $value;
	return $self->{_platform};
}

sub seq_protocol{
	my($self,$value) = @_;
	$self->{_seq_protocol} = $value if defined $value;
	return $self->{_seq_protocol};
}

sub description{
	my($self,$value) = @_;
	$self->{_description} = $value if defined $value;
	return $self->{_description};
}
