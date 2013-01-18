
String filename = "highRes/whales.jpg";
boolean saveIt = true;
color[] seam;

void setup() {

  println("Loading image...");
  PImage img = loadImage(filename);

  size(img.width, img.height);
  println("  Drawing image to screen...");
  println("  Dimensions: " + width + "x, " + height + "y");
  image(img, 0, 0);

  loadPixels();
  
  for (int i=0; i<height/2; i++) {
    println("    " + i + "/" + height/2);
    seam = new color[0];
    getSeam(i);
    seam = sort(seam);
    drawSeam(i);
  }
  
  println("  Updating pixel array and drawing to screen...");
  updatePixels();
  
  if (saveIt) {
    println("  Saving image to file...");
    save("SpiralSort_" + filename);
  }
  
  println("DONE!");  
}

void getSeam(int offset) {
  // top & bottom
  for (int x=offset; x<width-offset; x++) {
    seam = append(seam, pixels[offset*width + x]);               // top
    seam = append(seam, pixels[(height-offset-1)*width + x]);    // bottom
  }
  
  // right & left
  for (int y=offset+1; y<height-offset-1; y++) {
    seam = append(seam, pixels[y*width + offset]);               // right
    seam = append(seam, pixels[y*width + width-offset]);         // left
  }
}

void drawSeam(int offset) {
  int index = 0;
  
  // top
  for (int x=offset; x<width-offset; x++) {
    pixels[offset*width + x] = seam[index];
    index++;
  }
  
  // right
  for (int y=offset+1; y<height-offset-1; y++) {
    pixels[y*width + width - offset] = seam[index];
    index++;
  }
  
  // bottom
  for (int x=width-offset-1; x>=offset; x--) {
    pixels[(height-offset-1)*width + x] = seam[index];
    index++;
  }  
  
  // left
  for (int y=height-offset-2; y>offset+1; y--) {
    pixels[y*width + offset] = seam[index];
    index++;
  }
}
