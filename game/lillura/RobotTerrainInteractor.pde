/**
 * Template interactor between a TemplateBeing and another TemplateBeing
 * Don't forget to change TemplateBeing-s to
 * the names of the Being-types you want to interact
 */
class RobotTerrainInteractor extends Interactor<Robot, Terrain> {
  RobotTerrainInteractor() {
    super();
    //Add your constructor info here
  }

  boolean detect(Robot robot, Terrain terrain) {
    return ! terrain.getShape().getBoundingBox().contains(robot.getShape().getBoundingBox());
  }

  void handle(Robot robot, Terrain terrain) {
        robot.handleStop();
  }
}
