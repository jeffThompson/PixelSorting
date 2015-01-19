
// standard edge-detection, mostly via the Processing example!
void findEdges(PImage source) {

  float[][] kernel = {
    { 
      -1, -1, -1
    }
    , 
    { 
      -1, 9, -1
    }
    , 
    { 
      -1, -1, -1
    }
  };

  source.loadPixels();
  for (int y = 1; y < source.height-1; y++) {                 // skip top and bottom edges
    for (int x = 1; x < source.width-1; x++) {                // skip left and right edges
      float sum = 0;                                          // kernel sum for this pixel
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          int position = (y + ky)*source.width + (x + kx);    // calculate the adjacent pixel for this kernel point
          float val = red(source.pixels[position]);           // image is grayscale, red/green/blue are identical
          sum += kernel[ky+1][kx+1] * val;                    // multiply adjacent pixels based on the kernel values
        }
      }

      // if the result is below the threshold, store to list
      // of traversed pixels and set them in 'flag' array
      if (sum < thresh) {
        seeds.add(y*source.width + x);
        traversed[y*source.width + x] = true;
      }
    }
  }
  println("  found " + nfc(seeds.size()) + " edge pixels");

  // if we've requested to limit the seeds, remove redundant samples
  // NOTE: this is (at the moment) a very stupid system - it finds a pixel and removes
  // any other pixels within a certain range; a better method would be to find clusters,
  // then their center and remove others
  if (limitSeeds) {
    println("  culling neighboring pixels (may take a while)...");
    ArrayList<Integer> results = new ArrayList<Integer>();    // create new ArrayList to store pixels that aren't too close
all: 
    for (Integer current : seeds) {                           // label 'all' allows us to continue to outer for loop
      int cx = current % width;                               // get x/y coords of current point
      int cy = current / width;
      for (Integer other : results) {                         // iterate all other points (note this includes the current)
        int ox = other % width;                               // get x/y of other point
        int oy = other / width;
        float d = dist(cx, cy, ox, oy);                       // find distance between the two
        if (d > 0 && d < distThresh) {                        // first tests for the current point, the second if we're far enough away
          continue all;                                       // break out and add
        }
      }
      results.add(current);                                   // we made it! add to the results list
      traversed[current] = false;
    }
    seeds = results;                                          // set to original ArrayList for code-clarity
    println("  reduced seeds to " + nfc(seeds.size()) + " pixels");
  }
}





