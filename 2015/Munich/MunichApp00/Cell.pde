class Cell {
  boolean open;
  float x, y, s;
  ArrayList<Node> nodes;
  Node select;
  String name;
  Cell(float x, float y, String name) {
    this.x = x; 
    this.y = y;
    this.name = name;
    s = 0;
    nodes = new ArrayList<Node>();
  }

  void init() {
    float da = TWO_PI/nodes.size();
    for (int i = 0; i < nodes.size (); i++) {
      Node n = nodes.get(i);
      n.setPosition(x+cos(i*da)*160, y+sin(i*da)*160);
      n.setParent(this);
    }
  }

  void update() {
    if (mousePressed) {
      s += (512-s)*random(0.4, 0.9)*0.18;
    } else 
      s += (192-s)*random(0.4, 0.9)*0.18;
    show();

    for (int i = 0; i < nodes.size (); i++) {
      nodes.get(i).update();
    }
  }

  void show() {
    noStroke();
    fill(255, 33);
    ellipse(x, y, s, s);

    for (int i = 0; i < nodes.size (); i++) {
      Node n1 = nodes.get(i);
      Node n2 = nodes.get((i+1)%nodes.size());
      strokeWeight(1);
      stroke(255);
      line(n1.x, n1.y, n2.x, n2.y);
    }

    for (int i = 0; i < nodes.size (); i++) {
      nodes.get(i).show();
    }

    {
      noStroke();
      fill(255);
      rectMode(CENTER);
      float xx = x+map(s, 192, 512, 0, -s*0.5);
      float yy = y+map(s, 192, 512, 0, -s*0.25);
      rect(xx, yy, 80, 80);
    }

    if (select != null) {
      int w = 348;
      int h = 456;
      int xx = width-w-22;
      int yy = 59;
      stroke(0);
      strokeWeight(3);
      line(xx, yy+2, select.x, select.y);
      noStroke();
      fill(0);
      rectMode(CORNER);
      rect(xx, yy, w, h);
      fill(255);
      text(select.name, xx+13, yy+32);
      text(select.text, xx+13, yy+58, w-13*2, w);
    }
  }

  Node getNode(String name) {
    for (int i = 0; i < nodes.size (); i++) {
      Node n = nodes.get(i);
      if (n.name.equals(name)) {
        return n;
      }
    } 
    return null;
  }

  void addNode(Node n) {
    nodes.add(n);
  }
}

