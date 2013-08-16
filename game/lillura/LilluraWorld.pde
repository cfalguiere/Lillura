/**
 * Template World
 * You'll need to add stuff to setup().
 */
class LilluraWorld extends World {
  
  static final int SQUARE_NUM = 5;
  Terrain _terrain;
  
  LilluraWorld(int portIn, int portOut) {
    super(portIn, portOut);
  }

  void setup() {
    //IMPORTANT: put all other setup hereterBeing(TemplateBeing);
    _terrain = createTerrain();
    Group group = createSquares(_terrain);
    Robot robot = createRobot(_terrain);
    
    PerCMessenger messenger = createPerCMessenger();
    Hand hand = createHand(_terrain);
    hand.subscribeToPerCMessenger(messenger);
    
    // interactors
    register(group,robot,new LilluraInteractor());
  }
  
  Terrain createTerrain() {
        int x = LEFT_PANEL_WIDTH ;
        int y = 0;
        Terrain terrain = new Terrain(x, y);
        register(terrain);
        return terrain;
  }
  
  Group createSquares(Terrain terrain) {
    LilluraGroup group = new LilluraGroup(this, terrain);
    register(group);
    
    for (int i = 0; i < SQUARE_NUM; i++) {
       group.addSquare();
    }
    
    return group;
  }
  
  Robot createRobot(Terrain terrain) {
        int x = (int) ((TERRAIN_WIDTH / 2) + _terrain.getBoundingBox().getAbsMin().x);
        int y = TERRAIN_HEIGHT - 50;
        Robot robot = new Robot(x, y);
        register(robot);
        robot.subscribeToPostOffice(this);
        return robot;
  }
  
  public Terrain getTerrain() {
    return _terrain;
  }  

  PerCMessenger createPerCMessenger() {
        PerCMessenger messenger = new PerCMessenger(this);
        register(messenger);
        return messenger;
  }

  
  Hand createHand(Terrain terrain) {
      int w = (int)CAMERA_WIDTH/3;
      int h = (int)CAMERA_HEIGHT/3;
      int y = (int)(TERRAIN_HEIGHT - h);
        HandCanvas handCanvas = new HandCanvas(0, y, w, h);
        register(handCanvas);
        Hand hand = new Hand(0, y, w, h);
        register(hand);
        return hand;
  }

}

