
// get new seed pixels (surrounding neighbors)
void updateSeeds() {

  // iterate the seed pixels, in reverse so we can remove them
  for (int i = seeds.size()-1; i >= 0; i--) {

    // extract x/y position from position in array
    int x = seeds.get(i) % width;
    int y = seeds.get(i) / width;

    // get neighboring pixels, check if they have already
    // been stored - if not, add them to the list and flag them
    // as traversed

    // UP
    int upIndex = seeds.get(i) - width;
    if (y > 0 && !traversed[upIndex]) {
      seeds.add(upIndex);
      traversed[upIndex] = true;
    }

    // RIGHT
    int rightIndex = seeds.get(i) + 1;
    if (x < width-1 && !traversed[rightIndex]) {
      seeds.add(rightIndex);
      traversed[rightIndex] = true;
    }

    // DOWN
    int downIndex = seeds.get(i) + width;
    if (y < height-1 && !traversed[downIndex]) {
      seeds.add(downIndex);
      traversed[downIndex] = true;
    }

    // LEFT
    int leftIndex = seeds.get(i) - 1;
    if (x > 0 && !traversed[leftIndex]) {
      seeds.add(leftIndex);
      traversed[leftIndex] = true;
    }

    // if specified, get diagonal neighbors too...
    if (getDiagonal) {
      
      // UL
      int ulIndex = seeds.get(i) - width - 1;
      if (x > 0 && y > 0 && !traversed[ulIndex]) {
        seeds.add(ulIndex);
        traversed[ulIndex] = true;
      }

      // LL
      int llIndex = seeds.get(i) + width - 1;
      if (y < height-1 && !traversed[llIndex]) {
        seeds.add(llIndex);
        traversed[llIndex] = true;
      }

      // LR
      int lrIndex = seeds.get(i) + width + 1;
      if (x < width-1 && y < height-1 && !traversed[lrIndex]) {
        seeds.add(lrIndex);
        traversed[lrIndex] = true;
      }

      // UR
      int urIndex = seeds.get(i) - width + 1;
      if (y > 0 && !traversed[urIndex]) {
        seeds.add(urIndex);
        traversed[urIndex] = true;
      }
    }

    // remove the seed as we go!
    seeds.remove(i);
  }
}

