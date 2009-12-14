package Stat::Transactions;
use base 'Stat::Base';
use strict;
use warnings;

sub process {
	my $self     = shift;
	my $list_ref = shift;
    
    my @transaction_commits;
    my $last_transaction_commits = 0;
    my @transaction_failures;
    my $last_transaction_failures = 0;
    my @transaction_log_writes;
    my $last_transaction_log_writes = 0;
    my @transaction_restarts;
    my $last_transaction_restarts = 0;

    foreach my $hash ( @{$list_ref} ) {
          no warnings;
          $last_transaction_commits = 0 
            if $hash->{transaction_commits} - $last_transaction_commits < 0;
          $last_transaction_failures = 0
            if $hash->{transaction_failures} - $last_transaction_failures < 0;
          $last_transaction_log_writes = 0
            if $hash->{transaction_log_writes} - $last_transaction_log_writes < 0;
          $last_transaction_restarts = 0
            if $hash->{transaction_restarts} - $last_transaction_restarts < 0;
          
            push @transaction_commits,
		  {
			time  => $hash->{date},
			value => $hash->{transaction_commits} - $last_transaction_commits,
		  };
          push @transaction_failures,
          {
            time => $hash->{date},
            value => $hash->{transaction_failures} - $last_transaction_failures,
          };
          push @transaction_log_writes, 
          {
            time => $hash->{date},
            value => $hash->{transaction_log_writes} - $last_transaction_log_writes,
          };
          push @transaction_restarts, 
          {
            time => $hash->{date},
            value => $hash->{transaction_restarts} - $last_transaction_restarts,
          };
      }
    $self->{chart}->add_data( \@transaction_commits, { label => 'Comitted transactions', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@transaction_failures, { label => 'Failed transactions',
            style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@transaction_restarts, { label => 'Restarted transactions', style => 'line', color => shift @{$self->{colorset_ref}} } );
    $self->{chart}->add_data( \@transaction_log_writes, { label => 'Transaction log writes', 
            style => 'line', color => shift @{$self->{colorset_ref}} } );
}
1;
