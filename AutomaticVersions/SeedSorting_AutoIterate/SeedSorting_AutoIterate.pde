
/*
SEED SORTING (ie: sort with edge detection or random seeds)
 Jeff Thompson | 2013 | www.jeffreythompson.org
 
 A version for auto-iterating - see 'Seed Sorting' for documentation.
 
 */

// folder to load from - full path required
String fullPath = "/Volumes/Storage/Documents/Processing/PixelSorting/AutomaticVersions/SortThroughSeamCarving_AutoIterate/";
File folder = new File(fullPath + "source");
String[] imageList = new String[0];

// general settings
boolean getDiagonal = true;                             // get diagonal neighbors? true makes boxes, false diamonds**
int steps = 2500;                                       // # of steps to expand/sort
boolean saveIt = true;                                  // save the result?
boolean verbose = true;                                 // tell us everything about what's happening?
boolean edgeSeed = true;                                // use edge-detection or random seed?

// ** note that if diagonal neighbors is disabled, some pixels may be unreachable (which can also be cool!)

// edge-detection settings
boolean limitSeeds = true;                              // remove redundant seeds from edge-detection
int distThresh = 400;                                   // remove seeds that are too close
float thresh = 0.1;                                     // edge-detection threshold (lower = less edges)

// random seed settings
int numRandSeeds = 30;                                  // if using random seeds, how many to start?

ArrayList<Integer> seeds;                               // seed pixels to find neighbors for**
boolean[] traversed;                                    // keep track of pixels we have traversed
int step;                                               // count steps through the image
PImage img;                                             // variable to load in image
boolean finishIt = false;                               // hit spacebar to stop the process manually!

int numIterations = 30;
int iteration = 0;
boolean loadFilenames = true;
boolean allDone = false;
String filename;


void setup() {

  // load folder of images
  // http://www.javaprogrammingforums.com/java-programming-tutorials/3-java-program-can-list-all-files-given-directory.html
  if (loadFilenames) {
    if (folder.isDirectory()) {
      File[] allFiles = folder.listFiles();
      for (int i=0; i<allFiles.length; i++) {
        if (allFiles[i].isFile()) {
          imageList = append(imageList, allFiles[i].getAbsolutePath());
        }
      }
    }
    // if we screwed up and just gave the program a single file, use that
    else {
      imageList = append(imageList, folder);
    }
    
    // don't do this again!
    loadFilenames = false;    // just do this once when the program starts
  }

  println("Loading image...");
  img = loadImage(filename);
  img.loadPixels();
  size(img.width, img.height);
  image(img, 0, 0);
  println("  dimensions: " + width + " x " + height + "\n");
  loadPixels();

  // intialize array of already-traversed
  seeds = new ArrayList<Integer>();
  seeds.clear();                              // delete any previous (just to be safe)
  traversed = new boolean[width*height];
  step = 0;                                   // reset here
}

void draw() {

  if (!allDone) {
    println("STEP: " + step + "/" + steps);

    // if we're on the first step, find the edges
    if (step == 0) {
      println("  finding edges...");
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
    }

    // otherwise, get neighbors, sort, and put back in place
    else {
      if (verbose) {
        println("  gathering neighboring pixels...");
      }
      updateSeeds();

      // retrieve
      if (verbose) {
        println("  getting color values from neighboring pixels...");
      }
      color[] px = new color[seeds.size()];
      for (int i = seeds.size()-1; i >= 0; i--) {
        px[i] = pixels[seeds.get(i)];
      }

      // sort the results
      if (verbose) {
        println("  sorting the results...");
      }
      px = sort(px);

      // set the resulting pixels back into place
      if (verbose) {
        println("  setting sorted pixels into place...\n");
      }
      for (int i = seeds.size()-1; i >= 0; i--) {
        pixels[seeds.get(i)] = px[i];
      }
    }

    // so long as we're not at our limit (and not manually stopped) continue!
    if (step < steps && !finishIt) {
      step++;
      updatePixels();    // update to display the results
    }
    else {
      // save results
      if (saveIt) {
        saveImage();
      }

      // if we're not done iterating, update and restart; otherwise quit!
      if (iteration < numIterations) {
        println("NEXT!");
        if (edgeSeed) {
        }
        else {
        }
        setup();
      }
      else {
        allDone = true;
      }
    }
  }
  println("- - -\nALL DONE!");
  noLoop();
}

void keyPressed() {
  if (key == 32) {
    if (!finishIt) {
      finishIt = true;
    }
    else {
      finishIt = false;
      loop();
    }
  }
}

