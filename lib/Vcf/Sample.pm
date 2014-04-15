package Sanger::CGP::Vcf::Sample;

use Sanger::CGP::Vcf;
our $VERSION = Sanger::CGP::Vcf->VERSION;

use strict;

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