
void runKernels(PImage hImg, PImage vImg) {

  float[][] vertKernel = { 
    { 
      -1, 0, 1
    }
    , 
    { 
      -1, 0, 1
    }
    , 
    { 
      -1, 0, 1
    }
  };
  float[][] horizKernel = { 
    {  
      1, 1, 1
    }
    , 
    {  
      0, 0, 0
    }
    , 
    { 
      -1, -1, -1
    }
  };

  // different kernels, but using the algorithm from
  // the Processing edge detection algorithm...

  // horizontally
  for (int y = 1; y < img.height-1; y++) {
    for (int x = 1; x < img.width-1; x++) {
      float sum = 0;
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          int pos = (y + ky)*img.width + (x + kx);
          float val = red(img.pixels[pos]);
          sum += horizKernel[ky+1][kx+1] * val;
        }
      }
      hImg.pixels[y*img.width + x] = color(sum);
    }
  }
  hImg.updatePixels();

  // .. and then again vertically
  for (int y = 1; y < img.height-1; y++) {
    for (int x = 1; x < img.width-1; x++) {
      float sum = 0;
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          int pos = (y + ky)*img.width + (x + kx);
          float val = red(img.pixels[pos]);
          sum += vertKernel[ky+1][kx+1] * val;
        }
      }
      vImg.pixels[y*img.width + x] = color(sum);
    }
  }
  vImg.updatePixels();

  // combine the two matrices
  for (int i=0; i<img.pixels.length; i++) {
    img.pixels[i] = color(red(hImg.pixels[i]) + red(vImg.pixels[i]));
  }

  // returns the image with pixels manipulated
  img.updatePixels();
}

