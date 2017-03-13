// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';
import 'package:angular_ast/angular_ast.dart';

RecoveringExceptionHandler exceptionHandler = new RecoveringExceptionHandler();

List<StandaloneTemplateAst> parse(String template) =>
    const NgParser().parsePreserve(
      template,
      sourceUrl: '/test/parser_test.dart#inline',
      exceptionHandler: exceptionHandler,
    );

void main() {
  String input;
  while (true) {
    if (exceptionHandler is RecoveringExceptionHandler) {
      exceptionHandler.exceptions.clear();
    }
    input = stdin.readLineSync(encoding: UTF8);
    if (input == 'QUIT') {
      break;
    }
    var ast = parse(input);
    print("----------------------------------------------");
    if (exceptionHandler is ThrowingExceptionHandler) {
      print('CORRECT!');
      print(ast);
    }
    if (exceptionHandler is RecoveringExceptionHandler) {
      var exceptionsList = exceptionHandler.exceptions;
      if (exceptionsList.isEmpty) {
        print('CORRECT!');
        print(ast);
      } else {
        var visitor = const HumanizingTemplateAstVisitor();
        var fixed = ast.map((t) => t.accept(visitor)).join('');
        print('ORGNL: $input');
        print('FIXED: $fixed');
      }
      print('\n\nERRORS:');
      exceptionHandler.exceptions.forEach((e) {
        print('${e.message} :: ${e.context} at ${e.offset}');
      });
    }
  }
}
