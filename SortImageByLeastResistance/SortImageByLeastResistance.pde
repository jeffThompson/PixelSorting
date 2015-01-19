
/*
SORTING BY LEAST RESISTANCE
Jeff Thompson | 2012 | www.jeffreythompson.org

*/

String filename = "../SourceImageFiles/highRes/06.jpg";
boolean saveIt = true;

int startX, startY;
PImage img;
int[] path = new int[0];

void setup() {

  println("Loading \"" + filename + "\"...");
  img = loadImage(filename);
  size(img.width, img.height);
  startX = width/2;
  startY = height-1;

  println("Loading image: " + width + "x" + height);
  image(img, 0, 0);

  loadPixels();
  println("  getting seam at " + startX + "x, " + startY + "y");
  getSeam(startX, startY);
  println("  done getting seam!");

  // draw seam across image
  println("  drawing seam across image...");
  for (int start=0; start<width; start++) {
    println("    " + start);
    color[] seam = new color[path.length];      // array to store the seam
    for (int i=0; i<path.length; i++) {
      try {
        seam[i] = pixels[path[i] + start];
      }
      catch (Exception e) {
        // run out of pixels, ignore
      }
    }
    
    // sort seam
    seam = sort(seam);
    
    for (int i=0; i<path.length; i++) {
      try {
        pixels[path[i] + start] = seam[i];
      }
      catch (Exception e) {
        // run out of pixels, ignore
      }
    }
  }
  
  println("  updating results...");
  updatePixels();
  
  if (saveIt) {
    println("  saving image to file...");
    filename = stripFileExtension(filename);
    save("results/LeastResistance_" + filename + ".tiff");
  }
  println("DONE!");
}

// strip file extension for saving and renaming
String stripFileExtension(String s) {
  s = s.substring(s.lastIndexOf('/')+1, s.length());
  s = s.substring(s.lastIndexOf('\\')+1, s.length());
  s = s.substring(0, s.lastIndexOf('.'));
  return s;
}

void getSeam(int x, int y) {

  // run through image until offscreen (either off the top or past 0,0)
  while (y*width + x > 0) {

    // println("  " + x + ", " + y);

    // variables for finding seam
    color current = pixels[y*width + x];    // current color to compare against
    float diff, tempDiff;                   // difference between pixel values
    int loc;                                // location in pixel array
    int tempX = x;                          // get new x/y coordinates
    int tempY = y;

    // LEFT - first needs no 'if' statement since it will set the new record of minimum difference
    loc = y*width + (x-1);
    diff = (red(current) + green(current) + blue(current)) - (red(pixels[loc]) + green(pixels[loc]) + blue(pixels[loc]));
    tempX = x-1;
    current = pixels[loc];

    // UPPER LEFT
    loc = (y-1)*width + (x-1);
    tempDiff = (red(current) + green(current) + blue(current)) - (red(pixels[loc]) + green(pixels[loc]) + blue(pixels[loc]));
    if (tempDiff < diff) {
      tempX = x-1;
      tempY = y-1;
      current = pixels[loc];
      diff = tempDiff;
    }

    // UP
    loc = (y-1)*width + x;
    tempDiff = (red(current) + green(current) + blue(current)) - (red(pixels[loc]) + green(pixels[loc]) + blue(pixels[loc]));
    if (tempDiff < diff) {
      tempY = y-1;
      current = pixels[loc];
      diff = tempDiff;
    }

    // UPPER RIGHT
    loc = (y-1)*width + (x+1);
    tempDiff = (red(current) + green(current) + blue(current)) - (red(pixels[loc]) + green(pixels[loc]) + blue(pixels[loc]));
    if (tempDiff < diff) {
      tempX = x-1;
      tempY = y-1;
      current = pixels[loc];
      diff = tempDiff;
    }

    // RIGHT
    loc = y*width + (x+1);
    tempDiff = (red(current) + green(current) + blue(current)) - (red(pixels[loc]) + green(pixels[loc]) + blue(pixels[loc]));
    if (tempDiff < diff) {
      tempX = x-1;
      current = pixels[loc];
      diff = tempDiff;
    }

    // update variables
    x = tempX;
    y = tempY;
    path = append(path, y*width + x);
  }
}

