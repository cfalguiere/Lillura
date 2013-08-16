class MenuWorld extends World {
  
  MenuWorld(int portIn, int portOut) {
    super(portIn, portOut);
  }

  void setup() {
    //IMPORTANT: put all other setup hereterBeing(TemplateBeing);
        Menu menu = new Menu(0, 0);
        register(menu);
  }
  
}
