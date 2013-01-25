
int findStartPoint(float[][] sums, int padding) {
  
  // find smallest value in the last row
  float minValue = 1000;                        // temp value to start (much higher than likely)
  for (int i=padding; i<width-padding; i++) {   // increment across bottom row **
    if (sums[height-1][i] < minValue) {         // if the current value is less than the previous low
      minValue = sums[height-1][i];             // update value (for future comparison)
      bottomIndex = i;                          // and update the index point
    }
  }
  
  // ** we pad the trip across on the L/R sides to avoid selecting the far edges
  //    and seems to avoid problems running offscreen
  
  // set current index in the sums array to a huge number so that it can't be chosen again
  sums[height-1][bottomIndex] = 1000;
  
  return bottomIndex;
}
