
import toxi.color.*;
import toxi.util.datatypes.*;
import java.io.File;

/*
SEED SORTING (ie: sort with edge detection or random seeds)
 Jeff Thompson | 2013 | www.jeffreythompson.org
 
 A version for auto-iterating - see 'Seed Sorting' for documentation.
 
 */

// folder of images to process
String input = "mountains_sunset";
String inputFolder = "/Volumes/Storage/Documents/Processing/PixelSorting/SourceImageFiles/" + input;

// general settings
boolean sortRegular = true;                             // use either Processing color sorting or toxi (NOT WORKING) 
boolean getDiagonal = false;                            // get diagonal neighbors? true makes boxes, false diamonds**
int steps = 5000;                                       // # of steps to expand/sort
int numIterations = 10;

boolean saveIt = true;                                  // save the result?
boolean verbose = false;                                // tell us everything about what's happening?
boolean edgeSeed = false;                                // use edge-detection or random seed?

// ** note that if diagonal neighbors is disabled, some pixels may be unreachable (which can also be cool!)

// edge-detection settings
boolean limitSeeds = true;                              // remove redundant seeds from edge-detection
int distThresh = 200;                                   // remove seeds that are too close
float thresh = 0.01;                                    // edge-detection threshold (lower = less edges)

// random seed settings
int numRandSeeds = 2;                                   // if using random seeds, how many to start?

String filename;
ArrayList<Integer> seeds = new ArrayList<Integer>();    // seed pixels to find neighbors for**
boolean[] traversed;                                    // keep track of pixels we have traversed
int step = 0;                                           // count steps through the image
PImage img;                                             // variable to load in image
String outputFolder = inputFolder.substring(inputFolder.lastIndexOf("/")+1, inputFolder.length());
File folder = new File(inputFolder);


void setup() {

  // load folder of images, somewhat via:
  // http://www.javaprogrammingforums.com/java-programming-tutorials/3-java-program-can-list-all-files-given-directory.html
  String[] imageList = new String[0];
  if (folder.isDirectory()) {
    File[] allFiles = folder.listFiles();
    for (int i=0; i<allFiles.length; i++) {
      if (allFiles[i].isFile() && !allFiles[i].getName().startsWith(".")) {    // ignore hidden files
        imageList = append(imageList, allFiles[i].getAbsolutePath());
      }
    }
  }

  for (int whichImage=0; whichImage<imageList.length; whichImage++) {
    filename = imageList[whichImage];    
    
    // iterate settings on image
    for (int iter=0; iter<numIterations; iter++) {     
      loadAndReset();
      sortPixels();
      
      // increment settings
      if (edgeSeed) {
        distThresh += 100;
      }
      else {
        numRandSeeds += 1;
      }
      
      println("\n- - - - - - -");
    }
    
    // reset settings
    if (edgeSeed) {
      distThresh = 200;
    }
    else {
      numRandSeeds = 2;
    }
  }

  println("DONE!");
  exit();
}

void loadAndReset() {

  g.removeCache(img);                            // delete from memory (avoids problems later)
  
  println("Loading \"" + filename + "\"...");
  img = loadImage(filename);

  size(img.width, img.height);
  image(img, 0, 0);
  println("  dimensions: " + width + " x " + height + "\n");

  // intialize array of already-traversed
  seeds.clear();
  traversed = new boolean[img.width * img.height];

  loadPixels();
}

void sortPixels() {

  println("    finding edges...");
  if (edgeSeed) {
    findEdges(img);
  }
  else {
    for (int i=0; i<numRandSeeds; i++) {
      int seed = int(random(0, width*height));
      seeds.add(seed);
      traversed[seed] = true;
    }
  }

  for (int step = 0; step<steps; step++) {
    println("  " + step + " / " + steps);

    // get neighbors, sort, and put back in place
    if (verbose) {
      println("    gathering neighboring pixels...");
    }
    updateSeeds();

    // retrieve
    if (verbose) {
      println("    getting color values from neighboring pixels...");
    }
    color[] px = new color[seeds.size()];
    ColorList cl = new ColorList();
    for (int i = seeds.size()-1; i >= 0; i--) {
      px[i] = pixels[seeds.get(i)];
    }

    // sort the results
    if (verbose) {
      println("    sorting the results...");
    }
    if (sortRegular) {
      px = sort(px);
    }
    else {
      cl.createFromARGBArray(px, img.pixels.length, false);
      cl = cl.sortByCriteria(AccessCriteria.HUE, false);
      println("    " + cl.size());
    }

    // set the resulting pixels back into place
    if (verbose) {
      println("    setting sorted pixels into place...\n");
    }
    //for (int i = seeds.size()-1; i >= 0; i--) {
    for (int i=0; i<seeds.size(); i++) {
      if (sortRegular) {
        pixels[seeds.get(i)] = px[i];
      }
      else {
        pixels[seeds.get(i)] = cl.get(i).toARGB();
      }
    }
    updatePixels();        // update to display the results
  }

  // save results
  if (saveIt) {
    saveImage();
  }
}

