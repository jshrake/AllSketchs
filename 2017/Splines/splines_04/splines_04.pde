int seed = int(random(9999999));

Spline spline;

void setup() {
  //size(960, 540, P3D);
  size(720, 480, P3D);
  pixelDensity(2);
  smooth(8);

  generate();
}


void draw() {

  if (frameCount%600 == 0) generate();

  float time = frameCount*0.0001;
  PVector pos = spline.getPoint(time);
  PVector dir = spline.getDir(time);

  pushMatrix();
  randomSeed(seed);
  //lights();
  directionalLight(160, 160, 160, dir.x, dir.y, dir.z);
  directionalLight(30, 30, 30, -dir.x, -dir.y, -dir.z);
  ambientLight(60, 60, 60);
  background(0);
  float fov = PI/1.5;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), cameraZ/100.0, cameraZ*1000.0);
  PVector camPos = spline.getPoint(time-0.01);
  camera(camPos.x, camPos.y, camPos.z, pos.x, pos.y, pos.x, asin(-dir.y), atan2(dir.x, dir.z), 0);

  stroke(255, 80, 0);
  //line(pos.x, pos.y, pos.z, pos.x+dir.x*100, pos.y+dir.y*100, pos.z+dir.z*100);
  noFill();
  stroke(0);
  //spline.show();

  noStroke();
  //fill(0);
  stroke(255);
  strokeWeight(2);
  int cc = 80;
  rectMode(CENTER);
  float dd = 620;
  for (int i = 0; i < cc; i++) {
    float pp = i*1./cc;
    PVector p = spline.getPoint(pp);
    PVector d = spline.getDir(pp);
    pushMatrix();
    translate(p.x, p.y, p.z);
    rotateVector(d);
    ellipse(0, 0, dd, dd);
    popMatrix();
  }

  fill(255, 0, 0);
  float da = TWO_PI/6.;
  for (int i = 0; i < cc*5; i++) {
    float pp = i*1./(cc*5.);
    PVector p = spline.getPoint(pp);
    PVector d = spline.getDir(pp);
    pushMatrix();
    translate(p.x, p.y, p.z);
    rotateVector(d);
    for (int j = 0; j < 6; j++) {
      float ang = da*j;
      ellipse(cos(ang)*dd*0.5, sin(ang)*dd*0.5, 20, 20);
    }
    popMatrix();
  }

  /*
  noStroke();
   fill(255, 80, 0);
   pushMatrix();
   translate(pos.x, pos.y, pos.z);
   box(20);
   popMatrix();
   */

  popMatrix();
}

void keyPressed() {
  generate();
}

void generate() {
  seed = int(random(9999999));
  randomSeed(seed);
  ArrayList<PVector> points = new ArrayList<PVector>();
  float ss = 60000;
  for (int i = 0; i < 20; i++) {
    points.add(new PVector(random(-ss, ss), random(-ss, ss), random(-ss, ss)));//random(-ss, ss)));
  }
  spline = new Spline(points);
}

void rotateVector(PVector d) {
  float rx = asin(-d.y);
  float ry = atan2(d.x, d.z);
  rotateY(ry);
  rotateX(rx);
}

class Spline {
  ArrayList<PVector> points;
  float dists[];
  float length;
  Spline(ArrayList<PVector> points) {
    this.points = points;
    calculate();
  }

  void calculate() {
    dists = new float[points.size()+1];
    length = 0; 

    int res = 10;
    for (int i = 0; i <= points.size(); i++) {
      float ndis = 0;
      PVector ant = getPointLin(i);
      for (int j = 1; j <= res; j++) {
        PVector act = getPointLin(i+j*1./res);
        ndis += ant.dist(act);
        ant = act;
      }
      dists[i] = length;
      if (points.size() != i) length += ndis;
    }
  }

  void show() {
    PVector p1, p2, p3, p4;
    p1 = points.get(points.size()-1);
    p2 = points.get(0);
    p3 = points.get(1);
    p4 = points.get(2);
    curveTightness(0);
    curve(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, p3.x, p3.y, p3.z, p4.x, p4.y, p4.z);
    for (int i = 0; i < points.size()-1; i++) {
      p1 = points.get(i);
      p2 = points.get(i+1);
      p3 = points.get((i+2)%points.size());
      p4 = points.get((i+3)%points.size());
      curve(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, p3.x, p3.y, p3.z, p4.x, p4.y, p4.z);
    }
    curve(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, p3.x, p3.y, p3.z, p4.x, p4.y, p4.z);
  }

  PVector getPointLin(float v) {
    v = v%points.size();
    int ind = int(v);
    float m = v%1.;
    return calculatePoint(ind, m);
  }

  PVector getPoint(float v) {
    v = (v%1)*length;
    int ind = 0;
    float antLen = dists[ind];
    float actLen = dists[ind+1];
    while (actLen < v && ind <= points.size()) { 
      ind++;
      antLen = actLen;
      actLen = dists[(ind+1)];
    }
    float m = map(v, antLen, actLen, 0, 1);
    return calculatePoint(ind, m);
  }

  PVector calculatePoint(int ind, float m) {
    int ps = points.size();
    PVector p1 = points.get((ind-1+ps)%ps);
    PVector p2 = points.get((ind+0+ps)%ps);
    PVector p3 = points.get((ind+1+ps)%ps);
    PVector p4 = points.get((ind+2+ps)%ps);
    float xx = curvePoint(p1.x, p2.x, p3.x, p4.x, m);
    float yy = curvePoint(p1.y, p2.y, p3.y, p4.y, m);
    float zz = curvePoint(p1.z, p2.z, p3.z, p4.z, m);
    return new PVector(xx, yy, zz);
  }

  PVector getDir(float v) {
    PVector act = getPoint(v);
    PVector p1 = act.copy().sub(getPoint(v-0.01));
    PVector p2 = getPoint(v+0.01).sub(act);
    PVector aux = p1.add(p2).mult(0.5);
    return aux.normalize();
  }
}  



int colors[] = {#FFD52C, #F57839, #7C2FAD, #E0E0E0};//{#FF4400};//
int rcol() {
  return colors[int(random(colors.length))] ;
}
int getColor(float v) {
  v = v%(colors.length);
  int c1 = colors[int(v%colors.length)];
  int c2 = colors[int((v+1)%colors.length)];
  return lerpColor(c1, c2, v%1);
}