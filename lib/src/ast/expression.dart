// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/analyzer.dart';
import 'package:angular_ast/src/expression/parser.dart';

/// Wraps a parsed Dart [Expression] as an Angular [ExpressionAst].
class ExpressionAst {
  /// Dart expression.
  final Expression expression;

  /// Create a new expression AST wrapping a Dart expression.
  const ExpressionAst(this.expression);

  /// Create a new expression AST by parsing [expression].
  factory ExpressionAst.parse(
    String expression, {
    bool deSugarPipes: true,
    String sourceUrl: '/test.dart',
  }) {
    // Fall back in case this comes from a test w/o a real source URL.
    if (!sourceUrl.endsWith('.dart')) {
      sourceUrl = '/test.dart';
    }
    return new ExpressionAst(parseExpression(
      expression,
      deSugarPipes: deSugarPipes,
      sourceUrl: sourceUrl,
    ));
  }

  @override
  bool operator ==(Object o) {
    if (o is ExpressionAst) {
      return o.expression.toSource() == expression.toSource();
    }
    return false;
  }

  @override
  int get hashCode => expression.hashCode;

  @override
  String toString() => '$ExpressionAst {$expression}';
}
