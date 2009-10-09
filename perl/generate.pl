#!/usr/bin/perl

use strict;
use warnings;
use lib 'lib';
use Stat::RamUsage;
use Stat::IO;


use JSON;

################# CONFIG #############

my $STATFILE = "../erlang/stats.jsn";
my $OUTPUT_DIR = ".";
my $FORMAT = "png";

my %margin_opts = (    # general styling options
	margin_left   => 15,
	margin_bottom => 10,
	margin_right  => 0,
	margin_top    => 4,
	width         => 770,
	height        => 250,
);

my %ram_usage_opts = (
	'y_label'        => 'Memory usage (bytes)',
	draw_tic_labels  => 1,
	draw_data_labels => 1,
	thickness        => 2,
	draw_grid        => 1,
	draw_border      => 0,
	x_label          => 'Time',
	data_label_style => 'box',
	binary           => 1,
	%margin_opts,
);

my %io_opts = (
	'y_label'        => 'Overall Input/Output (Bytes/Time)',
	draw_tic_labels  => 1,
	draw_data_labels => 1,
	thickness        => 2,
	draw_grid        => 1,
	draw_border      => 0,
	x_label          => 'Zeit',
	binary           => 1,
	data_label_style => 'box',
	%margin_opts,
);


my @colorset = qw/000077 ef8b2f 7bcf6f cccccc 2b9842 b9cb33 666666 cf6f6f 6f7bcf 6fcfc8 cfc66f/;

############################## START MAINLINE ##############################
# this is the part you want to extend if you want more different charts.

print "[*] Starting statfile parsing\n";
my $dataset_ref = read_stats($STATFILE);

print "[*] Generating RamUsage chart\n";
my $ram_usage = Stat::RamUsage->new( \@colorset, \%ram_usage_opts );
$ram_usage->process( $dataset_ref );
$ram_usage->write_png( $OUTPUT_DIR . "/ram-usage-vs-time.png" );

print "[*] Generationg IO chart\n";
my $io = Stat::IO->new( \@colorset, \%io_opts );
$io->process($dataset_ref);
$io->write_png( $OUTPUT_DIR . "/io-vs-time.png" );
print "[*] Done.\n";













############################## START FUNCTIONS #############################
sub read_stats {
	my $stat_file = shift;
	my @slurp;
	open my $handle, '<', $stat_file or die "Couldn't open $stat_file for reading: $!";
	@slurp = <$handle>;
	close $handle;
	map { $_ = decode_json $_ } @slurp;
	return \@slurp;
}

