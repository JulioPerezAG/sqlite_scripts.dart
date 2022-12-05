import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlite_scripts_generator/src/sqlite_scripts_generator.dart';

Builder sqliteScripts(BuilderOptions options) =>
    SharedPartBuilder([SqliteScriptsGenerator()], 'sqliteScripts');
