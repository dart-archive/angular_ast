// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:source_span/source_span.dart';
import 'package:quiver/core.dart';

/// Represents the sugared form of `*directive="value"`.
///
/// This AST may only exist in the parses that do not de-sugar directives (i.e.
/// useful for tooling, but not useful for compilers).
///
/// Clients should not extend, implement, or mix-in this class.
abstract class StarAst implements TemplateAst {
  /// Create a new synthetic [StarAst] assigned to [name].
  factory StarAst(
    String name, [
    ExpressionAst expression,
  ]) = _SyntheticStarAst;

  /// Create a new synthetic property AST that originated from another AST.
  factory StarAst.from(
    TemplateAst origin,
    String name, [
    ExpressionAst expression,
  ]) = _SyntheticStarAst.from;

  /// Create a new property assignment parsed from tokens in [sourceFile].
  factory StarAst.parsed(
    SourceFile sourceFile,
    NgToken beginToken,
    NgToken prefixToken,
    NgToken elementDecoratorToken, [
    NgAttributeValueToken valueToken,
    NgToken equalSignToken,
  ]) = ParsedStarAst;

  @override
  /*=R*/ accept/*<R, C>*/(TemplateAstVisitor/*<R, C>*/ visitor, [C context]) {
    return visitor.visitStar(this, context);
  }

  @override
  bool operator ==(Object o) {
    if (o is PropertyAst) {
      return expression == o.expression && name == o.name;
    }
    return false;
  }

  @override
  int get hashCode => hash2(expression, name);

  /// Bound expression; optional for backwards compatibility.
  ExpressionAst get expression;

  /// Name of the directive being created.
  String get name;

  /// Name of expression string
  String get value;

  @override
  String toString() {
    if (expression != null) {
      return '$StarAst {$name="$expression"}';
    }
    return '$StarAst {$name}';
  }
}

/// Represents a real, non-synthetic sugared form of `*directive="value"`.
///
/// This AST may only exist in the parses that do not de-sugar directives (i.e.
/// useful for tooling, but not useful for compilers). Preserves offsets.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedStarAst extends TemplateAst
    with StarAst, TagOffsetInfo, SpecialOffsetInfo {
  final NgToken prefixToken;
  final NgToken nameToken;

  /// [NgAttributeValueToken] that represents `"value"`; may be `null` to have
  /// no value.
  final NgAttributeValueToken valueToken;

  /// [NgToken] that represents the equal sign token; may be `null` to have no
  /// value.
  final NgToken equalSignToken;

  ParsedStarAst(
    SourceFile sourceFile,
    NgToken beginToken,
    this.prefixToken,
    this.nameToken, [
    this.valueToken,
    this.equalSignToken,
  ])
      : this.expression = valueToken != null
            ? new ExpressionAst.parse(valueToken.innerValue.lexeme,
                sourceUrl: sourceFile.url.toString())
            : null,
        super.parsed(beginToken,
            valueToken != null ? valueToken.rightQuote : nameToken, sourceFile);

  /// ExpressionAst of `"value"`; may be null to have no value.
  @override
  final ExpressionAst expression;

  /// Name `directive` in `*directive`.
  @override
  String get name => nameToken.lexeme;

  /// Offset of `directive` in `*directive`.
  @override
  int get nameOffset => nameToken.offset;

  /// Offset of equal sign; may be `null` to have no value.
  @override
  int get equalSignOffset => equalSignToken.offset;

  /// Value bound to `*directive`; may be `null` to have no value.
  @override
  String get value => valueToken?.innerValue?.lexeme;

  /// Offset of value; may be `null to have no value.
  @override
  int get valueOffset => valueToken?.innerValue?.offset;

  /// Offset of value starting at left quote; may be `null` to have no value.
  @override
  int get quotedValueOffset => valueToken?.leftQuote?.offset;

  /// Offset of template prefix `*`.
  @override
  int get prefixOffset => prefixToken.offset;

  /// Always returns `null` since `*directive` has no suffix.
  @override
  int get suffixOffset => null;
}

class _SyntheticStarAst extends SyntheticTemplateAst with StarAst {
  _SyntheticStarAst(
    this.name, [
    this.expression,
  ]);

  _SyntheticStarAst.from(
    TemplateAst origin,
    this.name, [
    this.expression,
  ])
      : super.from(origin);

  @override
  final ExpressionAst expression;

  @override
  final String name;

  @override
  String get value => expression.expression.toString();
}
