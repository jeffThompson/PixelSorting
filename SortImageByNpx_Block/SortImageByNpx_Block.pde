import toxi.color.*;
import toxi.util.datatypes.*;

/*
 PIXEL SORTING BY Npx BLOCKS
 Jeff Thompson | 2012 | www.jeffreythompson.org
 
 A toolkit for pixel sorting, mashing, and otherwise destroying images.
 
 Commented out with two ** is the Processing-only method for color sorting (which 
 results in some weird transitions).  Otherwise depends on Toxi's color sorting 
 utilities: http://hg.postspectacular.com/toxiclibs/overview
 
 */

// final int horizBlock = 5;
// final int vertBlock = 49;
String filename = "../SourceImageFiles/taco.jpg";
boolean resizeIt = true;           // resize?
final int outputWidth = 1920;      // pixels, or inches * resolution (300ppi)
final int outputHeight = 1080;

final boolean saveIt = true;       // save to file?
final boolean saveVideo = true;    // use ffmpeg to create video when done?
PImage img;


void setup() {

  img = loadImage(filename);
  size(img.width, img.height);
  int w = img.width/2;
  int h = img.height/2;
  
  println("Input dimensions: " + width + ", " + height);

  for (int vertBlock=42; vertBlock<h; vertBlock++) {        // note: must start at 2 or more!
    String yFolder = nf(vertBlock, 3) + "y";
    println("- - - - - -");
    
    for (int horizBlock=2; horizBlock<w; horizBlock++) {    // otherwise, this will never stop... :(

      // reload image
      println("  " + horizBlock + ", " + vertBlock);
      img = loadImage("taco.jpg");
      size(img.width, img.height);

      noSmooth();    // no smoothing preserves the hard pixel edges (which is good)

      img.loadPixels();

      for (int y=0; y<height-vertBlock; y+=vertBlock) {
        for (int x=0; x<width; x+=horizBlock) {

          ColorList cList = new ColorList();
          // ** color[] c = new color[horizBlock*vertBlock];

          for (int iy=0; iy<vertBlock; iy++) {
            for (int ix=0; ix<horizBlock; ix++) {
              TColor tc = TColor.BLACK.copy();
              tc = tc.setARGB(img.pixels[(y+iy) * width + (x+ix)]);
              cList.add(tc);
              // ** c[ix*iy] = img.pixels[(y+iy) * width + (x+ix)];
            }
          }

          cList = cList.clusterSort(AccessCriteria.BRIGHTNESS, AccessCriteria.HUE, 12, true);
          // ** cList = cList.sortByCriteria(AccessCriteria.HUE, false);    // simpler but less effective sorting
          // ** c = sort(c);

          for (int iy=0; iy<vertBlock; iy++) {
            for (int ix=0; ix<horizBlock; ix++) {
              img.pixels[(y+iy) * width + (x+ix)] = cList.get(ix*iy).toARGB();
              // ** img.pixels[(y+iy) * width + (x+ix)] = c[ix*iy];
            }
          }
        }
      }

      img.updatePixels();
      // ** img.pixels = cList.toARGBArray();

      // display the image, resize for output if necessary
      if (resizeIt) {                                       // if we've specified an output size
        size(outputWidth, outputHeight);                    // change window dims for new image size
        image (img, 0, 0, outputWidth, outputHeight);       // draw image to fill the window
      }
      else {
        image(img, 0, 0);                                   // otherwise, display as usual
      }

      // save the result?
      if (saveIt) {
        save(yFolder + "/" + horizBlock + "x" + vertBlock + "px.png");
      }
    }
    
    // save the video each y increment?
    if (saveVideo) {
      makeVideo(vertBlock);
    }
  }
}
