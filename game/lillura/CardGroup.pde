class CardGroup extends Group<Card> {
  Rectangle boundingBox;
  PVector offset;
  int hoverPosition = -1;
  int actionCardIndex = -1;
  
  CardGroup(World aParentWorld, Rectangle aBoundingBox) {
    super(aParentWorld);
    boundingBox = aBoundingBox;
    
    offset = new PVector(0, Card.HEIGHT + VRT_SPACER);
  }

  public void update() {
    if (boundingBox.contains(mouseX, mouseY)) {
      //hoverPosition = int((mouseY - boundingBox.getAbsMin().y) / offset.y);
      hoverPosition = int(mouseY / offset.y) -1;
      //println("HOVER Card " + hoverPosition);
    } else {
      hoverPosition = -1;
    }
  }

  
  public void addCard(MovementType movementType, int aDistance) {
    int pos = size();
    PVector position = new PVector();
    position.set(offset);
    position.mult(pos);
    position.add(boundingBox.getAbsMin());
    position.add(new PVector(HRZ_SPACER+2, 0)); //FIXME magic number marker width 

    Card c = new Card(position, movementType, aDistance);
    _world.register(c);
    add(c);
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
  
  public void receive(MouseMessage m) {
    if (m.getAction() == POCodes.Click.PRESSED) {
          actionCardIndex = hoverPosition;
          Card card = getCard(actionCardIndex);
          println("select card " + actionCardIndex + " "  + card);
          card.select();
    }  
    if (m.getAction() == POCodes.Click.RELEASED) {
          Card card = getCard(actionCardIndex);
          println("deselect card " + actionCardIndex + " "  + card);
          card.deselect();
          actionCardIndex = -1;
    }  
  }


}

