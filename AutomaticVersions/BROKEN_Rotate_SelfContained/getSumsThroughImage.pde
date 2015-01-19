
float[][] getSumsThroughImage(PImage img) {

  // 2d array of the sums as we go down the image
  // see the Wikipedia entry listed in the head for
  // a good explanation of what's happening here
  float[][] sums = new float[img.height][img.width];

  // read first row
  for (int x=0; x<img.width; x++) {
    sums[0][x] = red(img.pixels[x]);
  }

  // read the rest
  for (int y=1; y<img.height; y++) {          // start with 1, since we already read 0
    for (int x=1; x<img.width-1; x++) {       // read from the 2nd to 2nd-to-last px

      float currentPx = red(img.pixels[y*width + x]);

      // test above L,C, and R sums
      float sumL = sums[y-1][x-1] + currentPx;
      float sumC = sums[y-1][x] + currentPx;
      float sumR = sums[y-1][x+1] + currentPx;
      if (sumL < sumC && sumL < sumR) {
        sums[y][x] = sumL;
      }
      else if (sumC < sumL && sumC < sumR) {
        sums[y][x] = sumC;
      }
      else {
        sums[y][x] = sumR;
      }
    }
  }

  // return the array of the sums of the image
  return sums;
}

