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
			value => $hash->{running_nodes},
		  };
          push @persistent_nodes,
          {
            time => $hash->{date},
            value => $hash->{persistent_nodes},
          };
          push @held_locks, 
          {
            time => $hash->{date},
            value => $hash->{held_locks},
          };
          push @known_tables, 
          {
            time => $hash->{date},
            value => $hash->{known_tables},
          };
          push @running_transactions, 
          {
            time => $hash->{date},
            value => $hash->{running_transactions},
          };
      }
    $self->{chart}->add_data( \@running_nodes, { label => 'Running mnesia nodes', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@persistent_nodes, { label => 'Persistent mnesia nodes', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@held_locks, { label => 'Locks held by the transaction manager', 
            style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@known_tables, { label => 'Known tables', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@running_transactions, { label => 'Running transactions', style => 'line', color => shift @{$self->{colorset_ref}} } );
}
1;
