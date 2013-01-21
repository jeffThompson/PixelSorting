
// which is the greatest? returns 1 (r), 2 (g), or 3 (b)
int highestColor(float r, float g, float b) {

  int greatestColor = 0;
  float minVal = -1;          // account for 0s in the color (0 will be greater)
  if (r > minVal) {
    greatestColor = 1;
    minVal = r;
  }
  if (g > minVal) {
    greatestColor = 2;
    minVal = g;
  }
  if (b > minVal) {
    greatestColor = 3;
    minVal = b;
  }

  return greatestColor;
}
