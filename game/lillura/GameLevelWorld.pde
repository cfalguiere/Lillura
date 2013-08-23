class GameLevelWorld extends World  implements MessageSubscriber {
  
  static final int SQUARE_NUM = 10;
  
  // environment
  LilluraWorld mainWorld;
  Rectangle worldBoundingBox;
  LilluraMessenger messenger;

  // world objects
  Terrain terrain;  
  BlockGroup blocks; 
  Robot robot;
  Goal goal;
  
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
      
      createGoal();
      
      // TOSO goal 
      // TODO origin
      
      // interactors
      register(robot, blocks, new RobotBlockInteractor()); 
      register(robot, terrain, new RobotTerrainInteractor());
      register(robot, goal, new RobotGoalInteractor());

      println("GameLevel world set up");
  }

  //
  // behavior implementation 
  //
    void actionSent(ActionMessage event) {
      if (event.action == ActionMessage.ACTION_RESET) {
         resetWold();
      }
    }
    
    void perCChanged(PerCMessage event) {
      // don't care
    }
  
    void resetWold() {
        println("requesting game to reset");
        robot.handleReset();
        goal.handleReset();
        blocks.destroy();
        createBlocks();
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
      RobotPath path =  new RobotPath(worldBoundingBox);
      PVector position = new PVector(worldBoundingBox.getWidth() / 2, worldBoundingBox.getHeight() -30);
      position.add(worldBoundingBox.getAbsMin());
      robot = new Robot(position, this, messenger,path);
      register(robot);
      register(path);
      messenger.subscribe(robot);
  }
  
  void createGoal() { 
      PVector position = new PVector(worldBoundingBox.getWidth() / 2, 10);
      position.add(worldBoundingBox.getAbsMin());
      goal = new Goal(position, worldBoundingBox);
      register(goal);
  }
  

}
