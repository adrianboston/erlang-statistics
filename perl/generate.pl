#!/usr/bin/perl

use strict;
use warnings;
use lib 'lib';
use JSON;
use Benchmark ':hireswallclock';

die "This script needs exactly one argument. Usage: `perl generate.pl config.jsn`" unless @ARGV == 1;

################# CONFIG #############

my %default_style_opts = (    # general styling options
	margin_left   => 15,
	margin_bottom => 10,
	margin_right  => 0,
	margin_top    => 4,
	width         => 770,
	height        => 250,

	'y_label'        => 'Default Label',
	draw_tic_labels  => 1,
	draw_data_labels => 1,
	thickness        => 2,
	draw_grid        => 1,
	draw_border      => 0,
	x_label          => 'Time',
	data_label_style => 'box',
);

############## PARSING CONFIGFILE ##############
my $config = parse_config(shift @ARGV);

# checking wether fast json via XS is enforced
die "[E] Fast JSON::XS backend for JSON parsing is not available, but config enforces the use of a fast backend."
    if JSON->backend ne "JSON::XS" and $config->{enforce_fast_json};

############## PARSING STATFILE ################
print "[*] Starting statfile parsing\n";
my $stats;
my $time = timeit(1, sub {
        $stats = read_stats($config->{statfile});
    });
print "[*] Done parsing statfile. \n\tParsing took " . timestr($time) . "\n";

############## STARTING OUTPUT ##################
print "[*] Start plotting...\n";
sub plot_dataset {
    foreach my $object (@{$config->{statistics}}) {
        print "\t~> Plotting " . $object->{class} . "   ->   " . $object->{filename} . "\n";
        my $class = "Stat::" . $object->{class};
        require "Stat/" . $object->{class} . ".pm";
        my %styleopts = (%default_style_opts, %{$object->{style_options}});
        my $plotter = $class->new($config->{colorset}, \%styleopts);
        $plotter->process($stats);
        if($config->{output_format} eq "png"){
            $plotter->write_png($object->{filename});
        }
        else {
            $plotter->write_jpg($object->{filename});
        }
    }
}
$time = timeit(1, \&plot_dataset);
print "[*] Done plotting all charts.\n\tOverall plotting time: " . timestr($time) . "\n";


############## START ASSISTANT FUNCTIONS ################
sub parse_config {
    my $file = shift;
    my $content = do 
                { 
                    local $/ = undef;
                    open my $fh, '<', $file or die "[E] Couldn't open $file for reading: $!";
                    <$fh>;
                };
    from_json $content;
}
sub read_stats {
	my $stat_file = shift;
	my @slurp;
	open my $handle, '<', $stat_file or die "[E] Couldn't open $stat_file for reading: $!";
	@slurp = <$handle>;
	close $handle;
	map { $_ = decode_json $_ } @slurp;
	return \@slurp;
}

