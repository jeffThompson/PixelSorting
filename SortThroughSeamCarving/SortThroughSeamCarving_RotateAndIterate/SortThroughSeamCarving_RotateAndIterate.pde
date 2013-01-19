import toxi.color.*;
import toxi.util.datatypes.*;

/*
 SEAM SORTING
 Jeff Thompson | 2012 | www.jeffreythompson.org
 
 Find the seam (pathway) with the lowest energy vertically through the
 image.  The underlying process, called "seam carving", is similar to
 the algorithm used for Photoshop's "content-aware scaling".
 
 This version loads the image, sorts it, then reloads the image, rotates
 90º and sorts again, repeating this process as many times as specified.
 
 Commented out with two ** is the Processing-only method for color sorting (which 
 results in some weird transitions).  Otherwise depends on Toxi's color sorting 
 utilities: http://hg.postspectacular.com/toxiclibs/overview
 
 Built heavily from examples on:
 http://en.wikipedia.org/wiki/Seam_carving#Dynamic_Programming
 
 www.jeffreythompson.org
 */

String filename = "../../SouceImageFiles/sheep.jpg";

int numIterations = 1000;                // how many times to rotate/sort
boolean sortRegular = true;              // sort regular (colors as long #s) or "fancy" using the toxi lib**
boolean reverseIt = false;               // sort ascending or descending?

// ** different sorting methods result in very different images - experimentation is key

PImage img, original;
float[][] sums;
int bottomIndex = 0;
int rotAngle = 0;

void setup() {

  // load, rotate, sort, repeat
  for (int iter = 0; iter<numIterations; iter++) {

    // load image
    println("IMAGE " + (iter+1) + " / " + numIterations);
    println("Loading source image...");
    img = loadImage(filename);

    // rotate (first time around we rotate by 0º so nothing happens)
    PGraphics pg = createGraphics(img.height, img.width);
    pg.beginDraw();
    pg.pushMatrix();
    pg.translate(pg.width/2, pg.height/2);
    pg.rotate(radians(90));                             // rotate by 90º
    pg.image(img, -img.width/2, -img.height/2);         // place image on rotated PGraphics
    pg.popMatrix();
    pg.endDraw();
    img = pg.get();                                     // load PImage from the result
    original = pg.get();                                // ditto the copy

    // set size to image's new dimensions
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

    // display and load pixels
    image(img, 0, 0);
    loadPixels();

    // get start point
    bottomIndex = width/2;                            // start at bottom center
    // bottomIndex = findStartPoint(sums, 50);        // or get "best" (lowest energy)
    println("Starting index: " + bottomIndex + "\n");

    // find the pathway with the lowest information
    int[] path = new int[height];
    path = findPath(bottomIndex, sums, path);

    // iterate and sort!
    for (int bi=0; bi<width; bi++) {

      // get the pixels of the path from the original image
      original.loadPixels();
      color[] c = new color[path.length];            // create array of the seam's color values
      ColorList cl = new ColorList();                // ColorList for fancy sorting - here to be accessible later
      for (int i=0; i<path.length; i++) {
        try {
          c[i] = original.pixels[i*width + path[i] + bi];      // set color array to values from original image
        }
        catch (Exception e) {
          // when we run out of pixels, just ignore
        }
      }

      // status update
      // println("  " + bi);

      // sort as numbers (makes cool glitches, but not as smooth)
      if (sortRegular) {
        c = sort(c);
        if (reverseIt) {
          c = reverse(c);
        }
      }
      // or do via "better" sorting - smoother and more options, fewer glitches
      else {
        cl.createFromARGBArray(c, c.length, false);                  // create from colors, using all and allowing duplicates
        cl = cl.sortByCriteria(AccessCriteria.HUE, false);           // simpler but less effective sorting
        // cl = cl.clusterSort(AccessCriteria.BRIGHTNESS, AccessCriteria.HUE, 12, true);
      }

      // put pixels back in place
      for (int i=0; i<path.length; i++) {
        try {
          if (sortRegular) {
            original.pixels[i*width + path[i] + bi] = c[i];      // reverse! set the pixels of the original from sorted array
          }
          else {
            original.pixels[i*width + path[i] + bi] = cl.get(i).toARGB();
          }
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

    // save the result
    println("Saving file...");
    filename = stripFileExtension(filename);
    filename += "_" + nf(rotAngle, 6) + "degrees.png";
    rotAngle += 90;
    save(filename);

    println("MOVING ON!\n\n- - - - - - - -\n");
  }

  // all finished!
  println("ALL DONE!");
}

// strip file extension for saving and renaming
String stripFileExtension(String s) {
  s = s.substring(s.lastIndexOf('/')+1, s.length());
  s = s.substring(s.lastIndexOf('\\')+1, s.length());
  s = s.substring(0, s.lastIndexOf('.'));
  return s;
}

