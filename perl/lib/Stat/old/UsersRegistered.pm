package Stat::UsersRegistered;
use base 'Stat::Base';
use strict;
use warnings;

sub process {
	my $self     = shift;
	my $list_ref = shift;
	my @users;
	foreach my $hash ( @{$list_ref} ) {
		push @users,
		  {
			time  => $hash->{time},
			value => $hash->{regUsers},
		  };
	}
	$self->{chart}->add_data( \@users, { label => 'Nutzer', style => 'line', color => shift @{$self->{colorset_ref}} } );
}
1;