class CardDeckWorld extends World implements MessageSubscriber  {
  
    Rectangle deckBoundingBox;
    
    LilluraMessenger messenger = null;  
    CardGroup cards;
  
    CardDeckMouseController cardDeckMouseController;
    CardDeckPerceptualController cardDeckPerceptualController;
    
    CardDeckWorld(int portIn, int portOut, Rectangle aBoundingBox, LilluraMessenger theMessenger) {
        super(portIn, portOut);
        deckBoundingBox = aBoundingBox;
        messenger = theMessenger;
    }

    void preUpdate() {
        cardDeckMouseController.preUpdate();
        cardDeckPerceptualController.preUpdate();
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
    void actionSent(ActionMessage message) {
        switch (message.eventType) {
            case ROBOT_ACTION_COMPLETED :
                cards.addCard(message.robotAction.movementType, message.robotAction.distance());
                break;
            case COMMAND_NEWGAME :
            case COMMAND_RESTART :
                resetDeck();
                break;
            case COMMAND_PLAY :
                replayDeck();
                break;
            case PERCEPTUAL_HAND_MOVED_BOTTOM_RIGHT:
            case PERCEPTUAL_HAND_MOVED_BOTTOM_CENTER:
                cardDeckMouseController.enable();
                cardDeckPerceptualController.disable();
                break;
            case PERCEPTUAL_HAND_MOVED_BOTTOM_LEFT:
                cardDeckMouseController.disable();
                cardDeckPerceptualController.enable();
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
      
      PVector position3D = new PVector(deckBoundingBox.getPosition().x, deckBoundingBox.getPosition().y, -1);
      Rectangle mouseMarker = new Rectangle(position3D, deckBoundingBox.getWidth() -12, 1);
      CardDeckMouseMarker cardMouseMarker = new CardDeckMouseMarker(mouseMarker, cards);
      register(cardMouseMarker);
      
      cardDeckMouseController =  new CardDeckMouseController(cardDeck, cards, this, messenger);
      subscribe(cardDeckMouseController, POCodes.Button.LEFT, deckBoundingBox);
      
      cardDeckPerceptualController =  new CardDeckPerceptualController(cardDeck, cards, this, messenger);
      messenger.subscribe(cardDeckPerceptualController);
      subscribe(cardDeckPerceptualController, POCodes.Key.C);
      subscribe(cardDeckPerceptualController, POCodes.Key.O);
  }

  void resetDeck() {
       cards.destroy();
       createDeck();
  }


  void replayDeck() {
    RobotProgram program = cards.makeProgram();
    messenger.sendMessage(new ActionMessage(EventType.PLAY_PROGRAM, program));
  }
}

