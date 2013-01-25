
import java.io.File;

/*
 SEAM SORTING
 Jeff Thompson | 2012 | www.jeffreythompson.org
 
 A version for auto-iterating through a folder of images - see
 'Seam Sorting' for documentation.
 
 */

boolean reverseIt = true;
boolean saveIt = true;
boolean go = false;

PImage img, original;
//boolean findNext = false;
float[][] sums;
int bottomIndex;
String filename;
File folder;  // folder to load from - loaded dynamically with selectFolder


void setup() {
  size(200,200);
  selectFolder("Choose directory of images...", "openDirectory");
}

void draw() {
  background(0);
}

void openDirectory(File f) {
  if (f != null && f.isDirectory()) {
    folder = f;
    sortImages();
    exit();
  }
} 
  

// put here so we can use the 'selectInput' method
void sortImages() {

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

  // do it!
  for (int iter=0; iter<imageList.length; iter++) {

    // load image
    filename = imageList[iter];
    println("Loading " + filename + " (" + (iter+1) + "/" + imageList.length + ")...");
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
      filename = stripFileExtension(filename);
      save("results/SeamSort_" + filename + ".tiff");
    }
    println("NEXT!\n- - -");
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

