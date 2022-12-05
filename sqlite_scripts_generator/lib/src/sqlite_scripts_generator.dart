import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlite_scripts_annotation/sqlite_scripts_annotation.dart';
import 'package:sqlite_scripts_generator/src/utils/string_utils.dart';

class SqliteScriptsGenerator extends GeneratorForAnnotation<Table> {
  // Annotation checkers
  static final _tableChecker = TypeChecker.fromRuntime(Table);
  static final _columnChecker = TypeChecker.fromRuntime(Column);
  static final _idChecker = TypeChecker.fromRuntime(Id);

  // DataType checkers
  static final _stringChecker = TypeChecker.fromRuntime(String);
  static final _intChecker = TypeChecker.fromRuntime(int);
  static final _boolChecker = TypeChecker.fromRuntime(bool);

  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement || element is EnumElement) {
      throw InvalidGenerationSourceError('`@Table` can only be used on classes',
          element: element);
    }

    if (!hasAnnotationOfExact(element, _tableChecker)) {
      throw InvalidGenerationSourceError('`@Table` is not found in this class',
          element: element);
    }

    String tableName =
        tableAnnotationFromElement(element)?.name ?? element.name.toUnderscoreCase();

    String columnDefs = getValidFields(element).map((element) => buildColumnDef(element)).join(', ');

    String script = 'CREATE TABLE $tableName($columnDefs)';

    return "String _\$${element.name}TableName = '$tableName'; String _\$${element.name}TableCreationScript = '$script;';";
  }

  List<FieldElement> getValidFields(ClassElement classElement) {
    return classElement.fields
        .where((element) => _columnChecker.hasAnnotationOfExact(element,
            throwOnUnresolved: false))
        .toList();
  }

  String? tableNameFromElement(Element element) => element.metadata.first
      .computeConstantValue()
      ?.getField('name')
      ?.toStringValue();

  String? tableNameFromConstantReader(ConstantReader annotation) =>
      annotation.objectValue.getField('name')?.toStringValue();

  Table? tableAnnotationFromElement(ClassElement element) {
    DartObject? annotation =
        _tableChecker.firstAnnotationOfExact(element, throwOnUnresolved: false);
    if (annotation != null) {
      return Table(name: annotation.getField('name')?.toStringValue() ?? '');
    }
    return null;
  }

  Column? columnAnnotationFromElement(FieldElement element) {
    DartObject? annotation = _columnChecker.firstAnnotationOfExact(element,
        throwOnUnresolved: false);
    if (annotation != null) {
      return Column(
          name: annotation.getField('name')?.toStringValue() ?? '',
          nullable: annotation.getField('nullable')?.toBoolValue() ?? false,
          dataType: DataType.fromString(
              annotation.getField('dataType')?.toStringValue()));
    }
    return null;
  }

  bool hasAnnotationOfExact(Element element, TypeChecker typeChecker) {
    return typeChecker.hasAnnotationOfExact(element, throwOnUnresolved: false);
  }

  String buildColumnDef(FieldElement element) {
    TypeChecker.fromRuntime(String).isAssignableFromType(element.type);

    bool isId = hasAnnotationOfExact(element, _idChecker);
    Column column = columnAnnotationFromElement(element)!;

    String fieldType = getColumnType(element) ?? 'Object';

    String columnType = 'String';

    String columnName =
        column.name.isNotEmpty ? column.name : element.name.toUnderscoreCase();

    if (column.dataType != null) {
      if (!DataType.dataTypeAssignableFromType(column.dataType!, fieldType)) {
        throw InvalidGenerationSourceError(
            '${column.dataType} cannot be assigned to $fieldType type!',
            element: element);
      }
      columnType = column.dataType!.sqlName();
    } else {
      if (fieldType == 'int') {
        columnType = DataType.real.sqlName();
      } else if (fieldType == 'String') {
        columnType = DataType.text.sqlName();
      } else if (fieldType == 'bool') {
        columnType = DataType.integer.sqlName();
      } else if (fieldType == 'Object') {
        columnType = DataType.blob.sqlName();
      }
    }

    return '$columnName $columnType${isId ? ' PRIMARY KEY' : ''}';
  }

  String? getColumnType(FieldElement element) {
    if (_stringChecker.isAssignableFromType(element.type)) {
      return "String";
    } else if (_boolChecker.isAssignableFromType(element.type)) {
      return "bool";
    } else if (_intChecker.isAssignableFromType(element.type)) {
      return "int";
    } else {
      return null;
    }
  }
}
