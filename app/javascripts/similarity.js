//= require <o3d>
//= require <yui>

o3djs.base.o3d = o3d;
o3djs.require('o3djs.webgl');
o3djs.require('o3djs.math');
o3djs.require('o3djs.rendergraph');
o3djs.require('o3djs.primitives');
o3djs.require('o3djs.material');
o3djs.require('o3djs.io');
o3djs.require('o3djs.picking');

// global variables
var g_o3dElement;
var g_client;
var g_o3d;
var g_math;
var g_pack;
var g_viewInfo;
var g_eyePhi = Math.PI / 6, g_eyeTheta = Math.PI / 2;
var samplers = [], transforms = [], shapes = [];
var locs = [];
var vels = [];
var similar;
var x = 1000;
var images, artists;
var mouseX, mouseY, mouseDown;

/**
 * Creates the client area.
 */
function initClient(hash) {
  images            = hash.images;
  similar           = hash.similarities;
  artists           = hash.artists;

  for (var i = 0; i < artists.length; i++) {
	  vels.push([Math.random() * 5, Math.random() * 5, Math.random() * 5]);

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

      if (!mouseDown) {
        process(e._event.layerX, e._event.layerY);
      }
    });
  });
}

function process(x, y) {
  jQuery('#artists').html('');

  var h = jQuery('canvas').height();
  var w = jQuery('canvas').width();

  var ray = o3djs.picking.clientPositionToWorldRay(x, y, g_viewInfo.drawContext, w, h);

  var vec1 = ray.far, vec2 = ray.near;

  for (var i = 0; i < shapes.length; i++) {
    var vec1tmp = g_math.subVector(vec1, locs[i]);
    var vec2tmp = g_math.subVector(vec2, locs[i]);

    var info = shapes[i].elements[0].boundingBox.intersectRay(vec1tmp, vec2tmp);

    if (info.valid && info.intersected) {
      jQuery('#artists').append(' ' + artists[i]);
      console.log(artists[i]);
    }
  }
}

function eyePosition() {
  var r = 8;
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
      g_client.renderGraphRoot,
	  [1,1,1,0]);
  g_client.normalizeClearColorAlpha = false;
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
    };
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
        .25);                  // The length of each side of the cube.

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

    o3djs.io.loadTexture(g_pack, images[tt], funFactory(tt));
    shapes.push(sphere);
  }
}

function move(){
  var t = .05;
  var accels = [];
  var i, j, accel, posDiff, offsetDiff, force, forceVec, len;
  for(i = 0; i < transforms.length; i++){
    accel = [0, 0, 0];
    for(j = 0; j < transforms.length; j++){
      if(i == j) continue;
      posDiff = [0, 0, 0];
      for(k = 0; k < 3; k++){
        posDiff[k] = locs[i][k] - locs[j][k];
      }
      offset = Math.sqrt(Math.abs(posDiff[0]*posDiff[0]+posDiff[1]*posDiff[1]+posDiff[2]*posDiff[2]));
      offsetDiff = offset - (2 - similar[i][j]*1.95);
      force = (-1) * offsetDiff * x / 2;
      forceVec = [force*posDiff[0]/offset,force*posDiff[1]/offset,force*posDiff[2]/offset];
      accel[0] += forceVec[0];
      accel[1] += forceVec[1];
      accel[2] += forceVec[2];
    }
    accels.push(accel);
  }

  for (i = 0; i < transforms.length; i++) {
    for (var j = 0; j < 3; j++) {
      vels[i][j] += accels[i][j] * t;
	  vels[i][j] *= .6;
      locs[i][j] += vels[i][j] * t;
    }
    len = Math.sqrt(Math.abs(locs[i][0]*locs[i][0]+locs[i][1]*locs[i][1]+
                 locs[i][2]*locs[i][2]));
  if(len != 0) locs[i] = [ locs[i][0] / len , locs[i][1] / len ,
               locs[i][2] / len ];
  }

  for(i = 0; i < transforms.length; i++){
    transforms[i].localMatrix = g_math.matrix4.translation(locs[i]);
  }

  //if(x>0) x -= .0001;
  // console.log(x);

}

function debug_array(arr){
  console.log("start");
  for(var i = 0; i<arr.length; i++){
    for(var j = 0; j<arr[0].length;j++){
      console.log(arr[i][j]);
    }
    console.log("mid");
  }
  console.log("stop");
}
