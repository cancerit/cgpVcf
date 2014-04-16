package Sanger::CGP::Vcf::VcfProcessLog;

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
		_input_vcf        => $args{'-input_vcf'},
		_input_vcf_source => $args{'-input_vcf_source'},
		_input_vcf_ver    => $args{'-input_vcf_ver'},
		_input_vcf_params  => $args{'-input_vcf_params'},
	};
    bless $self, $class;
    return $self;
}

sub input_vcf{
	my($self,$value) = @_;
	$self->{_input_vcf} = $value if defined $value;
	return $self->{_input_vcf};
}

sub input_vcf_source{
	my($self,$value) = @_;
	$self->{_input_vcf_source} = $value if defined $value;
	return $self->{_input_vcf_source};
}

sub input_vcf_ver{
	my($self,$value) = @_;
	$self->{_input_vcf_ver} = $value if defined $value;
	return $self->{_input_vcf_ver};
}

sub input_vcf_params{
	my($self,$value) = @_;
	$self->{_input_vcf_params} = $value if defined $value;
	return $self->{_input_vcf_params};
}
