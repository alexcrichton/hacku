//= require <o3d>

o3djs.base.o3d = o3d;
o3djs.require('o3djs.webgl');
o3djs.require('o3djs.math');
o3djs.require('o3djs.rendergraph');
o3djs.require('o3djs.primitives');
o3djs.require('o3djs.material');
o3djs.require('o3djs.io');

window.onload = initClient;

// global variables
var g_o3dElement;
var g_client;
var g_o3d;
var g_math;
var g_pack;
var g_viewInfo;
var g_eyePosition = [6, 8, 28];
var g_imgURL = 'http://profile.ak.fbcdn.net/hprofile-ak-snc4/hs227.ash2/49223_745375464_9946_q.jpg';
var g_imgURL2 = 'http://profile.ak.fbcdn.net/hprofile-ak-sf2p/hs353.snc4/41677_737168824_5825_s.jpg';
var g_imgURL3 = 'http://www.teamdc.org/images/frisbee.png'
var samplers = [], transforms = [];
var locs = [
  [1, 0, 0],
  [0, 1, 0],
  [0, 0, 1]
];
var vels = [
  [0, 0, 0],
  [0, 0, 0],
  [0, 0, 0]
];
var similar = [
  [0,.75,.95],
  [.75,0,.25],
  [.95,.25,0]
];
var x = 1000;

/**
 * Creates the client area.
 */
function initClient() {
  window.g_finished = false;  // for selenium testing.
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

  window.g_finished = true;  // for selenium testing.
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

  for (var tt = 0; tt < 3; ++tt) {
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
  }

  o3djs.io.loadTexture(g_pack, g_imgURL, function(texture, exception) {
    if (exception) {
      alert(exception);
    } else {
      samplers[0].texture = texture;
    }
  });
  o3djs.io.loadTexture(g_pack, g_imgURL2, function(texture, exception) {
    if (exception) {
      alert(exception);
    } else {
      samplers[1].texture = texture;
    }
	  });
  o3djs.io.loadTexture(g_pack, g_imgURL3, function(texture, exception) {
	if (exception) {
	  alert(exception);
	} else {
	  samplers[2].texture = texture;
	}
  });
}

//
//     var transform = g_pack.createObject('Transform');
//     transform.addShape(cube);
//     transform.translate(tt == 0 ? [1, 1, 0] : [0, 1, 1]);
//     // transforms.push(transform);
//     transform.parent = g_client.root;
//
//     // var sampler = g_pack.createObject('Sampler');
//     // material.getParam('texSampler0').value = sampler;
//     // samplers.push(sampler);
//   }
//
//   // o3djs.io.loadTexture(g_pack, g_imgURL, function(texture, exception) {
//   //   if (exception) {
//   //     alert(exception);
//   //   } else {
//   //     samplers[0].texture = texture;
//   //     setTimeout(100, function() {
//   //       o3djs.camera.fitContextToScene(g_client.root,
//   //                                      g_client.width,
//   //                                      g_client.height,
//   //                                      g_viewInfo.drawContext);
//   //     });
//   //   }
//   // });
// }

/*
function move() {
  var t = 0.001; // 4 ms
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

  for (i = 0; i < transforms.length; i++)
    transforms[i].translate(vels[i][0] * t, vels[i][1] * t, vels[i][2] * t);
  // gc_transform.translate(svel[0] * t, svel[1] * t, svel[2] * t);
  // gs_transform.translate(cvel[0] * t, cvel[1] * t, cvel[2] * t);
}
*/



function move(){
	var t = .001;
	var k = 1000; //spring constant
	var accels = [];
	for(var i = 0; i < transforms.length; i++){
		var accel = [0, 0, 0];
		for(var j = 0; j < transforms.length; j++){
			if(i >= j) continue;
			var posDiff = [0, 0, 0];
			for(var k = 0; k < 3; k++){
				posDiff[k] = locs[i][k] - locs[j][k];
			}
			//console.log(posDiff);
			var offset = Math.sqrt(posDiff[0]*posDiff[0]+posDiff[1]*posDiff[1]+posDiff[2]*posDiff[2]);
			//console.log(offset);
			var offsetDiff = offset - (2 - similar[i][j]*1.95);
			//console.log(offsetDiff);
			var force = (-1) * offset * k / 2;
			//console.log(force);
			var forceVec = [force*posDiff[0]/offset,force*posDiff[1]/offset,force*posDiff[2]/offset];
			//console.log(forceVec);
			accels[0] += forceVec[0];
			accels[1] += forceVec[1];
			accels[2] += forceVec[2];
		}
		accels.push(accel);
	}

	var oldLocs = locs;
	

	// Assume constant acceleration during this time
	for (var i = 0; i < transforms.length; i++) {
		for (var j = 0; j < 3; j++) {
			vels[i][j] += accels[i][j] * t;
			locs[i][j] += vels[i][j] * t;
		}

		var len = locs[i][0]*locs[i][0]+locs[i][1]*locs[i][1]+locs[i][2]*locs[i][2];
		console.log(len);
		locs[i] = [ locs[i][0] / len , locs[i][1] / len , locs[i][2] / len ];
	}

	for (var i = 0; i < transforms.length; i++)
		transforms[i].translate(oldLocs[i][0] - locs[i][0], oldLocs[i][1] - locs[i][1], oldLocs[i][2] - locs[i][2]);	

	//console.log(locs);

}
