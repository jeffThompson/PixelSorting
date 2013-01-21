
String getFileSize(String filename) {
  
  String fileSize = "";
  File f = new File(filename);
  
  int fs = (int)f.length();
  
  if (fs < 1024) {                         // less than 1 kb
    fileSize += nfc(fs) + " bytes";
  }
  else if (fs > 1024 && fs < 1048576) {    // 1 kb - .99 MB
    fs /= 1024;
    fileSize += nfc(fs) + " kb";
  }
  else {
    fs /= 1048576;
    fileSize += nfc(fs) + " MB";                // larger? measure in megabytes
  }
  
  return fileSize;
}
