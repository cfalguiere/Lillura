/**
 * A template to get you started
 * Define your beings, groups, interactors and worlds in separate tabs
 * Put the pieces together in this top-level file!
 *
 * See the tutorial for details:
 * https://github.com/rdlester/hermes/wiki/Tutorial-Pt.-1:-Worlds-and-Beings
 */

import hermes.*;
import hermes.hshape.*;
import hermes.animation.*;
import hermes.physics.*;
import hermes.postoffice.*;

import intel.pcsdk.*;

///////////////////////////////////////////////////
// CONSTANTS
///////////////////////////////////////////////////
/**
 * Constants should go up here
 * Making more things constants makes them easier to adjust and play with!
 */
static final int LEFT_PANEL_WIDTH = 200;
static final int RIGHT_PANEL_WIDTH = 200;
static final int TERRAIN_WIDTH = 600;
static final int TERRAIN_HEIGHT = 600;
static final int PORT_IN = 8080;
static final int PORT_OUT = 8000; 

static final int CAMERA_WIDTH = 640;
static final int CAMERA_HEIGHT = 480;


World currentWorld;

///////////////////////////////////////////////////
// PAPPLET
///////////////////////////////////////////////////

void setup() {
  int windowWidth = LEFT_PANEL_WIDTH + TERRAIN_WIDTH +  RIGHT_PANEL_WIDTH;
  size(windowWidth, TERRAIN_HEIGHT); 
  Hermes.setPApplet(this);

  currentWorld = new LilluraWorld(PORT_IN, PORT_OUT);       

  //Important: don't forget to add setup to TemplateWorld!

  currentWorld.start(); // this should be the last line in setup() method
}

void draw() {
  currentWorld.draw();
}
