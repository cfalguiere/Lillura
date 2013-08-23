/**
 * A template to get you started
 * Define your beings, groups, interactors and worlds in separate tabs
 * Put the pieces together in this top-level file!
 *
 * See the tutorial for details:
 * https://github.com/rdlester/hermes/wiki/Tutorial-Pt.-1:-Worlds-and-Beings
 */

import java.util.LinkedList;
import java.util.Iterator;

import hermes.*;
import hermes.hshape.*;
import hermes.animation.*;
import hermes.physics.*;
import hermes.postoffice.*;

/*
import intel.pcsdk.*;
*/

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
static final int HRZ_SPACER = 5;
static final int VRT_SPACER = 5;
static final int HEADER_HEIGHT = 50;
static final int LEFT_PANEL_WIDTH = CAMERA_WIDTH/3;
static final int RIGHT_PANEL_WIDTH =  CAMERA_WIDTH/6;
static final int WINDOW_WIDTH = CAMERA_WIDTH + LEFT_PANEL_WIDTH + RIGHT_PANEL_WIDTH + HRZ_SPACER*4;
static final int WINDOW_HEIGHT = CAMERA_HEIGHT + HEADER_HEIGHT + HRZ_SPACER*3;

static final int FRAME_BG = 72;
static final int MENU_BG = 96;
static final int DECK_BG = 96;
static final int HAND_BG = 36;
final color GOLD = color(256, 200, 32); 
final color GREEN = color(160, 200, 160); 
  

static final String HEADER_BBOX = "HBB";
static final String LEFT_PANEL_BBOX = "LPBB";
static final String GAME_LEVEL_BBOX = "GLBB";
static final String CARD_DECK_BBOX = "CDBB";

LilluraWorld mainWorld;
MessengerWorld messengerWorld;
//PerCWorld perCWorld;
GameLevelWorld gameLevelWorld;
CardDeckWorld cardDeckWorld;

///////////////////////////////////////////////////
// PAPPLET
///////////////////////////////////////////////////

void setup() {
  size(WINDOW_WIDTH, WINDOW_HEIGHT); 
  Hermes.setPApplet(this);
  //Important: don't forget to add setup to TemplateWorld!

  messengerWorld = new MessengerWorld(PORT_IN+1, PORT_OUT+1);
  messengerWorld.start();

  //perCWorld = new PerCWorld(PORT_IN+1, PORT_OUT+1);
  //perCWorld.start(); // this should be the last line in setup() method
  
  HashMap<String, Rectangle> boundingBoxes = new HashMap<String, Rectangle>();
  int lpY = VRT_SPACER*2 + HEADER_HEIGHT;
  boundingBoxes.put(HEADER_BBOX, new Rectangle(HRZ_SPACER, VRT_SPACER, LEFT_PANEL_WIDTH, HEADER_HEIGHT));
  Rectangle leftPanelBoundingBox = new Rectangle(HRZ_SPACER, lpY, LEFT_PANEL_WIDTH, WINDOW_HEIGHT - lpY);
  boundingBoxes.put(LEFT_PANEL_BBOX, leftPanelBoundingBox);

  int glX = (int)leftPanelBoundingBox.getAbsMax().x + HRZ_SPACER;
  int glY = WINDOW_HEIGHT - CAMERA_HEIGHT - VRT_SPACER;  
  Rectangle gameLevelBoundingBox = new Rectangle(glX, glY, CAMERA_WIDTH, CAMERA_HEIGHT);
  boundingBoxes.put(GAME_LEVEL_BBOX, gameLevelBoundingBox);

  int cdX = (int)gameLevelBoundingBox.getAbsMax().x + HRZ_SPACER;
  boundingBoxes.put(CARD_DECK_BBOX,  new Rectangle(cdX , glY, RIGHT_PANEL_WIDTH, CAMERA_HEIGHT));

  mainWorld = new LilluraWorld(PORT_IN, PORT_OUT, boundingBoxes, messengerWorld.getMessenger());
  mainWorld.start(); // this should be the last line in setup() method
  
  gameLevelWorld = new GameLevelWorld(PORT_IN+2, PORT_OUT+2, mainWorld, gameLevelBoundingBox, messengerWorld.getMessenger());
  gameLevelWorld.start(); // this should be the last line in setup() method

  cardDeckWorld = new CardDeckWorld(PORT_IN+3, PORT_OUT+3, boundingBoxes.get(CARD_DECK_BBOX), messengerWorld.getMessenger());
  cardDeckWorld.start(); 

}

void draw() {
  background(FRAME_BG);
  mainWorld.draw();
  gameLevelWorld.draw();
  cardDeckWorld.draw();
}

