package Stat::ClientDistribution;
use base 'Stat::Base';
use strict;
use warnings;
use Data::Dumper;

sub process {
	my $self     = shift;
	my $list_ref = shift;
	my $clients = {};
	foreach my $hash ( @{$list_ref} ) {
		my @dataset1 = ();
		my @dataset2 = ();
		foreach my $client ( keys %{ $hash->{clients} } ) {    # sortiere das datenset für diesen timeslice in ein brauchbares format
			push @dataset1, { name => $client, time => $hash->{time}, value => $hash->{clients}->{$client} };
			push @dataset2, { name => $client, time => $hash->{time}, value => $hash->{clients}->{$client} };
		}
		# this should be optimized by cloning the dataset instead of making two copies. I'm just too tired right now
		# to figure out how to clone a structure. Later.

		# now we got everything in a more processable format.
		
		for ( my $i = 0 ; $i <= $#dataset1 ; $i++ ) {          # for each client we calculate the cumulative distribution
			$dataset1[$i]->{value} = calculate_cumulative( $i, @dataset1 );
		}
		for ( my $i = 0 ; $i <= $#dataset2 ; $i++ ) {          # for each client we calculate the cumulative distribution
			$dataset2[$i]->{value} = calculate_cumulative( $i, @dataset2 );
		}

		for ( my $i = 0 ; $i <= $#dataset2 ; $i++ ) {
			if ( $i == 0 ) {
				$dataset2[$i]->{value} = 100;
			}
			else {
				eval { $dataset2[$i]->{value} = $dataset1[$i]->{value} / $dataset1[ 0 ]->{value} * 100; };
				$dataset2[$i]->{value} = 0 if $@;
			}
		}
		foreach my $client (@dataset2){
			push @{$clients->{$client->{name}}}, {time => $client->{time}, value => $client->{value}};
		}
	}
	foreach my $client (keys %{$clients}){
		$self->{chart}->add_data( $clients->{$client}, { label => $client, style => 'filled', color => shift @{$self->{colorset_ref}} } );
	}
}
1;

sub calculate_cumulative {
	my $index = shift;
	my @set   = @_;
	return $set[$index]->{value} if $index == $#set;
	return $set[$index]->{value} + calculate_cumulative( ++$index, @set );
}