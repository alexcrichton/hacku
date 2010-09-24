# Artist Relevance

## Relevance Database

Given a list of artist names, return a JSON encoded string which represents an array of the form:

<pre>
{
  'images' => {
    'artist1' => 'http://image',
    'artist2' => 'http://image2',
    ...
  },
  'artists' => ['artist1', 'aritst2', ...],
  'similarities' => [
    ['artist1', 'artist2', simliarity1],
    ['artist1', 'artist3', similarity2],
    ...
  ]
}
</pre>

Where `relevance` is a float 0-1 where 0 is not related at all and 1 is virtually the same artist. This list should never have `artistID1 = artistID2`.

This program prints to `STDOUT`

### last.fm similar artists

They have a web service which gives similar artists to a given artist and also gives you a score for the similarity.

We can access this through YQL through the `lastfm.artist.getsimilar` table with the following [query](http://developer.yahoo.com/yql/console/?q=show%20tables&env=store://datatables.org/alltableswithkeys#h=select%20*%20from%20lastfm.artist.getsimilar%20where%20api_key%3D%222116c8771c6a03bb89c24a0935bea3a4%22%20and%20artist%3D%22Lady%20Gaga%22%20and%20limit%3D%221000%22):

<pre>
select * from lastfm.artist.getsimilar where api_key="2116c8771c6a03bb89c24a0935bea3a4" and artist="Lady Gaga" and limit="1000"
</pre>

The `limit="1000"` doesn't actually give 1000 artists, but it gives 250 it looks like. This should be sufficient for our purposes.

I was thinking that because this service is slow (0.5s for each request) we could cache results in our own database for the hackathon and that way have a speedier demo when we ask about a lot of artists

## Physics JS

Simulator for physics in the javascript.

The model will be as follows:

* There is a central point everything is connected to with a spring with a  pre-defined spring constant.
* Every node then repels each other node with a force inversely proportional to the relevance of the two objects
* All points start at random locations on a sphere with a certain radius

Then we hit go. The function `move()` will be as follows:

* Global arrays:
  * `objs`: an array of yahoo IDs for each artist. The position of the ID in this array represents the position in the following arrays.
  * `pos`: an array of 3 element arrays where `x_i` is the position of the `i`'th object in space
  * `veloc`: an array of 3 element arrays where `v_i` is the components of the velocity of the `i`'th element.
  * `relevance`: this is a hash which stores all the relevances between two objects. `relevance[i][j]` only works if `i < j` and will give you the relevance between `i` and `j`

* The location array is initialized randomly and the velocity array is initially all 0.

* `move()` will be called every so often and it will represent a time lapse of some number of seconds.

  * Upon calling move, all of the object's locations will be updated according to the springs/repulsions.
  * The arrays `pos` and `veloc` must be updated

## Web Server

This does things, flesh this out more

## Artist Fetching

People have artists on facebook. This is awesome and we should use this. You enter in a bunch of usernames and you get all of the artists of the users and do fancy stuff with them.

This needs to be a function which takes a list of facebook usernames and then gives a mapping of username to list of artists listed on facebook:

<pre>
  function(['alex.crichton', 'kellyhope'])
    # then yields:
  {
    'alex.crichton' => ['goats', 'more goats', 'GHB', ...],
    'kellyhope'     => ['awful artists 1', 'Fall Out Boy', ...]
  }
</pre>

## Possible Extensions

1. Get a list of artists from a service (uploaded, last.fm, pandora?) and show how they group together
2. Get a list of artists for you and your friends, color code all the objects, then see where the equilibrium is to find your similar artist tastes.
3. Given an artist, show similar artists about them.
