/**
 * A template to get you started
 * Define your beings, groups, interactors and worlds in separate tabs
 * Put the pieces together in this top-level file!
 *
 * See the tutorial for details:
 * https://github.com/rdlester/hermes/wiki/Tutorial-Pt.-1:-Worlds-and-Beings
 */

import java.util.LinkedList;

import hermes.*;
import hermes.hshape.*;
import hermes.animation.*;
import hermes.physics.*;
import hermes.postoffice.*;

//import intel.pcsdk.*;


///////////////////////////////////////////////////
// CONSTANTS
///////////////////////////////////////////////////
/**
 * Constants should go up here
 * Making more things constants makes them easier to adjust and play with!
 */
static final boolean USE_PCC = false;

static final int PORT_IN = 8080;
static final int PORT_OUT = 8000; 

static final int CAMERA_WIDTH = 640;
static final int CAMERA_HEIGHT = 480;
static final int HRZ_SPACER = 7;
static final int VRT_SPACER = 7;
static final int LEFT_PANEL_WIDTH = CAMERA_WIDTH/3;
static final int RIGHT_PANEL_WIDTH =  CAMERA_WIDTH/3;
static final int WINDOW_WIDTH = CAMERA_WIDTH + LEFT_PANEL_WIDTH + RIGHT_PANEL_WIDTH + HRZ_SPACER*4;
static final int WINDOW_HEIGHT = 600;


World currentWorld;
PerCWorld perCWorld;

///////////////////////////////////////////////////
// PAPPLET
///////////////////////////////////////////////////

void setup() {
  size(WINDOW_WIDTH, WINDOW_HEIGHT); 
  Hermes.setPApplet(this);

  perCWorld = new PerCWorld(PORT_IN+1, PORT_OUT+1);
  perCWorld.start(); // this should be the last line in setup() method
  
  currentWorld = new LilluraWorld(PORT_IN, PORT_OUT, perCWorld);

  //Important: don't forget to add setup to TemplateWorld!

  currentWorld.start(); // this should be the last line in setup() method
}

void draw() {
  background(color(72,72,72));
  currentWorld.draw();
}

