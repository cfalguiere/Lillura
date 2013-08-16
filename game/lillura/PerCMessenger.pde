class PerCMessenger extends Group<Being>  {
  
  float[] mHandPos = new float[4];
  
  PXCUPipeline session;
  PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();

  boolean isActive = false;
  
  ArrayList<PerCListener> subscribers = new ArrayList<PerCListener>();
  
  PerCMessenger(World w) {
    super(w);
    session = new PXCUPipeline(  Hermes.getPApplet());
    if(!session.Init(PXCUPipeline.GESTURE)) {
      println("could not initialize Perc");
    } else {
      isActive = true;
      println("creating PerC session");
    }
  }
  
  public void update() {
    if(session.AcquireFrame(false))
    {
      if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand))
      {
        //println("hand detected");
        mHandPos[0] = hand.positionImage.x;
        mHandPos[1] = hand.positionImage.y;
        mHandPos[2] = hand.positionWorld.y;
        mHandPos[3] = hand.openness;
      }
//      PXCMGesture.Gesture gdata=new PXCMGesture.Gesture();
//      if (pp.QueryGesture(PXCMGesture.GeoNode.LABEL_ANY,gdata)){
//          print("gesture "+gdata.label+"\n");
 //     }
 
       synchronized(subscribers) {
         for(PerCListener subscriber : subscribers) {
           println("pushing to subscriber");
           subscriber.receivePerCMessage(hand);
         }
       }
       session.ReleaseFrame(); //must do tracking before frame is released
    }
  }

  void subscribe(PerCListener listener) {
    println(listener + " has subscribed to PerCMessenger");
    subscribers.add(listener);
  }

}
