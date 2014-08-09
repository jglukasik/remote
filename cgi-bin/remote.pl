#!/usr/bin/perl
#
# A script to return the button values for a given button on the apex remote

use strict;
use warnings;
use LWP::UserAgent;
use CGI;
use Data::Dumper;
use Time::HiRes qw(usleep);

use credentials;
my $id = $credentials::id;
my $token = $credentials::token;
my $home_ip = $credentials::home_ip;

use apex_codes;
my %buttons = %apex_codes::buttons;

my $q = CGI->new;
my $action = $q->param('action');
my $clicks = $q->param('clicks');

my $source_ip = $ENV{HTTP_X_FORWARDED_FOR};
my $remote_ip = $ENV{REMOTE_ADDR};

my $ua = LWP::UserAgent->new;
my $function = "input";

if ($remote_ip eq $home_ip || $source_ip eq $home_ip){
  &take_action($action, $clicks);
}

print "Content-type:text/html\n\n";
print $button;
print "<p>";
print $clicks;
print "<p>";
print "Source ip:  ".$source_ip;
print "<p>";
print "Remote ip:  ".$remote_ip;

sub take_action {
  my $vol_delay = 300;
  my $input_delay = 600;
  my $url = "https://api.spark.io/v1/devices/$id/$function";

  my %actions = (
   "power" => ("power");
   "tv" => ("tv");
   "chromecast" => ("tv", "hdmi");
   "laptop" => ("tv", "hdmi", "hdmi");
   "xbox" => ("tv", "hdmi", "hdmi", "hdmi");
   "volup" => ("volup");
   "voldown" => ("voldown");
   "mute" => ("mute");
  }

  my $action = $_;

  if ($action =~ /^vol/){
    my $clicks = $_;
    my $code = $buttons{$actions};

    for my $i (0..$clicks){
		  $ua->post($url, ['access_token' => $token, 'args' => $code]);
      usleep($vol_delay);
    }
  } else {
    foreach my $button (@actions{$action}){
      my $code = $buttons{$button};
		  $ua->post($url, ['access_token' => $token, 'args' => $code]);
      usleep($input_delay);
    }
  }
}








