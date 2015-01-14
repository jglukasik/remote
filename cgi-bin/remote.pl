#!/usr/bin/perl
#
# A script to return the button values for a given button on the apex remote

use strict;
use warnings;
use LWP::UserAgent;
use CGI;
use Data::Dumper;
use Time::HiRes qw(usleep);

print "Content-type: text/plain\n\n";

use credentials;
my $id = $credentials::id;
my $token = $credentials::token;
my $home_ip = $credentials::home_ip;

use insignia_codes;
my %buttons = %insignia_codes::buttons;

my $q = CGI->new;
my $action = $q->param('action');
my $count= $q->param('count');

my $source_ip = $ENV{HTTP_X_FORWARDED_FOR};
my $remote_ip = $ENV{REMOTE_ADDR};

if ($remote_ip eq $home_ip || $source_ip eq $home_ip){
	&take_action($action, $count);
}

sub take_action {
	my ($action, $count) = @_;
	my $vol_delay = 300;
	my $input_delay = 1500000;
	
	my $ua = LWP::UserAgent->new;
  my $function = "input";
 
  if ($count == 0) {
    $function = "test";
  }

	my $url = "https://api.spark.io/v1/devices/$id/$function";
	
	my %actions = 
		( "power" 	    =>	["power"]
		, "tv"  		    => 	["tv"]
		, "wii"	  	    => 	["av"]
		, "chromecast"	=>	["tv", "hdmi"]
		, "xbox"  	    => 	["tv", "hdmi", "hdmi"]
		, "laptop"	    => 	["tv", "hdmi", "hdmi", "hdmi"]
		, "volup"	      => 	["volup"]
		, "voldown"	    => 	["voldown"]
		, "mute"	      => 	["mute"]
    , "input"       =>  ["input", "input", "enter"]
		);
	
	if ($action =~ /^vol/){
		my $code = hex $buttons{$action};
		for my $i (0..$count){
			$ua->post($url, ['access_token' => $token, 'args' => $code]);
			usleep($vol_delay);
		}
	} else {
		for my $i (0..$#{ $actions{$action} }){
			my $button = $actions{$action}[$i];
			my $code = hex $buttons{$button};
			$ua->post($url, ['access_token' => $token, 'args' => $code]);
			usleep($input_delay);
		}
	}
}
