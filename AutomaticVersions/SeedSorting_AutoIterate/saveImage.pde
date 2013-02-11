
// save with parameters
void saveImage() {
  
  println("Saving image...");
  String output = outputFolder + "/" + stripFileExtension(filename);   // strip ext to rename for saving, put in directory

  // add settings as specified
  
  // created w/ edge detection
  if (edgeSeed) {
    output += "_edgeSeed";
    // output += "_" + step + "steps";
    output += "_" + int(thresh) + "thresh";
    output += "_" + distThresh + "dist";
  }
  
  // created w/ random seed
  else {
    output += "_randomSeed";
    // output += "_" + step + "steps";
    output += "_" + numRandSeeds + "randSeeds";
  }  

  // diagonal and extension
  if (getDiagonal) {
    output += "_diagonal";
  }
  else {
    output += "_noDiagonal";
  }
  output += ".tiff";

  // save!
  save(output);
}

