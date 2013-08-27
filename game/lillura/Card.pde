/**
 * Card on the CardDeck
 */
class Card extends Being {
  static final int WIDTH = 80;
  static final int HEIGHT = 60;
  MovementType movementType;
  int distance;
  boolean isSelected = false;
  HashMap<MovementType, CardShapeArrow> shapes;
  CardShapeForward shapeForward;

  Card(PVector position, MovementType aMovementType, int aDistance) {
      super(new Rectangle(position, WIDTH, HEIGHT));
      //Add your constructor info here
      println("creating card at " + position);
      movementType = aMovementType;
      distance = aDistance;
      
      Rectangle boundingBox = new Rectangle(position, WIDTH, HEIGHT);
      shapes = new HashMap<MovementType, CardShapeArrow>();
      shapes.put( MovementType.FORWARD,  new CardShapeForward(boundingBox));
      shapes.put( MovementType.TURN_LEFT,  new CardShapeLeft(boundingBox));
      shapes.put( MovementType.TURN_RIGHT,  new CardShapeRight(boundingBox));
  }

  public void update() {
    //_stroke = false;
  }

  public void select() {
    isSelected = true;
  }
  
  public void deselect() {
    isSelected = false;
  }
  
  public void draw() {
      if (isSelected) {
        fill(color(GREEN));
      } else {
        fill(color(256,256,256));
      }
      strokeWeight(1);
      stroke(0);
      _shape.draw();
      
      CardShapeArrow cardShape = shapes.get(movementType);
      cardShape.draw();
      
      fill(0);
      textSize(8);
      String label = movementType.name() + " " + distance;
      text(label, 5, HEIGHT - 8);
  }
   
  public String toString() {
    return movementType.name() + " " + distance;
  }
  
}

class CardShapeArrow {
    Rectangle boundingBox;
    private ArrayList<PVector> vertices;
    PVector origin;
  
    CardShapeArrow(Rectangle aBoundingBox) {
        boundingBox = aBoundingBox;
        
        vertices = new ArrayList<PVector>();
        initialize();
    }
    
    void initialize() {}

    void addVextex(float angle, float len) {
        PVector vertex = PVector.fromAngle(angle);
        vertex.mult(len);
        vertex.add(origin);
        vertices.add(vertex);        
    }

    PVector getCenter() {
      return boundingBox.getCenter();
    }

    public void draw() {
      pushMatrix();
      strokeWeight(3);
      stroke(GREEN);
      for (PVector v : vertices) {
          line(origin.x, origin.y, v.x, v.y);
      }
      popMatrix();
    }

}

class CardShapeForward extends CardShapeArrow {
    
    CardShapeForward(Rectangle aBoundingBox) {
        super(aBoundingBox);
    }

    void initialize() {
        float w = boundingBox.getWidth();
        float l1 = boundingBox.getHeight()/4;
        float l2 = boundingBox.getHeight()*0.45;
        
        origin = new PVector(w/2, 10);
        
        addVextex(TWO_PI*2/6, l1);
        addVextex(HALF_PI, l2);
        addVextex(TWO_PI/6, l1);
    }
}

class CardShapeRight extends CardShapeArrow {
    
    CardShapeRight(Rectangle aBoundingBox) {
        super(aBoundingBox);
    }

    void initialize() {
        float w = boundingBox.getWidth();
        float h = boundingBox.getHeight();
        float l1 = boundingBox.getWidth()/6;
        float l2 = boundingBox.getWidth()/3;
        
        origin = new PVector(w-10, h/3);
        
        addVextex(TWO_PI*5/8, l1);
        addVextex(PI, l2);
        addVextex(TWO_PI*3/8, l1);
    }
}

class CardShapeLeft extends CardShapeArrow {
    
    CardShapeLeft(Rectangle aBoundingBox) {
        super(aBoundingBox);
    }

    void initialize() {
        float h = boundingBox.getHeight();
        float l1 = boundingBox.getWidth()/6;
        float l2 = boundingBox.getWidth()/3;
        
        origin = new PVector(10, h/3);
        
        addVextex(TWO_PI*7/8, l1);
        addVextex(0, l2);
        addVextex(TWO_PI*1/8, l1);
    }
}


