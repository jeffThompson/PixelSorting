
/*
  ROTATE IMAGES BY ANGLE
 Jeff Thompson | 2012 | www.jeffreythompson.org
 
 A little extra utility for rotating images.
 
 NOT WORKING YET...
 */

String fullPath;
String[] f = new String[0];
PImage img;

void setup() {
  selectFolder("Open Folder...", "openFolder");
  imageMode(CENTER);
}

void draw() {

  if (fullPath != null) {

    // get all image files
    File file = new File(fullPath);
    if (file.isDirectory()) {
      String[] allFiles = file.list();
      for (int i=0; i<allFiles.length; i++) {
        if (allFiles[i].contains("png") || allFiles[i].contains("jpg")) {
          f = append(f, fullPath + "/" + allFiles[i]);
          println("  " + allFiles[i]);
        }
      }
    }

    for (int i=0; i<f.length; i++) {
      img = loadImage(f[i]);
      int rotAngle = i*90;
      
      //size(img.width, img.height);
      //image(img, 0,0);
      
      // is the image rotated from the original? if so, set back
      if ((rotAngle/90) % 2 == 1) {    // 1 means rotated by 90 from original, 0 means same but maybe flipped
        // rotate -90º
        background(0);
        size(height, width);
        pushMatrix();
        translate(width/2, height/2);
        rotate(radians(-90));
        image(img, 0, 0);
        popMatrix();
      }

      if ((rotAngle/180) % 2 == 1) {   // 1 means the image if upside down
        // rotate back -180º
        background(0);
        pushMatrix();
        translate(width/2, height/2);
        rotate(radians(180));
        image(img, 0, 0);
        popMatrix();
      }

      // once rotated, save and continue
      String filename = new File(f[i]).getName();
      filename = stripFileExtension(filename);
      save("rotated/" + filename + ".tiff");
    }

    noLoop();
    exit();
  }
}

// strip file extension for saving and renaming
String stripFileExtension(String s) {
  s = s.substring(s.lastIndexOf('/')+1, s.length());
  s = s.substring(s.lastIndexOf('\\')+1, s.length());
  s = s.substring(0, s.lastIndexOf('.'));
  return s;
}

// open an image file
void openFolder(File f) {

  // if the file is successfully chosen...
  if (f != null) {

    // get the full path to the file and print
    fullPath = f.getAbsolutePath();
    println("Directory: " + fullPath);
  }

  // if the user cancels the open operation, we would normally do nothing...
  else {
    println("Please select a directory, try again!");
  }
}

