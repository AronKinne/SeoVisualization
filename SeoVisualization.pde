Tupel tup;
Tree tree;
boolean done;

void setup() {
  size(1600, 900);
  surface.setTitle("Seo-Sort visualization");

  tup = new Tupel(10);
  tree = new Tree(tup);
}

void draw() {
  background(255);
  
  textAlign(LEFT, TOP);
  textSize(10);
  text("mouse-click: next step", 0, 0);

  tree.draw();
}

void mousePressed() {
  if(!done) tree.next(); 
}
