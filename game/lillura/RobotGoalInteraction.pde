/**
 * Template interactor between a TemplateBeing and another TemplateBeing
 * Don't forget to change TemplateBeing-s to
 * the names of the Being-types you want to interact
 */
class RobotGoalInteractor extends Interactor<Robot, Goal> {
  RobotGoalInteractor() {
    super();
    //Add your constructor info here
  }

  boolean detect(Robot robot, Goal goal) {
    return robot.getShape().collide(goal.getShape()) && ! robot.isGameOver;
  }

  void handle(Robot robot, Goal goal) {
        goal.handleWin();
        robot.handlePause();
        robot.handleStop();
  }
}
