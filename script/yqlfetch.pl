#!/usr/bin/perl

use strict;
use warnings;
use WebService::YQL;
use XML::Simple;
use Encode;

use constant DEFAULT_IMG => "http://www.mfu.ac.th/school/liberalarts/pics/unknown-person.gif";

my $multival_mode = 0;
if ($#ARGV > 0) {
    $multival_mode = 1;
}
elsif ($#ARGV < 0) {
    die "yqlfetch.pl called without arguments.\n";
}

my $yql = WebService::YQL->new(env => 'http://datatables.org/alltables.env');
my %rankings = (
    largesquare => 0,
    extralarge => 1,
    large => 2,
    original => 3,
    medium => 4,
    small => 5,
);

# these strings compose our final JSON output
my $images = "{\n  \'images\' => {\n";
my $artists = "  },\n  \'artists\' => [";
my $match = "],\n  \'similarities\' => [\n";
my $foot = " ]\n}\n";

if ($multival_mode) { multival(); } # we compare two artists
else { oneval(); }

print decode_utf8($images);
print decode_utf8($artists);
print decode_utf8($match);
print decode_utf8($foot);

# modify JSON output to include data for all artists
sub oneval
{
    # pick up an image for artist1
    my $artist1 = $ARGV[0];
    my $image1 = get_image_for_artist($artist1);

    # these strings compose our final JSON output
    $images .= "  \'" . $artist1 . " => \'" . $image1 . "\',\n";
    $artists .= "  \'" . $artist1 . "\'";

    my @sim_data = get_artist_sim_array($artist1);
    for my $sim_artist (@sim_data) {
  $images .= "    \'" . $sim_artist->{'name'} . "\' => \'";
  $images .= get_best_img('size', @{ $sim_artist->{'image'}}) . "\',\n";
  $artists .= ", \'" . $sim_artist->{'name'} . "\'";
  $match .= "    [\'" . $artist1 . "\', \'" . $sim_artist->{'name'};
  $match .= "\', \'" . $sim_artist->{'match'} . "\'],\n";
    }
}

# add to JSON output data for list of artists given
sub multival
{
    my @artist_keys = @ARGV;
    my %artists = ();

    for my $key (@artist_keys) {
  $artists{$key} = get_image_for_artist($key);
    }

    for my $artist (keys %artists) {
  $images .= "    \'" . $artist . "\' => \'" . $artists{$artist} . "\',\n";
  $artists .= "\'" . $artist . "\', ";

  my @sim_data = get_artist_sim_array($artist);
  for my $sim_artist (@sim_data) {
      if (exists ($artists{$sim_artist->{'name'}})) {
    $match .= "    [\'" . $artist . "\', \'" . $sim_artist->{'name'};
    $match .= "\', \'" . $sim_artist->{'match'} . "\'],\n";
      }
  }
    }
}

# images are ranked by preferred size. Set to best size or default image.
sub get_best_img
{
    return DEFAULT_IMG unless ($#_ >= 0);

    my $sizename = shift @_;
    my $curr_img = DEFAULT_IMG;
    my $curr_rank = 10;
    for my $img (@_) {
        if (exists($rankings{ $img->{$sizename} })
      && $rankings{$img->{$sizename}} < $curr_rank
      && exists($img->{'content'}) ) {
            $curr_img = $img->{'content'};
      $curr_rank = $rankings{$img->{$sizename}};
      last if ($curr_rank == 0);
  }
    }
    return $curr_img;
}

# fetch artist images and return best
sub get_image_for_artist
{
    my $artist = shift @_;
    my $image_query = "select * from lastfm.artist.getimages where api_key = \'2116c8771c6a03bb89c24a0935bea3a4\' and limit=\"1\" and artist = \'" . $artist . "\'";
    my $image_data = $yql->query($image_query);
    my @image_set = @{ $image_data->{'query'}{'results'}{'lfm'}{'images'}{'image'}{'sizes'}{'size'} };
    return get_best_img('name', @image_set);
}

# fetch array of similar artists
sub get_artist_sim_array
{
    my $artist = shift @_;
    my $match_query = "select * from lastfm.artist.getsimilar where api_key = \"2116c8771c6a03bb89c24a0935bea3a4\" and limit = \"1000\" and artist = \'" . $artist . "\'";
    my $data = $yql->query($match_query);
    my @sim_data = @{ $data->{'query'}{'results'}{'lfm'}{'similarartists'}{'artist'} };
    shift @sim_data;
    return @sim_data;
}
