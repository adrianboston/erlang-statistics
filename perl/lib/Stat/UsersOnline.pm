package Stat::UsersOnline;
use base 'Stat::Base';
use strict;
use warnings;

sub process {
	my $self     = shift;
	my $list_ref = shift;
	my @users_today;
	my @users_idle;
	foreach my $hash ( @{$list_ref} ) {
		push @users_today,
		  {
			time  => $hash->{time},
			value => $hash->{userOnline},
		  };
		push @users_idle,
		  {
			time  => $hash->{time},
			value => $hash->{userOnline} - $hash->{idleUsers},
		  };
	}
	$self->{chart}->add_data( \@users_today, { label => 'Nutzer', style => 'line', color => shift @{$self->{colorset_ref}} } );
	$self->{chart}->add_data( \@users_idle, { label => 'Aktive Chatter', style => 'filled', color => shift @{$self->{colorset_ref}} } );
}
1;

