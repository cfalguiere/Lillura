class CardGroup extends Group<Card> {
    Rectangle boundingBox;
    Rectangle usedBoundingBox;
    PVector offset;
    PFont font;
  
    int selectedCardIndex;
  
    CardGroup(World aParentWorld, Rectangle aBoundingBox) {
      super(aParentWorld);
      boundingBox = aBoundingBox;
      usedBoundingBox = new Rectangle(aBoundingBox.getPosition(), aBoundingBox.getWidth(), 0);
      
      offset = new PVector(0, Card.HEIGHT + VRT_SPACER);
      font = createFont("Verdana", 12); //FIXME creates a font per button

    }

    public void update() {
    }

    public float getCardIndexForMouse(float y) {
        float index = -1;
        //float relativeMouseY = mouseY - boundingBox.getAbsMin().y;
        int pos = floor(y / offset.y);
        float remainder = y - (pos*offset.y);
        //println("relativeMouseY " + relativeMouseY + " pos " + pos + " remainder " + remainder);
        if (pos < getObjects().size()) {
            index = pos;
            if (remainder>Card.HEIGHT) index += 0.5;
        } 
        return index;
    }
  
    public void addCard(MovementType movementType, int aDistance) {
      int pos = size();
  
      Card c = new Card(getCardPosition(pos) , movementType, aDistance, font);
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

    PFont getFont() {
        return font;
    }
    
    public void setSelectedCardIndex(int index) {
       selectedCardIndex = index;
    }
  
    public int getSelectedCardIndex() {
       return selectedCardIndex;
    }
  
    public int getNumberOfCards() {
       return getObjects().size();
    }
  
    Card getCard(int i) throws IllegalArgumentException  {
       if (i >= getObjects().size()) {
           IllegalArgumentException e = new IllegalArgumentException("No card found at position " + i);
           e.printStackTrace();
           throw e;
       }
       return getObjects().get(i);
    }
    
    PVector getCardOffset() {
      return offset;
    }
  
    Rectangle getUsedBoundingBox() {
      return usedBoundingBox;
    }
  

    void moveCardTo(Card card, int newPos) throws IllegalArgumentException {
        int currentPos = getObjects().indexOf(card);
        if (currentPos >= 0 && newPos >= 0) {
            getObjects().add(newPos, card);
            if(newPos < currentPos) currentPos++;
            getObjects().remove(currentPos);
            
            resetCardsPosition();
        } else {
           IllegalArgumentException e = new IllegalArgumentException("Card does not exist " + card);
           println("POST-MORTEM currentPos=" + currentPos + " newPos=" + newPos); 
           e.printStackTrace();
           throw e;
        }
    }
  
    void removeSelectedCard() {
        if (selectedCardIndex>=0) {
            Card card = getObjects().get(selectedCardIndex);
            card.discard();
            getObjects().remove(selectedCardIndex);    
            selectedCardIndex = -1;
            println("removing");
            resetCardsPosition();
        }
    }
  
    void resetCardsPosition() {
      int i = 0;
      for (Card card : getObjects() ) {
          card.getPosition().set(getCardPosition(i));
          i++;
      }
    }
    
    RobotProgram makeProgram() {
        RobotProgram program = new RobotProgram();
        for (Card card : getObjects()) {
          program.addOperation(new RobotOperation(card.movementType, card.distance));
        }
        println("program created for cards " + program);
        return program;
    }
}


