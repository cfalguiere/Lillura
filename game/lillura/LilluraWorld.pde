/**
 * Template World
 * You'll need to add stuff to setup().
 */
class LilluraWorld extends World {
  
  static final int SQUARE_NUM = 5;
  
  LilluraWorld(int portIn, int portOut) {
    super(portIn, portOut);
  }

  void setup() {
    //IMPORTANT: put all other setup hereterBeing(TemplateBeing);
    Group group = createSquares();
    Robot robot = createRobot();
    register(group,robot,new LilluraInteractor());
  }
  
  Group createSquares() {
    LilluraGroup group = new LilluraGroup(this);
    register(group);
    
    for (int i = 0; i < SQUARE_NUM; i++) {
       group.addSquare();
    }
    
    return group;
  }
  
  Robot createRobot() {
        int x = (int) (WINDOW_WIDTH / 2);
        int y = WINDOW_HEIGHT - 50;
        Robot robot = new Robot(x, y);
        register(robot);
        robot.subscribeToPostOffice(this);
        return robot;
  }
  

}

