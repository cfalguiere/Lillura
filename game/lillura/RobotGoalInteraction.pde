/**
 * Template interactor between a TemplateBeing and another TemplateBeing
 * Don't forget to change TemplateBeing-s to
 * the names of the Being-types you want to interact
 */
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
        messenger.sendActionMessage(ActionMessage.NOTIFICATION_WIN);
    } else {
        Rectangle r = new Rectangle( goal.getShape().getBoundingBox().getPosition(),  goal.getShape().getBoundingBox().getWidth(),  goal.getShape().getBoundingBox().getHeight()*2); 
        if (! r.contains(robot.getShape().getBoundingBox())) {
          robot.handleStop();
          messenger.sendActionMessage(ActionMessage.NOTIFICATION_LOST);
        }
    } 
  }
}
