
// either copy/paste this into your project, or copy this entire
// .pde file into your project to load it as a tab!

String stripFilename(String s) {
  s = s.substring(s.lastIndexOf('/')+1, s.length());
  s = s.substring(s.lastIndexOf('\\')+1, s.length());
  s = s.substring(0, s.lastIndexOf('.'));
  return s;
}
  
