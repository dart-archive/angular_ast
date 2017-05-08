// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/ast/ast.dart';

/// An implementation of [Expression] for the pipe operator in AngularDart.
class PipeExpression extends ExpressionImpl implements BinaryExpression {
  @override
  final Token beginToken;

  @override
  final int end;

  @override
  final Token endToken;

  /// Name of the pipe.
  final Identifier name;

  /// Parameters.
  final List<Expression> parameters;

  /// Value expression to evaluate the pipe against.
  final Expression value;

  /// Token.
  final Token _operator;

  PipeExpression(
    this.beginToken,
    this.endToken,
    this.end,
    this.name,
    this._operator,
    this.value,
    this.parameters,
  );

  @override
  String toSource() {
    var parameterCall = parameters.map((p) => p.toSource()).join(':');
    if (parameterCall.isNotEmpty) {
      parameterCall = ':$parameterCall';
    }
    return '${value.toSource()} | ${name.name}$parameterCall';
  }

  @override
  E accept<E>(AstVisitor<E> visitor) {
    return visitor.visitBinaryExpression(this);
  }

  @override
  Iterable<SyntacticEntity> get childEntities {
    return [
      name,
      value,
    ]..addAll(parameters);
  }

  // What should this actually be?
  @override
  int get precedence => 1;

  @override
  void visitChildren(AstVisitor visitor) {
    leftOperand?.accept(visitor);
    rightOperand?.accept(visitor);
  }

  @override
  Expression get leftOperand => value;

  @override
  set leftOperand(_) {
    throw new UnsupportedError('Cannot be modified');
  }

  @override
  MethodElement propagatedElement;

  @override
  Expression get rightOperand => name;

  @override
  set rightOperand(_) {
    throw new UnsupportedError('Cannot be modified');
  }

  @override
  MethodElement staticElement;

  @override
  MethodElement get bestElement => null;

  @override
  set operator(Token token) {
    throw new UnsupportedError('Cannot be modified');
  }

  @override
  Token get operator => _operator;
}
