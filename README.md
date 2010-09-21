# Artist Relevance

## Relevance Database

Given a list of artist IDs (all Yahoo IDs), return a JSON encoded string which represents an array of the form:

<pre>
[
  [artistXID1, artistYID2, relevance],
  [artistAID1, artistBID2, relevance],
  ...
]
</pre>

Where `relevance` is a float 0-100 where 0 is not related at all and 100 is virtually the same artist. This list should never have `artistID1 = artistID2`.

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

## Photo Fetching

We need a photo for each artist, this is a function which when given a list of yahoo IDs of artists, it will return a list of URLs to the photos of the artists in the same order as provided, JSON encoded.

