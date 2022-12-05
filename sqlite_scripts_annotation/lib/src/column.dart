import 'package:sqlite_scripts_annotation/src/data_type.dart';

class Column {
  final String name;

  final bool nullable;

  final DataType? dataType;

  const Column({this.name = '', this.nullable = false, this.dataType});
}
