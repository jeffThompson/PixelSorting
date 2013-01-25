import toxi.color.*;
import toxi.util.datatypes.*;

/*
 SEAM SORTING - ROTATE AND ITERATE (AUTOMATIC VIA SHELL SCRIPT)
 Jeff Thompson | 2012 | www.jeffreythompson.org
 
 Fugly auto-version to be run via shell script.
 
 ARGUMENTS (required):
 1. filename to load (full path)
 2. output location (folder)
 2. # of iterations for each image (default 20)
 3. regular sorting (true) or toxi (false, default)
 4. reverse order of seam (default false)
 
 Memory leak
 
 */

String filename = "sample.jpg";          // default to the sample image
int numIterations = 2;                   // how many times to rotate/sort (default 2);
boolean sortRegular = true;              // sort regular (colors as long #s) or "fancy" using the toxi lib**
boolean reverseIt = false;               // sort ascending or descending?

PImage img, original, hImg, vImg;
PGraphics pg;
float[][] sums;
int bottomIndex = 0;
int rotAngle = 0;
String outputLocation;


void setup() {

  // load arguments for settings
  if (args.length > 0) {
    filename = args[0];
    outputLocation = args[1];
    numIterations = Integer.parseInt(args[2]);
    sortRegular = Boolean.parseBoolean(args[3]);
    reverseIt = Boolean.parseBoolean(args[4]);
  }
  else {
    println("No arguments - running sample file at defaults\n\n");
  }

  // split off filename for use later
  String filenameNoDetails = stripFileExtension(filename);

  // load, rotate, sort, repeat
  for (int iter = 0; iter<numIterations; iter++) {

    // load image
    println((iter+1) + " / " + numIterations);
    println("  Loading \"" + filename.substring(filename.lastIndexOf("/")+1, filename.length()) + "\"");
    img = loadImage(filename);

    // rotate (first iteration, don't)
    if (iter > 0) {
      pg = createGraphics(img.height, img.width);
      pg.beginDraw();
      pg.pushMatrix();
      pg.translate(pg.width/2, pg.height/2);
      pg.rotate(radians(90));                             // rotate by 90º
      pg.image(img, -img.width/2, -img.height/2);         // place image on rotated PGraphics
      pg.popMatrix();
      pg.endDraw();
      img = pg.get();                                     // load PImage from the result
      original = pg.get();                                // ditto the copy
    }
    else {
      original = img.get();
    }

    // set size to image's new dimensions
    size(img.width, img.height);
    println("    " + width + " x " + height + " px");

    println("  Creating buffer images");
    hImg = createImage(img.width, img.height, RGB);
    vImg = createImage(img.width, img.height, RGB);

    // draw image and convert to grayscale
    image(img, 0, 0);
    img.filter(GRAY);
    img.loadPixels();    // updatePixels is in the 'runKernals'

    // run kernels to create "energy map"
    println("  Running kernels on image");
    runKernels(hImg, vImg);
    image(img, 0, 0);

    // sum pathways through the image
    println("  Getting sums through image");
    sums = getSumsThroughImage();

    // display and load pixels
    image(img, 0, 0);
    loadPixels();

    // get start point
    bottomIndex = width/2;                            // start at bottom center
    // bottomIndex = findStartPoint(sums, 50);        // or get "best" (lowest energy)
    println("  Starting index: " + bottomIndex);

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
    println("  Saving file\n");
    filename = outputLocation + "/" + filenameNoDetails + "_" + nf(rotAngle, 4) + "deg.tiff";
    rotAngle += 90;
    save(filename);
    
    // remove images from memory (seems to prevent memory leak on PImage instances)
    // via: https://forum.processing.org/topic/pimage-memory-leak-example#25080000001807951
    g.removeCache(img);
    g.removeCache(original);
    g.removeCache(pg);
    g.removeCache(hImg);
    g.removeCache(vImg);
  }

  // all finished!
  println("- - - - - - - -\n");
  exit();
}

// strip file extension for saving and renaming
String stripFileExtension(String s) {
  s = s.substring(s.lastIndexOf('/')+1, s.length());
  s = s.substring(s.lastIndexOf('\\')+1, s.length());
  s = s.substring(0, s.lastIndexOf('.'));
  return s;
}

