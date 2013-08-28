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
  
      createGoal();
      
      createRobot();
      
      createBlocks();
      
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
            case NOTIFICATION_PLAYER_LOST:
                robot.handleStop();
                println("after crashed " + robot);
                break;
            case NOTIFICATION_PLAYER_WON:
                robot.handleCompleted();
                println("after complete game " + robot);
                break;
            case COMMAND_NEWGAME:
                resetLevel();
                break;
            case COMMAND_RESTART:
                restartLevel();
                break;
            case PLAY_ROBOT_PROGRAM:
                replayLevel(message.program);
                println("robot ready for replay " + robot);
                robotProgramPlayer = new RobotProgramPlayer(robot, message.program, grid.getCellSize(), messenger);
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
        PVector goalPosition =  getGoalPosition();
        goal.handleReset(goalPosition);
        terrain.setArrival(goalPosition);
        blocks.destroy();
        createBlocks();
        register(robot, blocks, new RobotBlockInteractor(messenger)); 
    }

    void restartLevel() {
        println("requesting level to restart");
        robot.handleReset();
        blocks.resetAllBlocks();
    }

    void replayLevel(RobotProgram program) {
        robot.handleReplay();
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
    
      RobotTracker robotTracker = new RobotTracker(worldBoundingBox, messenger, grid);
      register(robotTracker);
      
      PVector coordinates = grid.computeRobotCoordinate();
      PVector position = grid.getPositionBottomCentered(coordinates, Robot.WIDTH, Robot.HEIGHT);
      position.add(new PVector(0, GridLayoutManager.GRID_HEIGHT_OFFSET*1/6));
      robot = new Robot(position, this, robotTracker);
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
      
      terrain.setDeparture(grid.getPosition(coordinates));

  }
  
  void createGoal() { 
      PVector position = getGoalPosition();
      goal = new Goal(position, worldBoundingBox);
      register(goal);
      
      terrain.setArrival(position);
  }
  
  PVector getGoalPosition() {
      PVector position =  grid.getPosition( grid.computeGoalCoordinate() );
      position.sub(new PVector(0, GridLayoutManager.GRID_HEIGHT_OFFSET));
      return position;
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
    
    PVector goalCoordinates;
    PVector robotCoordinates;
    PVector cellSize;
  
    GridLayoutManager(PVector anOrigin, float aTerrainWidth, float aTerrainHeight) {
        surfaceWidth = aTerrainWidth - GRID_WIDTH_OFFSET*2;
        surfaceHeight = aTerrainHeight - GRID_HEIGHT_OFFSET*2;
        nrCols = (int)(surfaceWidth / GRID_CELL_WIDTH);
        nrLines = (int)(surfaceHeight / GRID_CELL_HEIGHT);
        origin = anOrigin;
        cellSize = new PVector (GRID_CELL_WIDTH, GRID_CELL_HEIGHT);
    }
    
    ArrayList<PVector> computeBlockCoordinates(int numberOfBlocks) {
        ArrayList<PVector> cellCoordinates = new ArrayList<PVector>();
        randomSeed(millis());
        int remainingBlocks = numberOfBlocks;
        int nrLinesOfBlocks = nrLines - TOP_LINES_OFFSET - BOTTOM_LINES_OFFSET;
        for (int ic=0; ic<nrCols; ic++) {
           for (int il=0; il<nrLinesOfBlocks; il++) {
             if (! isNearGoal(ic, il) && ! isNearRobot(ic, il)) {
               float remainingCells = (nrLinesOfBlocks-il-1) + (nrCols-ic-1)*nrLinesOfBlocks;
               if (hasBlock(remainingBlocks, remainingCells)  && remainingBlocks>0) {
                   PVector cellCoordinate = new PVector(ic, il + TOP_LINES_OFFSET);
                   cellCoordinates.add(cellCoordinate);
                   remainingBlocks--;
               }
             } 
           }
       }
       return cellCoordinates;
    }
    
    private boolean hasBlock(int remainingBlocks, float remainingCells) { 
         float rate = remainingBlocks/remainingCells;
         float dice =  random(1) ;
         return dice <  rate;
    }
    
    private boolean isNearGoal(int ic, int il) {
      boolean isNextLine = (il == 0);
      boolean isNearColumn = (ic >= goalCoordinates.x-1) && (ic <= goalCoordinates.x+1);
      return isNextLine && isNearColumn;
    }
      
    private boolean isNearRobot(int ic, int il) {
      boolean isNextLine = (il >= robotCoordinates.y-2);
      boolean isNearColumn = (ic >= robotCoordinates.x-1) && (ic <= robotCoordinates.x+1);
      return isNextLine && isNearColumn;
    }
      
    
    PVector computeGoalCoordinate() {
        randomSeed(millis());
        int goalLine = 0;
        int dice =  int(random(1, nrCols-1));
        goalCoordinates =  new PVector(dice, goalLine);
        return goalCoordinates;
    }
    
    PVector computeRobotCoordinate() {
        int robotLine = nrLines-1;
        int robotCol = int(nrCols/2);
        robotCoordinates =  new PVector(robotCol, robotLine);
        return robotCoordinates;
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

    PVector getCoordinates(PVector position) {
       int x = floor( (position.x - origin.x - GRID_WIDTH_OFFSET) / GRID_CELL_WIDTH);
       int y = floor( (position.y - origin.y - GRID_HEIGHT_OFFSET) / GRID_CELL_HEIGHT);
       return new PVector(x,y);
    }

    PVector getCellSize() {
       return cellSize;
    }


}
