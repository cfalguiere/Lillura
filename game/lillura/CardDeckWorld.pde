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
      CardDeckCanvas cardDeck = new CardDeckCanvas(deckBoundingBox); 
      register(cardDeck);
      
      cards = new CardGroup(this, deckBoundingBox); 
      register(cards);
  }

  void resetDeck() {
       cards.destroy();
       createDeck();
  }


}

