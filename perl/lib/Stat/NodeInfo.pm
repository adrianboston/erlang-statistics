package Stat::NodeInfo;
use base 'Stat::Base';
use strict;
use warnings;

sub process {
	my $self     = shift;
	my $list_ref = shift;
	my @nodes;
    foreach my $hash ( @{$list_ref} ) {
          push @nodes,
          {
            time => $hash->{date},
            value => $hash->{nodes},
          };
      }
	
    $self->{chart}->add_data( \@nodes, { label => 'Nodes in this network', style => 'line', color => shift @{$self->{colorset_ref}} } );
}
1;
