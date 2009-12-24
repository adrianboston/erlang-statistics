package Stat::LoadedModules;
use base 'Stat::Base';
use strict;
use warnings;

sub process {
	my $self     = shift;
	my $list_ref = shift;
    my @modules_loaded;
    foreach my $hash ( @{$list_ref} ) {
          push @modules_loaded, 
          {
            time => $hash->{date},
            value => $hash->{modules_loaded},
          };
      }
	
    $self->{chart}->add_data( \@modules_loaded, { label => 'Loaded modules on this node', style => 'line', color => shift @{$self->{colorset_ref}} } );
}
1;
