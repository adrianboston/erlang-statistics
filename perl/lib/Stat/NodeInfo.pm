package Stat::NodeInfo;
use base 'Stat::Base';
use strict;
use warnings;

sub process {
	my $self     = shift;
	my $list_ref = shift;
	my @nodes;
    my @modules_loaded;
    foreach my $hash ( @{$list_ref} ) {
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
	
    $self->{chart}->add_data( \@nodes, { label => 'Nodes in this network', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@modules_loaded, { label => 'Loaded modules on this node', style => 'line', color => shift @{$self->{colorset_ref}} } );
}
1;
