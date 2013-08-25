class CardGroup extends Group<Card> {
  Rectangle boundingBox;
  Rectangle usedBoundingBox;
  PVector offset;
  int hoverPosition = -1;
  int actionCardIndex = -1;
  
  CardGroup(World aParentWorld, Rectangle aBoundingBox) {
    super(aParentWorld);
    boundingBox = aBoundingBox;
    usedBoundingBox = new Rectangle(aBoundingBox.getPosition(), aBoundingBox.getWidth(), 0);
    
    offset = new PVector(0, Card.HEIGHT + VRT_SPACER);
  }

  public void update() {
    if (boundingBox.contains(mouseX, mouseY)) {
      float relativeMouseY = mouseY - boundingBox.getAbsMin().y;
      int pos = floor(relativeMouseY / offset.y);
      float remainder = relativeMouseY - (pos*offset.y);
      //println("relativeMouseY " + relativeMouseY + " pos " + pos + " remainder " + remainder);
      int index = pos;// -1; // TODO found out reason
      if (index < getObjects().size() && remainder<Card.HEIGHT) {
        hoverPosition = index;
      } else {
        hoverPosition = -1;
      }
      //println("HOVER Card " + hoverPosition);
    } else {
      hoverPosition = -1;
    }
  }

  
  public void addCard(MovementType movementType, int aDistance) {
    int pos = size();

    Card c = new Card(getCardPosition(pos) , movementType, aDistance);
    _world.register(c);
    add(c);
    
    usedBoundingBox = new Rectangle(boundingBox.getPosition(), boundingBox.getWidth(), offset.y*(pos+1));
  }
  
  protected PVector getCardPosition(int pos) {
    PVector position = new PVector();
    position.set(offset);
    position.mult(pos);
    position.add(boundingBox.getAbsMin());
    position.add(new PVector(HRZ_SPACER+2, 0)); //FIXME magic number marker width 
    return position;
  }
  
  public int getSelectedCardIndex() {
     return hoverPosition;
  }
  
  Card getCard(int i) {
     return getObjects().get(i);
  }
  
  PVector getCardOffset() {
    return offset;
  }
  
  Rectangle getUsedBoundingBox() {
    return usedBoundingBox;
  }
  
  public void receive(MouseMessage m) {
    if (m.getAction() == POCodes.Click.PRESSED && hoverPosition>=0) {
          actionCardIndex = hoverPosition;
          Card card = getCard(actionCardIndex);
          println("select card " + actionCardIndex + " "  + card);
          card.select();
    }  
    if (m.getAction() == POCodes.Click.RELEASED && actionCardIndex>=0) {
          Card card = getCard(actionCardIndex);
        //  if (mouseX < 3) {
        //     println("want replay card");
        //  } else {
              float relativeMouseY = mouseY - boundingBox.getAbsMin().y; //TODO factorization
              int newPos = floor(relativeMouseY / offset.y);
              float remainder = relativeMouseY - (newPos*offset.y);
              if (remainder > Card.HEIGHT) newPos++;
              moveCardTo(card,newPos);
         //}
          println("deselect card " + actionCardIndex + " "  + card);
          card.deselect();
          actionCardIndex = -1;
    }  
  }

  void moveCardTo(Card card, int newPos) {
    int currentPos = getObjects().indexOf(card);
    getObjects().add(newPos, card);
    if(newPos < currentPos) currentPos++;
    getObjects().remove(currentPos);
    
    resetCardsPosition();
  }
  
  void removeCard(Card card) {
    int currentPos = getObjects().indexOf(card);
    getObjects().remove(currentPos);    
    resetCardsPosition();
  }
  
  void resetCardsPosition() {
    int i = 0;
    for (Card card : getObjects() ) {
        card.getPosition().set(getCardPosition(i));
        i++;
    }
  }
}

