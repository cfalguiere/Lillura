/**
 * Template interactor between a TemplateBeing and another TemplateBeing
 * Don't forget to change TemplateBeing-s to
 * the names of the Being-types you want to interact
 */
class LilluraInteractor extends Interactor<LilluraBeing, Robot> {
  LilluraInteractor() {
    super();
    //Add your constructor info here
  }

  boolean detect(LilluraBeing being1, Robot robot) {
    return being1.getShape().collide(robot.getShape());
  }

  void handle(LilluraBeing being1, Robot robot) {
        being1.handleProtect();
        robot.handleStop();
  }
}
