/**
 * Template being
 */
class RobotPath extends Being {
  ArrayList<PVector> path;
  Rectangle terrain;
  
    RobotPath(Rectangle theTerrain) {
        super(theTerrain);
        terrain = theTerrain;
        path = new ArrayList<PVector>();
    }
    
    synchronized void addPoint(PVector vertex) {
      path.add(vertex);
    }
    
    public void draw() {
      if (!path.isEmpty()) {
        stroke(128);
        for(int i=1; i<path.size(); i++) {
          PVector begin = path.get(i-1);
          begin.sub(terrain.getAbsMin());
          PVector end = path.get(i);
          end.sub(terrain.getAbsMin());
          line(begin.x, begin.y, end.x, end.y);
        }
      }
    }
  

}
