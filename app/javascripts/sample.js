//= require <o3d>

o3djs.base.o3d = o3d;
o3djs.require('o3djs.webgl');
o3djs.require('o3djs.math');
o3djs.require('o3djs.rendergraph');
o3djs.require('o3djs.primitives');
o3djs.require('o3djs.material');


// Events
// init() once the page has finished loading.
window.onload = initClient;

// global variables
// we make these global so we can easily access them from the debugger.
var g_o3dElement;
var g_client;
var g_o3d;
var g_math;
var g_pack;
var g_viewInfo;
var g_eyePosition = [3, 4, 14];

var g_cube, g_sphere, gc_transform, gs_transform;
var sloc = [1, 0, 0];
var cloc = [0, -2, 0];
var svel = [0, 0, 0];
var cvel = [0, 0, 0];


/**
 * Creates the client area.
 */
function initClient() {
  o3djs.webgl.makeClients(main);
}

/**
 * Initializes global variables, positions camera, draws shapes.
 * @param {Array} clientElements Array of o3d object elements.
 */
function main(clientElements) {
  // Init global variables.
  initGlobals(clientElements);

  // Set up the view and projection transformations.
  initContext();

  // Add the shapes to the transform heirarchy.
  createShapes();

  setInterval(move, 80);
}

/**
 * Initializes global variables and libraries.
 */
function initGlobals(clientElements) {
  g_o3dElement = clientElements[0];
  window.g_client = g_client = g_o3dElement.client;
  g_o3d = g_o3dElement.o3d;
  g_math = o3djs.math;

  // Create a pack to manage the objects created.
  g_pack = g_client.createPack();

  // Create the render graph for a view.
  g_viewInfo = o3djs.rendergraph.createBasicView(
      g_pack,
      g_client.root,
      g_client.renderGraphRoot);
}

/**
 * Sets up reasonable view and projection matrices.
 */
function initContext() {
  // Set up a perspective transformation for the projection.
  g_viewInfo.drawContext.projection = g_math.matrix4.perspective(
      g_math.degToRad(30), // 30 degree frustum.
      g_o3dElement.clientWidth / g_o3dElement.clientHeight, // Aspect ratio.
      1,                  // Near plane.
      5000);              // Far plane.

  // Set up our view transformation to look towards the world origin where the
  // primitives are located.
  g_viewInfo.drawContext.view = g_math.matrix4.lookAt(
      g_eyePosition,   // eye
      [0, 0, 0],       // target
      [0, 1, 0]);      // up
}

/**
 * Creates a material based on the given single color.
 * @param {!o3djs.math.Vector4} baseColor A 4-component vector with
 *     the R,G,B, and A components of a color.
 * @return {!o3d.Material} A phong material whose overall pigment is
 *     baseColor.
 */
function createMaterial(baseColor) {
  // Create a new, empty Material object.
  return o3djs.material.createBasicMaterial(g_pack, g_viewInfo, baseColor);
}

/**
 * Creates shapes using the primitives utility library, and adds them to the
 * transform graph at the root node.
 */
function createShapes() {
  var cube = o3djs.primitives.createCube(
      g_pack,
      createMaterial([0,1,0,1]), // A green phong-shaded material.
      Math.sqrt(2));                  // The length of each side of the cube.

  var sphere = o3djs.primitives.createSphere(
      g_pack,
      createMaterial([1,0,0,1]),
      1.0,   // Radius of the sphere.
      30,    // Number of meridians.
      20);   // Number of parallels.
  g_sphere = sphere;
  g_cube = cube;
  // Add the shapes to the transforms.
  var transformTable = [
    {shape: cube, translation: cloc},
    {shape: sphere, translation: sloc}
  ];

  for (var tt = 0; tt < transformTable.length; ++tt) {
    var transform = g_pack.createObject('Transform');
    transform.addShape(transformTable[tt].shape);
    transform.translate(transformTable[tt].translation);
    transform.parent = g_client.root;
    if (tt == 0) {
      gs_transform = transform;
    } else {
      gc_transform = transform;
    }
  }
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

  gc_transform.translate(svel[0] * t, svel[1] * t, svel[2] * t);
  gs_transform.translate(cvel[0] * t, cvel[1] * t, cvel[2] * t);
}
