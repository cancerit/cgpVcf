package Sanger::CGP::Vcf::Contig;

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
		_length => $args{'-length'},
		_species => $args{'-species'},
		_assembly => $args{'-assembly'},
		_checksum => $args{'-checksum'},
	};
    bless $self, $class;
    return $self;
}

sub name{
	my($self,$value) = @_;
	$self->{_name} = $value if defined $value;
	return $self->{_name};
}

sub length{
	my($self,$value) = @_;
	$self->{_length} = $value if defined $value;
	return $self->{_length};
}

sub species{
	my($self,$value) = @_;
	$self->{_species} = $value if defined $value;
	return $self->{_species};
}

sub assembly{
	my($self,$value) = @_;
	$self->{_assembly} = $value if defined $value;
	return $self->{_assembly};
}

sub checksum{
	my($self,$value) = @_;
	$self->{_checksum} = $value if defined $value;
	return $self->{_checksum};
}

sub compare{
	my($self,$contig) = @_;

	my $same = 1;
	$same = 0 unless ref $contig eq 'Sanger::CGP::Pindel::OutputGen::Contig';
	$same = 0 unless $contig->name eq $self->{_name};
	$same = 0 unless $contig->length eq $self->{_length};
	$same = 0 unless $contig->assembly eq $self->{_assembly};
	$same = 0 unless $contig->species eq $self->{_species};
	if(defined ($contig->checksum) && defined ($self->{_checksum})){
		$same = 0 unless $contig->checksum eq $self->{_checksum};
	}
	return $same;
}
