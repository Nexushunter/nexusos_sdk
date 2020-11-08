extension Nameparsing on String {
  parseName() {
    // TODO: Make platform safe
    var trailingSep = this.lastIndexOf('/');
    // Not present assuming this is the application name;
    return trailingSep == -1 ? this : this.substring(trailingSep + 1);
  }
}
