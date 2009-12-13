package Stat::General;
use base 'Stat::Base';
use strict;
use warnings;

sub process {
	my $self     = shift;
	my $list_ref = shift;
	my @running_queue;
	my @nodes;
    my @modules_loaded;
    foreach my $hash ( @{$list_ref} ) {
		  push @running_queue,
		  {
			time  => $hash->{date},
			value => $hash->{running_queue},
		  };
          push @nodes,
          {
            time => $hash->{date},
            value => $hash->{nodes},
          };
          push @modules_loaded, 
          {
            time => $hash->{date},
            value => $hash->{modules_loaded},
          };
      }
	
    $self->{chart}->add_data( \@running_queue, { label => 'Queued Processes', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@nodes, { label => 'Nodes in the network', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@modules_loaded, { label => 'loaded modules', style => 'line', color => shift @{$self->{colorset_ref}} } );
}
1;
