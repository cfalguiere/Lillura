/**
 * Template interactor between a TemplateBeing and another TemplateBeing
 * Don't forget to change TemplateBeing-s to
 * the names of the Being-types you want to interact
 */
class RobotBlockInteractor extends Interactor<Robot,Block> {
  RobotBlockInteractor() {
    super();
    //Add your constructor info here
  }

  boolean detect(Robot robot, Block block) {
    return block.getShape().collide(robot.getShape());
  }

  void handle(Robot robot, Block block) {
        block.handleProtect();
        robot.handleStop();
  }
}
