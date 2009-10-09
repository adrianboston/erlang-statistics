package Stat::RamUsage;
use base 'Stat::Base';
use strict;
use warnings;

sub process {
	my $self     = shift;
	my $list_ref = shift;

	my @total = generate_set($list_ref, "total");
    my @processes = generate_set($list_ref, "processes");
    my @system = generate_set($list_ref, "system");
    my @atom = generate_set($list_ref, "atom");
    my @atom_used = generate_set($list_ref, "atom_used");
    my @binary = generate_set($list_ref, "binary");
    my @code = generate_set($list_ref, "code");
    my @ets = generate_set($list_ref, "ets");

	$self->{chart}->add_data( \@total, { label => 'Total memory', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@processes, { label => 'Process memory', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@system, { label => 'System memory', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@atom, { label => 'Atom memory', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@atom_used, { label => 'Used atom memory', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@binary, { label => 'Binary memory', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@code, { label => 'Code memory', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@ets, { label => 'ets memory', style => 'line', color => shift @{$self->{colorset_ref}} } );


}

sub generate_set {
    my $list_ref = shift;
    my $what = shift;
    my @set;
    foreach my $hash (@{$list_ref}){
        push @set,
        {
            time => $hash->{date},
            value => $hash->{memory_usage}->{$what},
        }
    }
    @set
}
1;
