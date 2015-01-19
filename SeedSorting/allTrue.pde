
// does the traversed array contain false values (meaning NOT completely traversed)?
// via: http://stackoverflow.com/a/8260897/1167783
boolean allTrue(boolean[] array) {
  for (boolean b : array) {
    if (!b) {
      return false;      // contains false, return false
    }
  }
  return true;           // contains true, returns true
}
