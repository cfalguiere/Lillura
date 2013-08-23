/**
 * Card on the CardDeck
 */
class Card extends Being {
  static final int WIDTH = 80;
  static final int HEIGHT = 60;
  MovementType movementType;

  Card(PVector position, MovementType aMovementType) {
      super(new Rectangle(position, WIDTH, HEIGHT));
      //Add your constructor info here
      println("creating card at " + position);
      movementType = aMovementType;
  }

  public void update() {
    //_stroke = false;
  }

  public void draw() {
      fill(color(256,256,256));
      strokeWeight(1);
      stroke(0);
      _shape.draw();
      
      fill(0);
      textSize(12);
      if (movementType ==  MovementType.FORWARD) {
          text("Up", 10, 20);
      } else if (movementType ==  MovementType.RIGHT) {
          text("Right", 10, 20);
      } else if (movementType ==  MovementType.LEFT) {
          text("Left", 10, 20);
      }
  }
   
}

