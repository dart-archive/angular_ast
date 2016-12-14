// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO: This is a placeholder.
//
// Probably want to either:
// - Port the original one
// - Write a new one
// - Use the Dart analyzer and special case pipes
// - Use the Dart analyzer and transform pipes
class ExpressionAst {
  final String expression;

  const ExpressionAst(this.expression);

  @override
  bool operator ==(Object o) =>
      o is ExpressionAst && o.expression == expression;

  @override
  int get hashCode => expression.hashCode;

  @override
  String toString() => '$ExpressionAst {$expression}';
}
