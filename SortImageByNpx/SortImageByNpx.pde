/*
SORT IMAGE BY N PIXEL SEGMENTS
 Jeff Thompson | 2012 | www.jeffreythompson.org
 
 Loads an image and sorts pixels in chunks of N pixels.  Wraps
 pixels across image.
 
 */

boolean saveIt = false;
boolean saveAll = true;
int numPx = 5;
PImage img;

void setup() {

  img = loadImage("taco.jpg");
  size(img.width, img.height);
  image(img, 0,0);
}

void draw() {

  if (saveAll) {
    println("Saving lots of tacos...");
    for (int i=2; i<2000; i++) {
      println("  " + i);
      img = loadImage("taco.jpg");
      sortNpx(i);
      image(img, 0, 0);
      save("200Tacos/" + nf(i, 4) + ".png");
    }
    println("DONE!");
    exit();
  }
  else {
    sortNpx(numPx);
    image(img, 0, 0);
  }
}

void mouseDragged() {
  img = loadImage("taco.jpg");
  numPx = int(map(mouseX, 0, width, 5, 100));
}

void mouseReleased() {
  if (saveIt) {
    save("SortNpx_" + numPx + ".png");
  }
}

void sortNpx(int numPx) {
  img.loadPixels();
  for (int i=0; i<img.pixels.length-numPx; i+=numPx) {
    color[] c = new color[numPx];
    for (int j=0; j<numPx; j++) {
      c[j] += img.pixels[i+j];
    }
    c = sort(c);

    for (int j=0; j<numPx; j++) {
      img.pixels[i+j] = c[j];
    }
  }
  img.updatePixels();
}

