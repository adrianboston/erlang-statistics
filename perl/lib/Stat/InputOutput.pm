package Stat::InputOutput;
use base 'Stat::Base';
use strict;
use warnings;

sub process {
	my $self     = shift;
	my $list_ref = shift;
	my $last_in  = undef;
	my $last_out = undef;
	my @traffic_in;
	my @traffic_out;
	foreach my $hash ( @{$list_ref} ) {
		my $is_in;
		my $is_out;
		if ( !defined $last_in && !defined $last_out ) {    # first iteration, the values are still undef
			$is_in  = 0;
			$is_out = 0;
		}
		else {                              # not the first iteration - continue with usual processing
			if ( $hash->{input} < $last_in ) {
				$last_in  = 0;
				$last_out = 0;
			}
			$is_in  = $hash->{input} - $last_in;
			$is_out = $hash->{output} - $last_out;
		}
		push @traffic_in,
		  {
			time  => $hash->{date},
			value => $is_in,
		  };
		push @traffic_out,
		  {
			time  => $hash->{date},
			value => $is_out,
		  };
		$last_in  = $hash->{input};
		$last_out = $hash->{output};
	}
	$self->{chart}->add_data( \@traffic_in,  { label => 'Incoming', style => 'line', color => shift @{ $self->{colorset_ref} } } );
	$self->{chart}->add_data( \@traffic_out, { label => 'Outgoing', style => 'line', color => shift @{ $self->{colorset_ref} } } );
	return $self->{chart};
}
1;
