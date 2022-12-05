enum DataType {
  integer(['int', 'bool']),
  real(['int']),
  text(['String']),
  blob(['String', 'Object']);

  const DataType(this._assignableFromType);

  final List<String> _assignableFromType;

  static DataType? fromString(String? strEnum) {
    if (strEnum == null) {
      return null;
    }
    strEnum = strEnum.toLowerCase();
    return DataType.values.firstWhere(
        (element) => element.name.toLowerCase() == strEnum,
        orElse: null);
  }

  bool assignableFromType(String type) {
    return this._assignableFromType.contains(type);
  }

  static bool dataTypeAssignableFromType(DataType dataType, String type) {
    return dataType._assignableFromType.contains(type);
  }

  String sqlName() {
    return this.name.toUpperCase();
  }
}
