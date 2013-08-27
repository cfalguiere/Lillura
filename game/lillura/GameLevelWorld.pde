class GameLevelWorld extends World  implements MessageSubscriber {
  
  static final int BLOCK_NUM = 10;
  
  // environment
  LilluraWorld mainWorld;
  Rectangle worldBoundingBox;
  LilluraMessenger messenger;

  // world objects
  Terrain terrain;
  GridLayoutManager grid; 
   
  BlockGroup blocks; 
  Robot robot;
  Goal goal;
  
  RobotMouseMovementController robotMouseMovementController;
  RobotKeyMovementController robotKeyMovementController;
  RobotPerceptualMovementController robotPerceptualMovementController;
  RobotProgramPlayer robotProgramPlayer;
  
  boolean hasPerceptualFocus = true;
  
  
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
      
      createGoal();
      
      // TODO origin
      
      // interactors
      register(robot, blocks, new RobotBlockInteractor(messenger)); 
      register(robot, terrain, new RobotTerrainInteractor(messenger));
      register(robot, goal, new RobotGoalInteractor(messenger));

      println("GameLevel world set up");
  }

    //
    // World interface
    //
    
    void preUpdate() {
        robotMouseMovementController.preUpdate();
        
        if (robotProgramPlayer != null) {
            robotProgramPlayer.preUpdate();
        }
      
    }
    
  
    //
    // behavior implementation 
    //
    void actionSent(ActionMessage message) {
        switch(message.eventType) {
            case COMMAND_NEWGAME:
                resetLevel();
                break;
            case COMMAND_RESTART:
                restartLevel();
                break;
            case PLAY_ROBOT_PROGRAM:
                replayLevel(message.program);
                println("robot ready for replay " + robot);
                robotProgramPlayer = new RobotProgramPlayer(robot, message.program, messenger);
                println("replay player setup " + robotProgramPlayer);
                break;
            case ROBOT_PROGRAM_COMPLETED:
                robot.handleStopReplay();
                robotProgramPlayer = null;
                break;
            case PERCEPTUAL_HAND_MOVED_TOP_LEFT:
            case PERCEPTUAL_HAND_MOVED_TOP_RIGHT:
            case SWITCH_TO_VIEW_0:
            case SWITCH_TO_VIEW_2:
                robotPerceptualMovementController.disable();
                robotKeyMovementController.disable();
                hasPerceptualFocus = false;
                break;
            case PERCEPTUAL_HAND_MOVED_TOP_CENTER:
            case SWITCH_TO_VIEW_1:
                robotPerceptualMovementController.enable();
                robotKeyMovementController.enable();
                hasPerceptualFocus = false;
                break;
            default:
                 // ignore other events
          }
    }
    
    void perCChanged(PerCMessage event) {
      // don't care
    }
  
    void resetLevel() {
        println("requesting level to reset");
        robot.handleReset();
        goal.handleReset(getGoalPosition());
        blocks.destroy();
        createBlocks();
        register(robot, blocks, new RobotBlockInteractor(messenger)); 
    }

    void restartLevel() {
        println("requesting level to restart");
        robot.handleReset();
    }

    void replayLevel(RobotProgram program) {
        println("requesting a replay of the level");
        robot.handleReplay(program);
    }

    
  //
  // World construction 
  //
  
  void createTerrain() {
      int x = CAMERA_WIDTH/3 + HRZ_SPACER*2;
      int y = WINDOW_HEIGHT - CAMERA_HEIGHT -  + VRT_SPACER;
      terrain = new Terrain(x, y, CAMERA_WIDTH, CAMERA_HEIGHT);
      register(terrain);
      
      float terrainWidth = worldBoundingBox.getWidth();
      float terrainHeight = worldBoundingBox.getHeight();
      grid = new GridLayoutManager(worldBoundingBox.getAbsMin(), terrainWidth, terrainHeight);
      
      //DEBUG
      ArrayList<PVector> allCells = grid.getPositions(grid.getAllCells());
      terrain.showGrid(allCells, grid.GRID_CELL_WIDTH, grid.GRID_CELL_HEIGHT);
  }
  

  void createBlocks() {
      blocks = new BlockGroup(this, worldBoundingBox); 
      register(blocks);
      
      ArrayList<PVector> blockCoordinates = grid.computeBlockCoordinates(BLOCK_NUM);
      ArrayList<PVector> blockPositions = grid.getPositions(blockCoordinates);
      for (PVector position : blockPositions) {
         blocks.addBlock(position, grid.GRID_CELL_WIDTH, grid.GRID_CELL_HEIGHT); 
      }

 }
  

  void createRobot() {     
      PVector position = grid.getPositionBottomCentered(grid.computeRobotCoordinate(), Robot.WIDTH, Robot.HEIGHT);
      robot = new Robot(position, this, messenger);
      register(robot);
      
      robotMouseMovementController =  new RobotMouseMovementController(robot, this, messenger);
      subscribe(robotMouseMovementController, POCodes.Button.LEFT, worldBoundingBox);
     
      robotKeyMovementController =  new RobotKeyMovementController(robot, this, messenger);
      subscribe(robotKeyMovementController, POCodes.Key.UP);
      subscribe(robotKeyMovementController, POCodes.Key.LEFT);
      subscribe(robotKeyMovementController, POCodes.Key.RIGHT);
      subscribe(robotKeyMovementController, POCodes.Key.SPACE);
      
      robotPerceptualMovementController =  new RobotPerceptualMovementController(robot, this, messenger);
      messenger.subscribe(robotPerceptualMovementController);
  }
  
  void createGoal() { 
      goal = new Goal( getGoalPosition(), worldBoundingBox);
      register(goal);
  }
  
  PVector getGoalPosition() {
      return grid.getPosition( grid.computeGoalCoordinate() );
  }


}

