// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/lexer.dart';
import 'package:angular_ast/src/parser/recursive.dart';
import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

class NgParser {
  @literal
  const factory NgParser() = NgParser._;

  // Prevent inheritance.
  const NgParser._();

  /// Return a series of tokens by incrementally scanning [template].
  List<StandaloneTemplateAst> parse(String template) {
    final tokens = const NgLexer().tokenize(template);
    return new RecursiveAstParser(new SourceFile(template), tokens).parse();
  }
}
