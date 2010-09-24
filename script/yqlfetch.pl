#!/usr/bin/perl

use strict;
use warnings;
use WebService::YQL;
use XML::Simple;
use Encode;

die "Incorrect number of arguments submitted to yqlfetch.pl.\n" unless ($#ARGV == 0);

my $yql = WebService::YQL->new(env => 'http://datatables.org/alltables.env');

# pick up an image for artist1
my $artist1 = $ARGV[0];
my $image_query = "select * from lastfm.artist.getimages where api_key = \'2116c8771c6a03bb89c24a0935bea3a4\' and artist = \'" . $artist1 . "\'";
my $image_data = $yql->query($image_query);
my @image_set = @{ $image_data->{'query'}{'results'}{'lfm'}{'images'}{'image'} };
my $image1 = "";
if ($#image_set >= 0) {
     $image1 = $image_set[0]->{'url'};
}

# grab artists similar to artist1
my $match_query = "select * from lastfm.artist.getsimilar where api_key = \"2116c8771c6a03bb89c24a0935bea3a4\" and limit = \"1000\" and artist = \'" . $artist1 . "\'";
my $data = $yql->query($match_query);

# these strings compose our final JSON output
my $images = "{\n\'images\' => {\n  \'" . $artist1 . " => \'" . $image1 . "\'\n";
my $artists = "},\'artists\' => [\'" . $artist1 . "\'";
my $match = "],\'similarities\' => [";
my $foot = "]}\n";

# modify JSON output to include all artists
my @sim_data = @{ $data->{'query'}{'results'}{'lfm'}{'similarartists'}{'artist'} };
shift @sim_data;
for my $sim_artist (@sim_data) {
     $images .= "\'" . $sim_artist->{'name'} . "\' => \'";
     $images .= @{ $sim_artist->{'image'}}[0]->{'content'} . "\',\n";
     $artists .= ", \'" . $sim_artist->{'name'} . "\'";
     $match .= "[\'" . $artist1 . "\', \'" . $sim_artist->{'name'};
     $match .= "\', \'" . $sim_artist->{'match'} . "\'],\n ";
}

print decode_utf8($images);
print decode_utf8($artists);
print decode_utf8($match);
print decode_utf8($foot);
     
