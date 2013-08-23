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
    return goal.getShape().getBoundingBox().contains(robot.getShape().getBoundingBox()) &&  robot.isOn;
  }

  void handle(Robot robot, Goal goal) {
        goal.handleWin();
        robot.handleCompleted();
        messenger.sendActionMessage(ActionMessage.NOTIFICATION_WIN);
  }
}
