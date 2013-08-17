/**
 * Template World
 * You'll need to add stuff to setup().
 */
class LilluraWorld extends World {
  
  static final int SQUARE_NUM = 5;
  Terrain _terrain;
  PerCMessenger _perCMessenger;
  
  LilluraWorld(int portIn, int portOut) {
    super(portIn, portOut);
  }

  void setup() {
    //IMPORTANT: put all other setup hereterBeing(TemplateBeing);
    _terrain = createTerrain();
    Group group = createSquares(_terrain);
    Robot robot = createRobot(_terrain);
  
    _perCMessenger = new PerCMessenger();
    Hand hand = createHand(_terrain);
    _perCMessenger.subscribe(hand);

    // interactors
    register(group,robot,new LilluraInteractor());
    register(robot,_terrain,new RobotTerrainInteractor());
  }

  void preUpdate() {
    _perCMessenger.checkMessages();
  }
  
  //
  // World construction
  //
  Terrain createTerrain() {
        int x = CAMERA_WIDTH/3 + HRZ_SPACER*2;
        int y = WINDOW_HEIGHT - CAMERA_HEIGHT -  + VRT_SPACER;
        Terrain terrain = new Terrain(x, y, CAMERA_WIDTH, CAMERA_HEIGHT);
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
        int x = (int) (terrain.getBoundingBox().getWidth() / 2 + terrain.getBoundingBox().getAbsMin().x );
        int y = (int) (terrain.getBoundingBox().getHeight() + terrain.getBoundingBox().getAbsMin().y  - 50); //TODO use HSpace primitives
        Robot robot = new Robot(x, y, this);
        register(robot);
        return robot;
  }
  
  public Terrain getTerrain() {
    return _terrain;
  }  

  
  Hand createHand(Terrain terrain) {
      int w = (int)CAMERA_WIDTH/3;
      int h = (int)CAMERA_HEIGHT/3;
      int y = (int)(WINDOW_HEIGHT - h) - VRT_SPACER;
        HandCanvas handCanvas = new HandCanvas(HRZ_SPACER, y, w, h);
        register(handCanvas);
        Hand hand = new Hand(0, y, w, h);
        register(hand);
        return hand;
  }

}

