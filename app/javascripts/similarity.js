//= require <o3d>
//= require <yui>

o3djs.base.o3d = o3d;
o3djs.require('o3djs.webgl');
o3djs.require('o3djs.math');
o3djs.require('o3djs.rendergraph');
o3djs.require('o3djs.primitives');
o3djs.require('o3djs.material');
o3djs.require('o3djs.io');

// global variables
var g_o3dElement;
var g_client;
var g_o3d;
var g_math;
var g_pack;
var g_viewInfo;
var g_eyePhi = Math.PI / 6, g_eyeTheta = Math.PI / 2;
var samplers = [], transforms = [];
var locs = [];
var vels = [];
var images, similarities, artists;
var mouseX, mouseY, mouseDown;

/**
 * Creates the client area.
 */
function initClient(hash) {
  images            = hash.images;
  similarities      = hash.similarities;
  artists           = hash.artists;

  for (var i = 0; i < artists.length; i++) {
    vels.push([0, 0, 0]);

    var vec = [Math.random() - 0.5, Math.random() - 0.5, Math.random() - 0.5];
    var mag = Math.sqrt(vec[0] * vec[0] + vec[1] * vec[1] + vec[2] * vec[2]);

    locs.push([vec[0] / mag, vec[1] / mag, vec[2] / mag]);
  }

  window.g_finished = false;  // for selenium testing.
  o3djs.webgl.makeClients(main);
}

function setUpCameraDragging() {
  YUI().use('node', function(Y) {
    Y.one('#o3d').on('mousedown', function(e) {
      mouseDown = true;
    });
    Y.one('#o3d').on('mouseup', function(e) {
      mouseDown = false;
    });
    Y.one('#o3d').on('mousemove', function(e) {
      if (mouseDown) {
        var dx = e.clientX - mouseX;
        var dy = e.clientY - mouseY;

        g_eyeTheta = (g_eyeTheta + dy * 0.01) % (2 * Math.PI);
        g_eyePhi = (g_eyePhi + dx * 0.01) % (2 * Math.PI);

        g_viewInfo.drawContext.view = g_math.matrix4.lookAt(
            eyePosition(),   // eye
            [0, 0, 0],    // target
            [-1, 0, 0]);  // up
      }

      mouseX = e.clientX;
      mouseY = e.clientY;
    });
  });
}

function eyePosition() {
  var r = 13;
  var x = r * Math.cos(g_eyeTheta) * Math.sin(g_eyePhi);
  var y = r * Math.sin(g_eyeTheta) * Math.sin(g_eyePhi);
  var z = r * Math.cos(g_eyePhi);
  return [x, y, z];
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

  window.g_finished = true;  // for selenium testing.
  setInterval(move, 80);

  setUpCameraDragging();
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
      eyePosition(),   // eye
      [0, 0, 0],    // target
      [-1, 0, 0]);  // up
}

/**
 * Creates shapes using the primitives utility library, and adds them to the
 * transform graph at the root node.
 */
function createShapes() {
  var cubeEffect = g_pack.createObject('Effect');
  var vertexShaderString = document.getElementById('vshader').value;
  var pixelShaderString = document.getElementById('pshader').value;
  cubeEffect.loadVertexShaderFromString(vertexShaderString);
  cubeEffect.loadPixelShaderFromString(pixelShaderString);

  var funFactory = function(n) {
    return function(texture, exception) {
      if (exception) {
        alert(exception);
      } else {
        samplers[n].texture = texture;
      }
    }
  };

  for (var tt = 0; tt < artists.length; tt++) {
    var material      = g_pack.createObject('Material');
    material.drawList = g_viewInfo.performanceDrawList;
    material.effect   = cubeEffect;

    cubeEffect.createUniformParameters(material);

    // var sphere = o3djs.primitives.createSphere(
    //     g_pack,
    //     material,
    //     5.0,   // Radius of the sphere.
    //     20,    // Number of meridians.
    //     30);   // Number of parallels.
    var sphere = o3djs.primitives.createCube(
        g_pack,
        material, // A green phong-shaded material.
        1);                  // The length of each side of the cube.

    var transform = g_pack.createObject('Transform');
    transform.addShape(sphere);
    transform.translate(locs[tt]);
    transform.parent = g_client.root;
    transforms.push(transform);

    var sampler = g_pack.createObject('Sampler');
    sampler.minFilter = g_o3d.Sampler.ANISOTROPIC;
    sampler.maxAnisotropy = 4;
    material.getParam('texSampler0').value = sampler;
    samplers.push(sampler);

    o3djs.io.loadTexture(g_pack, images[artists[tt]], funFactory(tt));
  }
}

function move() {
  var t = 0.040; // 40 ms
  var x = 10;   // sprint constant
  var i, j, k;
  var accels = [];

  for (i = 0; i < transforms.length; i++) {
    var accel = [0, 0, 0];
    for (j = 0; j < transforms.length; j++) {
      for (k = 0; k < 3; k++) {
        accel[k] += (locs[j][k] - locs[i][k]) * x;
      }
    }

    accels.push(accel);
  }

  // Assume constant acceleration during this time
  for (i = 0; i < transforms.length; i++) {
    for (j = 0; j < 3; j++) {
      vels[i][j] += accels[i][j] * t;
    }
  }

  // Assume constant velocity
  for (i = 0; i < transforms.length; i++) {
    for (j = 0; j < 3; j++) {
      locs[i][j] += vels[i][j] * t;
    }
  }

  for (i = 0; i < transforms.length; i++) {
    transforms[i].translate(vels[i][0] * t, vels[i][1] * t, vels[i][2] * t);
  }
}
