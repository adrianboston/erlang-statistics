package Stat::GarbageCollections;
use base 'Stat::Base';
use strict;
use warnings;

sub process {
	my $self     = shift;
	my $list_ref = shift;
    my @gcs = generate_set_cumulative($list_ref, "garbage_collections");

    $self->{chart}->add_data( \@gcs, { label => 'garbage collections', style => 'line', color => shift @{$self->{colorset_ref}} });

}
sub generate_set_cumulative {
    my $list_ref = shift;
    my $what = shift;
    my @set;
    my $previous = 0;
    foreach my $hash (@{$list_ref}){
        if ( $hash->{$what} < $previous ) {
				$previous = 0;
			}
        push @set, 
        {
            time => $hash->{date},
            value => $hash->{$what} - $previous,
        };
        $previous = $hash->{$what};
    }
    @set
}
1;
