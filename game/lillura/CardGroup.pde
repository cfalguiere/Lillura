class CardGroup extends Group<Card> {
  Rectangle boundingBox;
  PVector offset;
  
  CardGroup(World aParentWorld, Rectangle aBoundingBox) {
    super(aParentWorld);
    boundingBox = aBoundingBox;
    
    offset = new PVector(0, Card.HEIGHT + VRT_SPACER);
  }

  public void update() {
  }

  
  public void addCard(Movement movement) {
    int pos = size();
    PVector position = new PVector();
    position.set(offset);
    position.mult(pos);
    position.add(boundingBox.getAbsMin());
    position.add(new PVector(HRZ_SPACER, 0));

    Card c = new Card(position, movement);
    _world.register(c);
    add(c);
  }


}

