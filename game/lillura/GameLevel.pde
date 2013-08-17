class GameLevel {
  static final int SQUARE_NUM = 5;

  Robot _robot;
  Group _squares;
  
  GameLevel(World world, Terrain terrain, LilluraMessenger messenger) {
    println("creating game level");
    initialize(world, terrain, messenger);
  }

  void initialize(World world, Terrain terrain, LilluraMessenger messenger) {
    _squares = createSquares(terrain, world);
    
    _robot = createRobot(terrain, world);
    if (USE_PCC) {
      messenger.subscribe(_robot);
    }

  }

  Group createSquares(Terrain terrain, World world) {
    LilluraGroup group = new LilluraGroup(world, terrain);
    world.register(group);
    
    for (int i = 0; i < SQUARE_NUM; i++) {
       group.addSquare();
    }
    
    return group;
  }

  Robot createRobot(Terrain terrain, World world) {
        PVector position = new PVector(terrain.getBoundingBox().getWidth() / 2, terrain.getBoundingBox().getHeight() -50);
        position.add(terrain.getBoundingBox().getAbsMin());
        Robot robot = new Robot(position, world);
        world.register(robot);
        return robot;
  }
  
  
  void resetLevel() {
    println("resetting game level");
    _robot.handleReset();
  }

  
  Robot getRobot() {
    return _robot;
  }  
  
  Group getSquares() {
    return _squares;
  }  

}
