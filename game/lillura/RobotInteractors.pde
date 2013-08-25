/**
 * Template interactor between a TemplateBeing and another TemplateBeing
 * Don't forget to change TemplateBeing-s to
 * the names of the Being-types you want to interact
 */
class RobotBlockInteractor extends Interactor<Robot,Block> {
  LilluraMessenger messenger;
  
  RobotBlockInteractor(LilluraMessenger theMessenger) {
    super();
    //Add your constructor info here
    messenger = theMessenger;
  }

  boolean detect(Robot robot, Block block) {
    return block.getShape().collide(robot.getShape()) &&  robot.isOn;
  }

  void handle(Robot robot, Block block) {
        block.handleProtect();
        robot.handleStop();
        messenger.sendActionMessage(EventType.NOTIFICATION_PLAYER_LOST);
  }
}

//
// RobotGoalInteractor
//

class RobotGoalInteractor extends Interactor<Robot, Goal> {
  LilluraMessenger messenger;
  
  RobotGoalInteractor(LilluraMessenger theMessenger) {
    super();
    //Add your constructor info here
    messenger = theMessenger;
  }

  boolean detect(Robot robot, Goal goal) {
    return goal.getShape().collide(robot.getShape()) &&  robot.isOn;
  }

  void handle(Robot robot, Goal goal) {
    if ( goal.getShape().getBoundingBox().contains(robot.getShape().getBoundingBox()) ) {
        goal.handleWin();
        robot.handleCompleted();
        messenger.sendActionMessage(EventType.NOTIFICATION_PLAYER_WON);
    } else {
        Rectangle r = new Rectangle( goal.getShape().getBoundingBox().getPosition(),  goal.getShape().getBoundingBox().getWidth(),  goal.getShape().getBoundingBox().getHeight()*2); 
        if (! r.contains(robot.getShape().getBoundingBox())) {
          robot.handleStop();
          messenger.sendActionMessage(EventType.NOTIFICATION_PLAYER_LOST);
        }
    } 
  }
}

//
// RobotTerrainInteractor
//

class RobotTerrainInteractor extends Interactor<Robot, Terrain> {
  LilluraMessenger messenger;

  RobotTerrainInteractor(LilluraMessenger theMessenger) {
    super();
    //Add your constructor info here
    messenger = theMessenger;
  }

  boolean detect(Robot robot, Terrain terrain) {
    return ! terrain.getShape().getBoundingBox().contains(robot.getShape().getBoundingBox())
            &&  robot.isOn;
  }

  void handle(Robot robot, Terrain terrain) {
        robot.handleStop();
        messenger.sendActionMessage(EventType.NOTIFICATION_PLAYER_LOST);
  }
}

