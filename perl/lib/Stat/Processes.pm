package Stat::Processes;
use base 'Stat::Base';
use strict;
use warnings;

sub process {
	my $self     = shift;
	my $list_ref = shift;
	my @processes;
	my @ports;
    my @process_limit;
    my @switches;
    my $last_switches = 0;
    foreach my $hash ( @{$list_ref} ) {
		push @processes,
		  {
			time  => $hash->{date},
			value => $hash->{process_count},
		  };
          push @process_limit,
          {
            time => $hash->{date},
            value => $hash->{process_limit},
          };
          push @ports, 
          {
            time => $hash->{date},
            value => $hash->{ports},
          };
	      if($hash->{context_switches} - $last_switches < 0) {
            # server got restarted, reset $last_switches.
            $last_switches = 0;
          }
          push @switches,
          {
            time => $hash->{date},
            value => $hash->{context_switches} - $last_switches
          };
          $last_switches = $hash->{context_switches};
      
      
      
      }
	
    $self->{chart}->add_data( \@processes, { label => 'Processes', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@process_limit, { label => 'Process limit', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@ports, { label => 'ports', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@switches, { label => 'Context switches', style => 'line', color => shift @{$self->{colorset_ref}} } );
    #$self->{chart}->add_data( \@processes, { label => 'Processes', style => 'line', color => shift @{$self->{colorset_ref}} } );
    #$self->{chart}->add_data( \@processes, { label => 'Processes', style => 'line', color => shift @{$self->{colorset_ref}} } );
}
1;
