
// TO DO: Multipass version that auto-rotates, sorts, exports, repeat N-times

/*
 SEAM SORTING
 Jeff Thompson | 2012 | www.jeffreythompson.org
 
 Find the seam (pathway) with the lowest energy vertically through the
 image.  The underlying process, called "seam carving", is similar to
 the algorithm used for Photoshop's "content-aware scaling".
 
 Built heavily from examples on:
 http://en.wikipedia.org/wiki/Seam_carving#Dynamic_Programming
 
 www.jeffreythompson.org
 */

/* file to read in:
 mountainLake.jpg
 face.jpg
 crowd.jpg
 missile.jpg
 sheep.jpg
 balloons.jpg
 snowyWoods.jpg
 explosion.jpg
 squirrel.jpg
 balugaWhale.jpg
 chili.jpg
 jungleScreensaver.jpg
 fireplace.jpg
 sphinx.jpg
 superMarioBrothers.png
 algae.jpg
 curry.jpg
 serialKiller.jpg
 poppies.jpg
 
 also, mountain images:
 mountains/01.jpg - mountains/08.jpg
 
 and high-resolution images:
 highRes/01.jpg - 10.jpg
 */
String filename = "multiPass/01.png";

boolean reverseIt = true;
boolean saveIt = true;

PImage img, original;
//boolean findNext = false;
float[][] sums;
int bottomIndex = 0;

void setup() {

  // load image
  println("Loading source image...");
  img = loadImage(filename);
  original = loadImage(filename);

  size(img.width, img.height);
  println("  " + width + " x " + height + " px");

  println("Creating buffer images...");
  PImage hImg = createImage(img.width, img.height, RGB);
  PImage vImg = createImage(img.width, img.height, RGB);

  // draw image and convert to grayscale
  image(img, 0, 0);
  filter(GRAY);
  img.loadPixels();    // updatePixels is in the 'runKernals'

  // run kernels to create "energy map"
  println("Running kernals on image...");
  runKernels(hImg, vImg);
  image(img, 0, 0);

  // sum pathways through the image
  println("Getting sums through image...");
  sums = getSumsThroughImage();

  image(img, 0, 0);
  loadPixels();

  // get start point (smallest value) - this is used to find the 
  // best seam (starting at the lowest energy)
  bottomIndex = width/2;
  // bottomIndex = findStartPoint(sums, 50);
  println("Bottom index: " + bottomIndex);

  // find the pathway with the lowest information
  int[] path = new int[height];
  path = findPath(bottomIndex, sums, path);

  for (int bi=0; bi<width; bi++) {

    // get the pixels of the path from the original image
    original.loadPixels();
    color[] c = new color[path.length];               // create array of the seam's color values
    for (int i=0; i<c.length; i++) {
      try {
        c[i] = original.pixels[i*width + path[i] + bi];      // set color array to values from original image
      }
      catch (Exception e) {
        // when we run out of pixels, just ignore
      }
    }

    println("  " + bi);

    c = sort(c);                                      // sort (use better algorithm later)
    if (reverseIt) {
      c = reverse(c);
    }

    for (int i=0; i<c.length; i++) {
      try {
        original.pixels[i*width + path[i] + bi] = c[i];      // reverse! set the pixels of the original from sorted array
      }
      catch (Exception e) {
        // when we run out of pixels, just ignore
      }
    }
    original.updatePixels();
  }

  // when done, update pixels to display
  updatePixels();

  // display the result!
  image(original, 0, 0);

  if (saveIt) {
    println("Saving file...");
    String f = filename.substring(0, filename.lastIndexOf('.'));
    save("sortedImages/" + f + "_seamSort.png");
  }
  
  println("DONE!");
}

