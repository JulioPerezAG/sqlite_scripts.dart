extension StringUtils on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }

  String uncapitalize() {
    return "${this[0].toLowerCase()}${this.substring(1).toLowerCase()}";
  }

  String toUnderscoreCase() {
    RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
    return this
        .replaceAllMapped(
            exp, (Match m) => m.group(0) != null ? ('_' + m.group(0)!) : '')
        .toLowerCase();
  }
}
