
int[] findPath(int bottomIndex, float[][] sums, int[] path) {

  // starting at the bottom index, go up row by row
  // looking for the smallest number, either to L,C, or R
  // of the current position
  int currentIndex = bottomIndex;
  for (int i=height-1; i>0; i-=1) {

    // if running the calculations on the row above to the L/R would
    // run us off the image (and cause an error), set the value to the edge
    if (currentIndex-1 <= 0) {
      path[i] = 0;
    }
    else if (currentIndex+1 >= width) {
      path[i] = width;
    }
    
    // otherwise, check the values above and above-L/R; use whichever has the
    // lowest value (energy) from the sums array
    else {
      float upL = sums[i-1][currentIndex-1];
      float upC = sums[i-1][currentIndex];
      float upR = sums[i-1][currentIndex+1];

      if (upL < upC && upL < upR) {          // if left is the smallest
        currentIndex += -1;
      }
      else if (upR < upC && upR < upL) {     // if right is the smallest
        currentIndex += 1;
      }
      // if up is smallest, do nothing

      // add to path array
      path[i] = currentIndex;
      // print(path[i] + " ");
    }
  }
  return path;
}
