// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:source_span/source_span.dart';
import 'package:quiver/core.dart';

/// Represents a bound property assignment for an element.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class PropertyAst implements TemplateAst {
  /// Create a new synthetic [PropertyAst] assigned to [name].
  factory PropertyAst(
    String name, [
    ExpressionAst expression,
    String postfix,
    String unit,
  ]) = _SyntheticPropertyAst;

  /// Create a new synthetic property AST that originated from another AST.
  factory PropertyAst.from(
    TemplateAst origin,
    String name, [
    ExpressionAst expression,
    String postfix,
    String unit,
  ]) = _SyntheticPropertyAst.from;

  /// Create a new property assignment parsed from tokens in [sourceFile].
  factory PropertyAst.parsed(
    SourceFile sourceFile,
    NgToken beginToken,
    NgToken nameToken,
    NgToken endToken, [
    ExpressionAst expressionAst,
  ]) = _ParsedPropertyAst;

  @override
  bool operator ==(Object o) {
    if (o is PropertyAst) {
      return expression == o.expression &&
          name == o.name &&
          postfix == o.postfix &&
          unit == o.unit;
    }
    return false;
  }

  @override
  int get hashCode => hash4(expression, name, postfix, unit);

  @override
  /*=R*/ accept/*<R, C>*/(TemplateAstVisitor/*<R, C>*/ visitor, [C context]) {
    return visitor.visitProperty(this, context);
  }

  /// Bound expression; optional for backwards compatibility.
  ExpressionAst get expression;

  /// Name of the property being set.
  String get name;

  /// An optional indicator for some properties as a shorthand syntax.
  ///
  /// For example:
  /// ```html
  /// <div [class.foo]="isFoo"></div>
  /// ```
  ///
  /// Means _has class "foo" while "isFoo" evaluates to true_.
  String get postfix;

  /// An optional indicator the unit coercion before assigning.
  ///
  /// For example:
  /// ```html
  /// <div [style.height.px]="height"></div>
  /// ```
  ///
  /// Means _assign style.height to height plus the "px" suffix_.
  String get unit;

  @override
  String toString() {
    if (unit != null) {
      return '$PropertyAst {$name.$postfix.$unit="$expression"}';
    }
    if (postfix != null) {
      return '$PropertyAst {$name.$postfix="$expression"}';
    }
    if (expression != null) {
      return '$PropertyAst {$name="$expression"}';
    }
    return '$PropertyAst {$name}';
  }
}

class _ParsedPropertyAst extends TemplateAst with PropertyAst {
  final NgToken _nameToken;

  _ParsedPropertyAst(
    SourceFile sourceFile,
    NgToken beginToken,
    this._nameToken,
    NgToken endToken, [
    this.expression,
  ])
      : super.parsed(beginToken, endToken, sourceFile);

  @override
  final ExpressionAst expression;

  String get _nameWithoutBrackets {
    return _nameToken.lexeme.substring(1, _nameToken.lexeme.length - 1);
  }

  @override
  String get name => _nameWithoutBrackets.split('.').first;

  @override
  String get postfix {
    final split = _nameWithoutBrackets.split('.');
    return split.length > 1 ? split[1] : null;
  }

  @override
  String get unit {
    final split = _nameWithoutBrackets.split('.');
    return split.length > 2 ? split[2] : null;
  }
}

class _SyntheticPropertyAst extends SyntheticTemplateAst with PropertyAst {
  _SyntheticPropertyAst(
    this.name, [
    this.expression,
    this.postfix,
    this.unit,
  ]);

  _SyntheticPropertyAst.from(
    TemplateAst origin,
    this.name, [
    this.expression,
    this.postfix,
    this.unit,
  ])
      : super.from(origin);

  @override
  final ExpressionAst expression;

  @override
  final String name;

  @override
  final String postfix;

  @override
  final String unit;
}
