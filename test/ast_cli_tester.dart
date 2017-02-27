// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';
import 'package:angular_ast/angular_ast.dart';

RecoveringExceptionHandler exceptionHandler = new RecoveringExceptionHandler();
//ThrowingExceptionHandler exceptionHandler = new ThrowingExceptionHandler();

List<StandaloneTemplateAst> parse(String template) {
  return const NgParser().parse(
    template,
    sourceUrl: '/test/parser_test.dart#inline',
    exceptionHandler: exceptionHandler,
  );
}

void main() {
  String input;
  while (true) {
    if (exceptionHandler is RecoveringExceptionHandler) {
      exceptionHandler.exceptions.clear();
    }
    input = stdin.readLineSync(encoding: UTF8);
    if (input == "QUIT") {
      break;
    }
    List<StandaloneTemplateAst> ast = parse(input);
    print("----------------------------------------------");
    if (exceptionHandler is ThrowingExceptionHandler) {
      print("CORRECT!");
    }
    if (exceptionHandler is RecoveringExceptionHandler) {
      final exceptionsList = exceptionHandler.exceptions;
      if (exceptionsList.isEmpty) {
        print("CORRECT!");
      } else {
        HumanizingTemplateAstVisitor visitor =
            const HumanizingTemplateAstVisitor();
        String fixed = ast.map((t) => t.accept(visitor)).join('');
        print("ORGNL: " + input);
        print("FIXED: " + fixed);
      }
      print('\n\nERRORS:');
      print(exceptionHandler.exceptions);
    }
  }
}
