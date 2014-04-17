package Sanger::CGP::Vcf::Contig;

use Sanger::CGP::Vcf;
our $VERSION = Sanger::CGP::Vcf->VERSION;

use strict;
use Carp qw(croak);
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
	croak 'Incorrect input' unless ref $contig eq 'Sanger::CGP::Vcf::Contig';

  # check for defined mismatch
  return 0 if((defined $contig->name      ? 1 : 0) != (defined $self->{_name}     ? 1 : 0));
  return 0 if((defined $contig->length    ? 1 : 0) != (defined $self->{_length}   ? 1 : 0));
  return 0 if((defined $contig->assembly  ? 1 : 0) != (defined $self->{_assembly} ? 1 : 0));
  return 0 if((defined $contig->species   ? 1 : 0) != (defined $self->{_species}  ? 1 : 0));
  return 0 if((defined $contig->checksum  ? 1 : 0) != (defined $self->{_checksum} ? 1 : 0));

  return 0 if defined $self->{_name} && $contig->name ne $self->{_name};
	return 0 if defined $self->{_length} && $contig->length != $self->{_length};
	return 0 if defined $self->{_assembly} && $contig->assembly ne $self->{_assembly};
	return 0 if defined $self->{_species} && $contig->species ne $self->{_species};
	return 0 if defined $self->{_checksum} && $contig->checksum ne $self->{_checksum};

  return 1;

#	$same = 0 unless $contig->name eq $self->{_name};
#	$same = 0 unless $contig->length eq $self->{_length};
#	$same = 0 unless $contig->assembly eq $self->{_assembly};
#	$same = 0 unless $contig->species eq $self->{_species};
#	if(defined ($contig->checksum) && defined ($self->{_checksum})){
#		$same = 0 unless $contig->checksum eq $self->{_checksum};
#	}
#	return $same;
}
