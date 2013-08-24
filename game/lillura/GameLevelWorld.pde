class GameLevelWorld extends World  implements MessageSubscriber {
  
  static final int BLOCK_NUM = 10;
  
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
      
      // TODO origin
      
      // interactors
      register(robot, blocks, new RobotBlockInteractor(messenger)); 
      register(robot, terrain, new RobotTerrainInteractor(messenger));
      register(robot, goal, new RobotGoalInteractor(messenger));

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
        goal.handleReset(getGoalPosition());
        blocks.destroy();
        createBlocks();
        register(robot, blocks, new RobotBlockInteractor(messenger)); 
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
      
      float terrainWidth = worldBoundingBox.getWidth();
      float terrainHeight = worldBoundingBox.getHeight();
      BlockPlacementDelegate delegate = new BlockPlacementDelegate(terrainWidth, terrainHeight);
      ArrayList<PVector> blockCoordinates = delegate.computeCoordinates(BLOCK_NUM);
      ArrayList<PVector> blockPositions = delegate.getRelativePositions(blockCoordinates, worldBoundingBox.getAbsMin());
      for (PVector position : blockPositions) {
         blocks.addBlock(position); 
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
      goal = new Goal(getGoalPosition(), worldBoundingBox);
      register(goal);
  }
  
  PVector getGoalPosition() {
     float terrainW = worldBoundingBox.getWidth();
     int x =  (int) (random(terrainW/4,terrainW*3/4));
     PVector position = new PVector(x, 5);
     position.add(worldBoundingBox.getAbsMin());
     return position;
  }


}

class BlockPlacementDelegate {
    static final int GRID_WIDTH_OFFSET = 20;
    static final int GRID_HEIGHT_OFFSET = 100;
  
    final float surfaceWidth;
    final float surfaceHeight;
    final int nrCols;
    final int nrLines;
  
    BlockPlacementDelegate(float aTerrainWidth, float aTerrainHeight) {
        surfaceWidth = aTerrainWidth - GRID_WIDTH_OFFSET*2;
        surfaceHeight = aTerrainHeight - GRID_HEIGHT_OFFSET*2;
        nrCols = (int)(surfaceWidth / Block.WIDTH);
        nrLines = (int)(surfaceHeight / Block.HEIGHT);
    }
    
    ArrayList<PVector> computeCoordinates(int numberOfBlocks) {
        ArrayList<PVector> cellCoordinates = new ArrayList<PVector>();
        randomSeed(millis());
        int remainingBlocks = numberOfBlocks;
        for (int ic=0; ic<nrCols; ic++) {
           for (int il=0; il<nrLines; il++) {
             float remainingCells = (nrLines-il-1) + (nrCols-ic-1)*nrLines;
             float rate = remainingBlocks/remainingCells;
             float dice =  random(1) ;
             println("ic=" + ic + "/" + nrCols + " il=" + il + "/" + nrLines + " dice=" + dice + " remainingBlocks=" + remainingBlocks + " rate=" + rate + " remainingCells=" + remainingCells);
             boolean hasBlock = dice <  rate;
             if (hasBlock && remainingBlocks>0) {
                 PVector cellCoordinate = new PVector(ic, il);
                 cellCoordinates.add(cellCoordinate);
                 remainingBlocks--;
             }
           }
       }
       return cellCoordinates;
    }
    
    ArrayList<PVector> getRelativePositions(ArrayList<PVector>  coordinates, PVector origin) {
      ArrayList<PVector> blockPositions = new ArrayList<PVector>();
      for (PVector coordinate : coordinates) {
         PVector position = new PVector(coordinate.x*Block.WIDTH, coordinate.y*Block.HEIGHT);
         position.add(new PVector(GRID_WIDTH_OFFSET, GRID_HEIGHT_OFFSET));
         position.add(origin);
         blockPositions.add(position); 
      }
       return blockPositions;
    }

}
