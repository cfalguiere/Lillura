class GameLevelWorld extends World {
  
  static final int SQUARE_NUM = 5;
  
  // environment
  LilluraWorld mainWorld;
  Rectangle worldBoundingBox;
  LilluraMessenger messenger;

  // world objects
  Terrain terrain;  
  BlockGroup blocks; 
  Robot robot;
  
  GameLevelWorld(int portIn, int portOut, LilluraWorld aMainWorld, Rectangle aWorldBoundingBox) {
      super(portIn, portOut);
      mainWorld = aMainWorld;
      worldBoundingBox = aWorldBoundingBox;
  }

  void setup() {
      //messenger = mainWorld.getMessenger(); //TODO remettre
      
      createTerrain(); //TODO draw borders
  
      createBlocks();
      
      createRobot();
      if (USE_PCC) {
        //messenger.subscribe(robot); // TODO
      }
      
      // TOSO goal 
      // TODO origin
      
      // interactors
      register(robot, blocks, new RobotBlockInteractor()); 
      register(robot, terrain, new RobotTerrainInteractor());

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
  }
  

}
