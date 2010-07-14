package Stat::Generic;
use base 'Stat::Base';
use strict;
use warnings;

sub process {
	my $self     = shift;
	my $list_ref = shift;
	my $last_value  = undef;
    my $type = $self->{styleopts_ref}->{type};
    my @data = @{$self->{styleopts_ref}->{data}};
    die "Generic only supports cumulative types right now." if $type ne "cumulative";    
    foreach my $generic_data_set (@data) {
        my $key = $generic_data_set->{'key'};
        my $label = $generic_data_set->{'label'};
        my @set = ();
        foreach my $hash (@{$list_ref}) {
            $last_value = 0 if not defined $last_value; # avoid entry spike
            $last_value = 0 if $hash->{"generic"}->{$key} < $last_value; # never drop values into the negative range.
            push @set, {time => $hash->{date}, value => $hash->{'generic'}->{$key}};
            $last_value = $hash->{'generic'}->{$key};
            }
           $self->{chart}->add_data(\@set, {label => $label, style => 'line', color => shift @{$self->{colorset_ref}}}); 
        }
	return $self->{chart};
}
1;