//
// GridLayoutManager : helper for the grid creation and random blocks placemebt
//

class GridLayoutManager {
    static final int GRID_CELL_WIDTH = 50;
    static final int GRID_CELL_HEIGHT = 50;
    static final int GRID_WIDTH_OFFSET = 20;
    static final int GRID_HEIGHT_OFFSET = 15;
    static final int TOP_LINES_OFFSET = 1;
    static final int BOTTOM_LINES_OFFSET = 1;
  
    final PVector origin;
    final float surfaceWidth;
    final float surfaceHeight;
    final int nrCols;
    final int nrLines;
  
    GridLayoutManager(PVector anOrigin, float aTerrainWidth, float aTerrainHeight) {
        surfaceWidth = aTerrainWidth - GRID_WIDTH_OFFSET*2;
        surfaceHeight = aTerrainHeight - GRID_HEIGHT_OFFSET*2;
        nrCols = (int)(surfaceWidth / GRID_CELL_WIDTH);
        nrLines = (int)(surfaceHeight / GRID_CELL_HEIGHT);
        origin = anOrigin;
    }
    
    ArrayList<PVector> computeBlockCoordinates(int numberOfBlocks) {
        ArrayList<PVector> cellCoordinates = new ArrayList<PVector>();
        randomSeed(millis());
        int remainingBlocks = numberOfBlocks;
        int nrLinesOfBlocks = nrLines - TOP_LINES_OFFSET - BOTTOM_LINES_OFFSET;
        for (int ic=0; ic<nrCols; ic++) {
           for (int il=0; il<nrLinesOfBlocks; il++) {
             float remainingCells = (nrLinesOfBlocks-il-1) + (nrCols-ic-1)*nrLinesOfBlocks;
             float rate = remainingBlocks/remainingCells;
             float dice =  random(1) ;
             //println("ic=" + ic + "/" + nrCols + " il=" + il + "/" + nrLinesOfBlocks + " dice=" + dice + " remainingBlocks=" + remainingBlocks + " rate=" + rate + " remainingCells=" + remainingCells);
             boolean hasBlock = dice <  rate;
             if (hasBlock && remainingBlocks>0) {
                 PVector cellCoordinate = new PVector(ic, il + TOP_LINES_OFFSET);
                 cellCoordinates.add(cellCoordinate);
                 remainingBlocks--;
             }
           }
       }
       return cellCoordinates;
    }
    
    
    PVector computeGoalCoordinate() {
        randomSeed(millis());
        int goalLine = 0;
        int dice =  int(random(1, nrCols-1));
        return new PVector(dice, goalLine);
    }
    
    PVector computeRobotCoordinate() {
        int robotLine = nrLines-1;
        int robotCol = int(nrCols/2);
        return new PVector(robotCol, robotLine);
    }
    
    
    ArrayList<PVector> getAllCells() {
       ArrayList<PVector> cellCoordinates = new ArrayList<PVector>();
       for (int ic=0; ic<nrCols; ic++) {
           for (int il=0; il<nrLines; il++) {
                cellCoordinates.add(new PVector(ic, il));
           }
       }
       return cellCoordinates;
    }

    ArrayList<PVector> getPositions(ArrayList<PVector>  coordinates) {
      ArrayList<PVector> blockPositions = new ArrayList<PVector>();
      for (PVector coordinate : coordinates) {
         blockPositions.add( getPosition(coordinate)); 
      }
       return blockPositions;
    }

    PVector getPosition(PVector  coordinate) {
       PVector position = new PVector(coordinate.x*GRID_CELL_WIDTH, coordinate.y*GRID_CELL_HEIGHT);
       position.add(new PVector(GRID_WIDTH_OFFSET, GRID_HEIGHT_OFFSET));
       position.add(origin);
       return position;
    }

    PVector getPositionBottomCentered(PVector  coordinate, float aWidth, float aHeight) {
       PVector position = getPosition(coordinate);
       float vertOffset = GRID_CELL_WIDTH - aHeight;
       float hrzOffset = (GRID_CELL_HEIGHT - aWidth)/2;
       position.add(new PVector(hrzOffset, vertOffset));
       return position;
    }

}
