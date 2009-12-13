package Stat::Mnesia;
use base 'Stat::Base';
use strict;
use warnings;

sub process {
	my $self     = shift;
	my $list_ref = shift;
    my @running_nodes;
    my @persistent_nodes;
    my @held_locks;
    my @known_tables;
    my @running_transactions;
    foreach my $hash ( @{$list_ref} ) {
		  push @running_nodes,
		  {
			time  => $hash->{date},
			value => defined $hash->{running_nodes} ? $hash->{running_nodes} : 0,
		  };
          push @persistent_nodes,
          {
            time => $hash->{date},
            value => defined $hash->{persistent_nodes} ? defined $hash->{persistent_nodes} : 0,
          };
          push @held_locks, 
          {
            time => $hash->{date},
            value => defined $hash->{held_locks} ? $hash->{held_locks} : 0,
          };
          push @known_tables, 
          {
            time => $hash->{date},
            value => defined $hash->{known_tables} ? $hash->{known_tables} : 0,
          };
          push @running_transactions, 
          {
            time => $hash->{date},
            value => defined $hash->{running_transactions} ? $hash->{running_transactions} : 0,
          };
      }
    $self->{chart}->add_data( \@running_nodes, { label => 'Running mnesia nodes', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@persistent_nodes, { label => 'Persistent nodes', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@held_locks, { label => 'Locks held by the manager', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@known_tables, { label => 'Known tables', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@running_transactions, { label => 'Running transactions', style => 'line', color => shift @{$self->{colorset_ref}} } );
}
1;
