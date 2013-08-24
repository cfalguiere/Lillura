class CardDeckWorld extends World implements MessageSubscriber  {
  
  Rectangle deckBoundingBox;
  
  LilluraMessenger messenger = null;  
  CardGroup cards;
  
  //GameLevel _gameLevel;  
  
  CardDeckWorld(int portIn, int portOut, Rectangle aBoundingBox, LilluraMessenger theMessenger) {
      super(portIn, portOut);
      deckBoundingBox = aBoundingBox;
      messenger = theMessenger;
  }

  void setup() {
      //IMPORTANT: put all other setup hereterBeing(TemplateBeing);
      createDeck();

      messenger.subscribe(this);
    
      println("CardDeck world set up");
  }

  //
  // behavior implementation 
  //
    void actionSent(ActionMessage event) {
      switch (event.action) {
         case ActionMessage.ACTION_COMPLETED :
            cards.addCard(event.movementType, event.value);
            break;
         case ActionMessage.ACTION_RESET :
            resetDeck();
            break;
         default :
             break;
      }
    }
    
    void perCChanged(PerCMessage event) {
      // don't care
    }
  //
  // World construction
  //
    
  void createDeck() {      
      cards = new CardGroup(this, deckBoundingBox); 
      register(cards);
      subscribe(cards, POCodes.Button.LEFT, deckBoundingBox);
      
      CardDeckCanvas cardDeck = new CardDeckCanvas(deckBoundingBox, cards); 
      register(cardDeck);
  }

  void resetDeck() {
       cards.destroy();
       createDeck();
  }


}

