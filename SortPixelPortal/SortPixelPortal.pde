
/*
SORT PIXEL PORTAL
 Jeff Thompson | 2013 | www.jeffreythompson.org
 
 Sort columns of pixels of a specified length; sort the results and use the last
 pixel as a seed to find a new random starting point with a similar color.  Also
 keeps track of the pixels that have already been "traversed" by the algorithm,
 preventing the same parts of the image from being processed twice.
 
 FLAGS (not errors, just to let you know what's happening inside the program):
 t = path ran into an already-traversed pixel, being cut short
 o = path ran offscreen, being cut short
 r = no suitable seed found, picking a random point instead
 
 */

String filename = "../SourceImageFiles/mountains/06.jpg";

int maxIterations = 2000;               // max # of times to go through the image 
int dist = 200;                         // maximum distance downward to travel
int margin = 50;                        // margin of error for finding the next seed pixel
boolean saveIt = true;                  // save the output to high-res file?

// set global variables for efficiency - avoids allocating them each pixel
int pos, x, y;                          // location variables, set in code below
float r, g, b, tr, tb, tg;              // color variables for comparing new seed positions
color t;                                // temp color to compare pixels in image
int[] traversed = new int[0];           // array to store pixels we've already traversed (avoids duplicates)


void setup() {

  // load source, display and get its pixels
  PImage img = loadImage(filename);
  size(img.width, img.height);
  image(img, 0, 0);
  loadPixels();

  // create initial starting position (ensuring enough room to draw a full line down)
  pos = int(random(width, height*width-width*dist));

  // go through image!
  int numIterations = 0;
  while (numIterations < maxIterations) {

    // let us know where we're at in the image
    y = pos/width;
    x = pos - y*width;
    print("\n" + numIterations + ":\t" + x + "/" + y + "\t(" + nfc(pos) + ")\t");    // space at end for flags (so the newline at start)

    // load a strip of colors down from starting point
    color[] c = new color[0];            // 0 length and add; in case we runn offscreen
    int[] path = new int[0];             // same for the path
    for (int i=0; i<dist; i++) {

      // don't try to load pixels that are off the image's bottom - if they are, stop
      if (pos < width*height) {
        if (!alreadyStored(pos, traversed)) {      // make sure we haven't already traversed those pixels (if so, also stop)
          c = append(c, pixels[pos]);              // if we're still in the image, add color to array
          path = append(path, pos);                // store the locations as well
          traversed = append(traversed, pos);      // add the px to the array of traversed pixels
          pos += width;                            // update position to the pixel below
        }
        else {
          print(" t");
          break;
        }
      }
      else {
        print(" o");
        break;     // if off the image, stop the process and continue to sorting
      }
    }

    // sort the results!
    c = sort(c);

    // put the results back into the image!
    for (int i=0; i<path.length; i++) {
      // optionally, set the first pixel to red so we can see the process better
      if (i==0) {
        pixels[path[0]] = color(255, 0, 0);
      }
      pixels[path[i]] = c[i];
    }

    // get the last color as our new seed, find an instance of that color
    // elsewhere in the image (within a margin) and set to our new start position
    if (c.length > 0) {
      color last = c[c.length-1];
      int[] nextCandidates = findNext(last);                       // get a list of potential new seed px
      if (nextCandidates.length == 0) {                            // if we've not found a suitable seed, end process
        break;
      }
      pos = nextCandidates[int(random(nextCandidates.length))];    // get a new, random seed from the list
    }
    // if getting a new seed fails, get a random one instead
    else {
      print(" r");
      pos = int(random(0, width*height));
    }
    numIterations++;                                             // update the iteration count
  }

  // all done? update image to display
  updatePixels();

  // see how many pixels were left untraversed
  println("\n\nPixels traversed:         " + nfc(traversed.length));
  println("Pixels not yet traversed: " + nfc(width*height - traversed.length));

  // save if speficied
  if (saveIt) {
    String output = stripExtension(filename);
    save(output + "_" + maxIterations + "iter_" + dist + "dist.tiff");
  }
}


boolean alreadyStored(int val, int[] array) {
  array = sort(array);
  for (int i=0; i<array.length; i++) {
    if (array[i] == val) {
      return true;
    }
  }
  return false;
}


int[] findNext(color c) {

  // seed color values (using the faster method)
  r = c >> 16 & 0xFF;
  g = c >> 8 & 0xFF;
  b = c & 0xFF;
  int[] results = new int[0];

  // go through entire image, looking for candidates to be the new seed
  for (int i=0; i<width*height; i++) {

    // load each pixel from the image
    t = pixels[i];
    tr = t >> 16 & 0xFF;
    tg = t >> 8 & 0xFF;
    tb = t & 0xFF;

    // if we're close enough (within the margin either way), add to the list
    if (r-tr < margin && r-tr > -margin && g-tg < margin && g-tg > -margin && b-tg < margin && b-tg > -margin) {
      results = append(results, i);
    }
  }

  // all done? send the results back
  return results;
}

String stripExtension(String s) {
  s = s.substring(s.lastIndexOf('/')+1, s.length());
  s = s.substring(s.lastIndexOf('\\')+1, s.length());
  s = s.substring(0, s.lastIndexOf('.'));
  return s;
}

