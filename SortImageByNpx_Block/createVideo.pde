
void makeVideo(int vertBlock) {
  
  int fps = 24;
  String ffmpegInstall = "/usr/local/bin/";
  
  String exportFilename = "Tacos_" + vertBlock + "y.mov";
  String commandToRun;

  // ffmpeg -y -r 24 -i %01dx10px.png -vcodec png Tacos_y.mov
  println("\n  saving video...\n");
  commandToRun = ffmpegInstall + "ffmpeg -y -r " + fps + " -i " + nf(vertBlock,3) + "y/%01dx" + vertBlock + "px.png -vcodec png " + exportFilename;
  UnixCommand(commandToRun);

  println("DONE!\n");
}

// function for running Unix commands (like ffmpeg) inside Processing
void UnixCommand(String commandToRun) {
  File workingDir = new File(sketchPath(""));
  String returnedValues;
  try {
    Process p = Runtime.getRuntime().exec(commandToRun, null, workingDir);
    int i = p.waitFor();
    if (i == 0) {
      BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
      while ( (returnedValues = stdInput.readLine ()) != null) {
        // enable this option if you want to get updates when the process succeeds
        // println("  " + returnedValues);
      }
    }
    else {
      BufferedReader stdErr = new BufferedReader(new InputStreamReader(p.getErrorStream()));
      while ( (returnedValues = stdErr.readLine ()) != null) {
        // print information if there is an error or warning (like if a file already exists, etc)
        println("  " + returnedValues);
      }
    }
  }

  // if there is an error, let us know
  catch (Exception e) {
    println("Error, sorry!");  
    println("     " + e);
  }
}
