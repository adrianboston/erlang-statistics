package Stat::Base;
use strict;
use warnings;
use Chart::Strip;

sub new {
	my ( $class, $colorset_ref, $styleopts_ref ) = @_;
	my $self = {};
	@{ $self->{colorset_ref} } = @{$colorset_ref};    # makin' a copy
	$self->{styleopts_ref} = $styleopts_ref;
	$self->{chart}         = Chart::Strip->new(
		%{ $styleopts_ref },
	);
	bless $self, $class;
	return $self;
}

sub process { }                                       # override!

sub write_png {
	my $self     = shift;
	my $filename = shift;
	my $img      = $self->{chart}->png();
	open my $fh, '>', $filename or die "Couldn't open $filename for writing: $!\n";
	binmode($fh);
	print {$fh} $img or die "Write failed: $!";
	close $fh;
	return 1;
}

sub write_jpeg {
	my $self     = shift;
	my $filename = shift;
	my $img      = $self->{chart}->jpeg();
	open my $fh, '>', $filename or die "Couldn't open $filename for writing: $!\n";
	binmode($fh);
	print {$fh} $img or die "Write failed: $!";
	close $fh;
	return 1;
}
1;
