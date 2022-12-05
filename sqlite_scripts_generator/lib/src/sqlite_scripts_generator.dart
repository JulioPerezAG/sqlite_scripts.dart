import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlite_scripts_annotation/sqlite_scripts_annotation.dart';

class SqliteScriptsGenerator extends GeneratorForAnnotation<Table> {
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return "// Found annotation";
  }
}
