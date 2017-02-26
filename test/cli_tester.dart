// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';
import 'package:angular_ast/angular_ast.dart';

RecoveringExceptionHandler exceptionHandler = new RecoveringExceptionHandler();
Iterable<NgToken> tokenize(String html) {
  exceptionHandler.exceptions.clear();
  return const NgLexer().tokenize(html, exceptionHandler);
}

String untokenize(Iterable<NgToken> tokens) => tokens
    .fold(new StringBuffer(), (buffer, token) => buffer..write(token.lexeme))
    .toString();

void main() {
  String input;
  while (true) {
    input = stdin.readLineSync(encoding: UTF8);
    if (input == "QUIT") {
      break;
    }
    try {
      Iterable<NgToken> tokens = tokenize(input);
      String fixed = untokenize(tokens);
      if (input == fixed) {
        print("CORRECT(UNCHANGED): $input");
      } else {
        print("ORGNL: $input");
        print("FIXED: $fixed");
        print("ERRORS:" + exceptionHandler.exceptions.toString());
      }
    } catch (e) {
      print(e);
    }
  }
}
