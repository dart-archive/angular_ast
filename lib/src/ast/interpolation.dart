// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:source_span/source_span.dart';

/// Represents a bound text element to an expression.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class InterpolationAst implements StandaloneTemplateAst {
  /// Create a new synthetic [InterpolationAst] with a bound [expression].
  factory InterpolationAst(
    ExpressionAst expression,
  ) = _SyntheticInterpolationAst;

  /// Create a new synthetic [InterpolationAst] that originated from [origin].
  factory InterpolationAst.from(
    TemplateAst origin,
    ExpressionAst expression,
  ) = _SyntheticInterpolationAst.from;

  /// Create a new [InterpolationAst] parsed from tokens in [sourceFile].
  factory InterpolationAst.parsed(
    SourceFile sourceFile,
    NgToken beginToken,
    String value,
    NgToken endToken,
  ) = _ParsedInterpolationAst;

  @override
  /*=R*/ accept/*<R, C>*/(TemplateAstVisitor/*<R, C>*/ visitor, [C context]) {
    return visitor.visitInterpolation(this, context);
  }

  /// Bound expression.
  ExpressionAst get expression;

  /// Bound String value used in expression; used to preserve offsets
  String get value;

  @override
  bool operator ==(Object o) {
    return o is InterpolationAst && o.expression == expression;
  }

  @override
  int get hashCode => expression.hashCode;

  @override
  String toString() => '$InterpolationAst {$expression}';
}

class _ParsedInterpolationAst extends TemplateAst with InterpolationAst {
  @override
  final ExpressionAst expression;

  @override
  final String value;

  _ParsedInterpolationAst(
    SourceFile sourceFile,
    NgToken beginToken,
    this.value,
    NgToken endToken,
  )
      : expression = new ExpressionAst.parse(
          value,
          sourceUrl: sourceFile.url.toString(),
        ),
        super.parsed(beginToken, endToken, sourceFile);
}

class _SyntheticInterpolationAst extends SyntheticTemplateAst
    with InterpolationAst {
  @override
  final ExpressionAst expression;

  _SyntheticInterpolationAst(this.expression);

  _SyntheticInterpolationAst.from(
    TemplateAst origin,
    this.expression,
  )
      : super.from(origin);

  @override
  String get value => expression.expression.toString();
}
