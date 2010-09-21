//= require <o3d>

o3djs.require('o3djs.simple');

// Events
// init() once the page has finished loading.
window.onload = init;

// global variables
// we make these global so we can easily access them from the debugger.
var g_simple;
var g_cube;
var g_sphere;
var g_finished = false;  // for selenium testing

var sloc = [40, 0, 0];
var cloc = [0, 40, 0];
var svel = [0, 0, 0];
var cvel = [0, 0, 0];

/**
 * Creates the client area.
 */
function init() {
  o3djs.util.makeClients(initStep2);
}

/**
 * Initializes our app.
 * @param {Array} clientElements Array of o3d object elements.
 */
function initStep2(clientElements) {
  // Initializes global variables and libraries.
  var o3dElement = clientElements[0];

  // Create an o3djs.simple object to manage things in a simple way.
  g_simple = o3djs.simple.create(o3dElement);

  // Create a cube.
  g_cube = g_simple.createCube(50);

  // You should now have a cube on the screen!
  // Examples of other commands you can issue (live from firebug if you want)
  //
  g_cube.transform.translate(cloc[0], cloc[1], cloc[2]);  // translate the cube.
  g_cube.setDiffuseColor(1, 0, 0, 1);  // make the cube red.
  // g_cube.loadTexture("http://someplace.org/somefile.jpg");  // now textured.
  // g_simple.setCameraPosition(200, 100, -50);  // move the camera
  
  // g_simple.setCameraTarget(0, 10, 0);  // move the camera's target
  // g_simple.setFieldOfView(30 * Math.PI / 180);  // change the field of view.
  g_sphere = g_simple.createSphere(35, 10);  // create a sphere.
  g_sphere.transform.translate(sloc[0], sloc[1], sloc[2]);
  //
  // Try typing these commands from firebug live!

  g_finished = true;  // for selenium testing.

  setInterval(move, 80);
}

function move() {
  var t = 0.010; // 40 ms
  var x = 1000;   // sprint constant

  var caccel = [
    (sloc[0] - cloc[0]) * x,
    (sloc[1] - cloc[1]) * x,
    (sloc[2] - cloc[2]) * x
  ];
  var saccel = [
    (cloc[0] - sloc[0]) * x,
    (cloc[1] - sloc[1]) * x,
    (cloc[2] - sloc[2]) * x
  ];

  // Assume constant acceleration during this time
  cvel[0] += caccel[0] * t;
  cvel[1] += caccel[1] * t;
  cvel[2] += caccel[2] * t;

  svel[0] += saccel[0] * t;
  svel[1] += saccel[1] * t;
  svel[2] += saccel[2] * t;

  // Assume constant velocity
  cloc[0] += cvel[0] * t;
  cloc[1] += cvel[1] * t;
  cloc[2] += cvel[2] * t;

  sloc[0] += svel[0] * t;
  sloc[1] += svel[1] * t;
  sloc[2] += svel[2] * t;

  g_sphere.transform.translate(svel[0] * t, svel[1] * t, svel[2] * t);
  g_cube.transform.translate(cvel[0] * t, cvel[1] * t, cvel[2] * t);
}
