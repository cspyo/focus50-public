extension VersionCompare on String {
  bool isGreaterThanOrEqual(String s) {
    final splittedThis = this.split('.');
    final splittedThat = s.split('.');
    int majorThis = int.parse(splittedThis[0]);
    int minorThis = int.parse(splittedThis[1]);
    int patchThis = int.parse(splittedThis[2]);
    int majorThat = int.parse(splittedThat[0]);
    int minorThat = int.parse(splittedThat[1]);
    int patchThat = int.parse(splittedThat[2]);

    if (majorThis > majorThat) {
      return true;
    } else if (majorThis == majorThat && minorThis > minorThat) {
      return true;
    } else if (majorThis == majorThat &&
        minorThis == minorThat &&
        patchThis >= patchThat) {
      return true;
    } else {
      return false;
    }
  }

  bool isLessThan(String s) {
    return !this.isGreaterThanOrEqual(s);
  }
}
