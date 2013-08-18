class GameLevelWorld extends World implements MessageSubscriber {
  
  static final int SQUARE_NUM = 5;
  
  // environment
  LilluraWorld mainWorld;
  Rectangle worldBoundingBox;
  LilluraMessenger messenger;

  // world objects
  Terrain terrain;  
  BlockGroup blocks; 
  Robot robot;
  
  GameLevelWorld(int portIn, int portOut, LilluraWorld aMainWorld, Rectangle aWorldBoundingBox, LilluraMessenger theMessenger) {
      super(portIn, portOut);
      mainWorld = aMainWorld;
      worldBoundingBox = aWorldBoundingBox;
      messenger = theMessenger;
  }

  void setup() {
      messenger.subscribe(this);
      
      createTerrain(); //TODO draw borders
  
      createBlocks();
      
      createRobot();
      if (USE_PCC) {
        messenger.subscribe(robot);
      }
      
      // TOSO goal 
      // TODO origin
      
      // interactors
      register(robot, blocks, new RobotBlockInteractor()); 
      register(robot, terrain, new RobotTerrainInteractor());

      println("GameLevel world set up");
  }

  //
  // behavior implementation 
  //
    void actionSent(ActionMessage event) {
      if (event.action == ActionMessage.ACTION_RESET) {
        println("requesting robot to reset");
        robot.handleReset();
      }
    }
    void perCChanged(PerCMessage event) {
      // don't care
    }
  
  //
  // World construction 
  //
  
  void createTerrain() {
      int x = CAMERA_WIDTH/3 + HRZ_SPACER*2;
      int y = WINDOW_HEIGHT - CAMERA_HEIGHT -  + VRT_SPACER;
      terrain = new Terrain(x, y, CAMERA_WIDTH, CAMERA_HEIGHT);
      register(terrain);
  }
  
  void createBlocks() {
      blocks = new BlockGroup(this, worldBoundingBox); 
      register(blocks);
      
      for (int i = 0; i < SQUARE_NUM; i++) {
         blocks.addBlock();
      }
  }

  void createRobot() { 
      PVector position = new PVector(worldBoundingBox.getWidth() / 2, worldBoundingBox.getHeight() -50);
      position.add(worldBoundingBox.getAbsMin());
      robot = new Robot(position, this);
      register(robot);
      messenger.subscribe(robot);
  }
  

}
