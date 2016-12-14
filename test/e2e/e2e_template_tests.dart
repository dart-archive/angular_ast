import 'dart:io';

import 'package:angular_ast/angular_ast.dart';
import 'package:path/path.dart' as p;

import 'package:test/test.dart';

main() {
  final parse = const NgParser().parse;
  final templatesDir = p.join('test', 'e2e', 'templates');

  // Just assert that we can parse all of these templates without failing.
  new Directory(templatesDir).listSync().forEach((file) {
    if (file is File) {
      test('should parse ${p.basenameWithoutExtension(file.path)}', () {
        parse(file.readAsStringSync());
      });
    }
  });
}
