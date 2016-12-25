// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/analyzer.dart' as analyzer;
import 'package:angular_ast/src/expression/parser.dart';
import 'package:meta/meta.dart';

/// Wraps a parsed Dart [Expression] as an Angular [ExpressionAst].
class ExpressionAst {
  /// Dart expression.
  final analyzer.Expression expression;

  /// Create a new expression AST wrapping a Dart expression.
  const ExpressionAst(this.expression);

  /// Create a new expression AST by parsing [expression].
  factory ExpressionAst.parse(
    String expression, {
    bool deSugarPipes: true,
    @required String sourceUrl,
  }) {
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
