#!/usr/bin/perl
#
# A script to return the button values for a given button on the apex remote

use strict;
use warnings;
use LWP::UserAgent;
use CGI;
use Data::Dumper;
use Time::HiRes qw(usleep);

#use credentials;
use credentials;

my $id = $credentials::id;
my $token = $credentials::token;
my $home_ip = $credentials::home_ip;

my $q = CGI->new;
my $button = $q->param('button');
my $clicks = $q->param('clicks');

my $source_ip = $ENV{HTTP_X_FORWARDED_FOR};
my $remote_ip = $ENV{REMOTE_ADDR};

my $ua = LWP::UserAgent->new;
my $function = "input";

my $url =  "https://api.spark.io/v1/devices/$id/$function";

my %apex_buttons = (
	'power' =>	'FE50AF',
	'display' =>	'FE9A65',
	'tv' =>		'FE807F',
	'hdmi' =>	'FE20DF',
	'comp' =>	'FEB04F',
	'av' =>		'FEA05F',
	'vga' =>	'FE10EF',
	'chlist' =>	'FE52AD',
	'guide' =>	'FEBA45',
	'fav' =>	'FE2AD5',
	'freeze' =>	'FE08F7',
	'picture' =>	'FE728D',
	'temp' =>	'FE906F',
	'up' =>		'FE7A85',
	'left' =>	'FEDA25',
	'enter' =>	'FE0AF5',
	'right' =>	'FE1AE5',
	'down' =>	'FE6A95',
	'exit' =>	'FE32CD',
	'return' =>	'FE9867',
	'sleep' =>	'FEAA55',
	'menu' =>	'FE5AA5',
	'zoom' =>	'FEEA15',
	'volup' =>	'FE7887',
	'voldown' =>	'FEFA05',
	'last' =>	'FED827',
	'mute' =>	'FED02F',
	'chup' =>	'FEF807',
	'chdown' =>	'FE3AC5',
	'1' =>		'FE708F',
	'2' =>		'FE609F',
	'3' =>		'FEF00F',
	'4' =>		'FE48B7',
	'5' =>		'FEE01F',
	'6' =>		'FEC837',
	'7' =>		'FE6897',
	'8' =>		'FE40BF',
	'9' =>		'FEE817',
	'dash' =>	'FEC03F',
	'0' =>		'FE58A7',
	'input' =>	'FECA35',
	'audio' =>	'FED22D',
	'mts' =>	'FE4AB5',
	'ccd' =>	'FE8A75',
);

my $code = hex $apex_buttons{$button};

my $delay_ms = 300;
$delay_ms = 6000 if $button eq 'hdmi';

if ($remote_ip eq $home_ip || $source_ip eq $home_ip){
	for my $i (1..$clicks){
		$ua->post($url, ['access_token' => $token, 'args' => $code]);
		#print "Sent the request\n";
		usleep(300);
	}
}

print "Content-type:text/html\n\n";
print $button;
print "<p>";
print $clicks;
print "<p>";
print "Source ip:  ".$source_ip;
print "<p>";
print "Remote ip:  ".$remote_ip;
