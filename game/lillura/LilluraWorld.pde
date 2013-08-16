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
        int x = CAMERA_WIDTH/3 + HRZ_OFFSET*2;
        int y = WINDOW_HEIGHT - CAMERA_HEIGHT -  + VRT_OFFSET;
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
        int y = (int) (terrain.getBoundingBox().getHeight() + terrain.getBoundingBox().getAbsMin().y  - 50);
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
      int y = (int)(WINDOW_HEIGHT - h) - VRT_OFFSET;
        HandCanvas handCanvas = new HandCanvas(HRZ_OFFSET, y, w, h);
        register(handCanvas);
        Hand hand = new Hand(0, y, w, h);
        register(hand);
        return hand;
  }

}

