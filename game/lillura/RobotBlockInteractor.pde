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
