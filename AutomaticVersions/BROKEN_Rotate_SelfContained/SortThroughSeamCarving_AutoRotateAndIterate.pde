import toxi.color.*;              // for color sorting
import toxi.util.datatypes.*;
import java.io.File;              // to read in folder's contents

/*
 SEAM SORTING
 Jeff Thompson | 2012 | www.jeffreythompson.org
 
 A somewhat fugly, wrapped-up version that loads an entire folder, processing each
 image a specified number of times!
 
 Saves to a folder of the original folder's name, plus details:
   results/inputFolder/originalFilename_rotationAngle.tiff
 
 Commented out with two ** is the Processing-only method for color sorting (which 
 results in some weird transitions).  Otherwise depends on Toxi's color sorting 
 utilities: 
   http://hg.postspectacular.com/toxiclibs/overview
   
 */

String sourceFolder = "/Volumes/Storage/Documents/Processing/PixelSorting/SourceImageFiles/deserts";
int numIterations = 40;           // how many times to rotate/sort

PImage img, original, hImg, vImg;
PGraphics pg;
float[][] sums;
int bottomIndex, rotAngle;
String outputFolder = sourceFolder.substring(sourceFolder.lastIndexOf("/"), sourceFolder.length());

void setup() {

  // load folder of images, somewhat via:
  // http://www.javaprogrammingforums.com/java-programming-tutorials/3-java-program-can-list-all-files-given-directory.html
  File folder = new File(sourceFolder);
  String[] imageList = new String[0];
  if (folder.isDirectory()) {
    File[] allFiles = folder.listFiles();
    for (int i=0; i<allFiles.length; i++) {
      if (allFiles[i].isFile() && !allFiles[i].getName().startsWith(".")) {    // ignore hidden files
        imageList = append(imageList, allFiles[i].getAbsolutePath());
      }
    }
  }

  // go through each file and process!
  for (String imageFile : imageList) {
      println(imageFile.substring(imageFile.lastIndexOf("/")+1, imageFile.length()));
      seamSort(imageFile, numIterations, true, false);
  }

  // all finished!
  println("ALL DONE!");
  exit();
}

void seamSort(String filename, int numIterations, boolean sortRegular, boolean reverseIt) {

  rotAngle = 0;
  bottomIndex = 0;

  // split off filename for use later
  String filenameNoDetails = stripFileExtension(filename);

  // load, rotate, sort, repeat
  for (int iter = 0; iter<numIterations; iter++) {

    // load image - if too large for our memory settings, we simply
    // skip it (rather than the whole sketch coming to a halt)
    println((iter+1) + " / " + numIterations);
    println("  Loading source image...");
    try {
      img = null;
      original = null;
      img = loadImage(filename);
    }
    catch (OutOfMemoryError oome) {
      println("    FILE TOO LARGE, skipping...");
      return;
    }

    // rotate - first iteration don't rotate...
    if (iter == 0) {
      original = img.get();
    }
    else {
      pg = null;
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

    // set size to image's new dimensions
    size(img.width, img.height);
    println("    " + img.width + " x " + img.height + " px");

    println("  Creating buffer images...");
    hImg = null;
    vImg = null;
    hImg = createImage(img.width, img.height, RGB);
    vImg = createImage(img.width, img.height, RGB);

    // draw image and convert to grayscale
    img.filter(GRAY);
    img.loadPixels();    // updatePixels is in the 'runKernals'

    // run kernels to create "energy map"
    println("  Running kernals on image...");
    runKernels(hImg, vImg);
    image(img, 0, 0);

    // sum pathways through the image
    println("  Getting sums through image...");
    sums = getSumsThroughImage(img);

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
    println("  Saving file...\n");
    filename = "results/" + outputFolder + "/" + filenameNoDetails + "_" + nf(rotAngle, 6) + "degrees.tiff";
    rotAngle += 90;
    save(sketchPath("") + filename);
  }
  println("\n- - - - - - - -\n");
}

// strip file extension for saving and renaming
String stripFileExtension(String s) {
  s = s.substring(s.lastIndexOf('/')+1, s.length());
  s = s.substring(s.lastIndexOf('\\')+1, s.length());
  s = s.substring(0, s.lastIndexOf('.'));
  return s;
}

