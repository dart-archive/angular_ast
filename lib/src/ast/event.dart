// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:source_span/source_span.dart';
import 'package:quiver/core.dart';

/// Represents an event listener on an element.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class EventAst implements TemplateAst {
  /// Create a new synthetic [EventAst] listening to [name].
  factory EventAst(
    String name,
    ExpressionAst expression, [
    String postfix,
  ]) = _SyntheticEventAst;

  /// Create a new synthetic [EventAst] that originated from [origin].
  factory EventAst.from(
    TemplateAst origin,
    String name,
    ExpressionAst expression, [
    String postfix,
  ]) = _SyntheticEventAst.from;

  /// Create a new [EventAst] parsed from tokens in [sourceFile].
  factory EventAst.parsed(
      SourceFile sourceFile,
      NgToken beginToken,
      NgSpecialAttributeToken nameToken,
      NgAttributeValueToken valueToken,
      NgToken equalSignToken) = _ParsedEventAst;

  @override
  bool operator ==(Object o) =>
      o is EventAst &&
      name == o.name &&
      expression == o.expression &&
      postfix == o.postfix;

  @override
  int get hashCode => hash3(name, expression, postfix);

  @override
  /*=R*/ accept/*<R, C>*/(TemplateAstVisitor/*<R, C>*/ visitor, [C context]) {
    return visitor.visitEvent(this, context);
  }

  /// Bound expression.
  ExpressionAst get expression;

  /// Name of the event being listened to.
  String get name;

  /// An optional postfix used to filter events that support it.
  ///
  /// For example `(keydown.space)`.
  String get postfix;

  @override
  String toString() {
    if (postfix != null) {
      return '$EventAst {$name.$postfix="$expression"}';
    }
    return '$EventAst {$name="$expression"}';
  }
}

class _ParsedEventAst extends TemplateAst
    with EventAst, OffsetInfo, SpecialOffsetInfo {
  final NgSpecialAttributeToken nameToken;
  final NgAttributeValueToken valueToken;
  final NgToken equalSignToken;

  _ParsedEventAst(SourceFile sourceFile, NgToken beginToken, this.nameToken,
      this.valueToken, this.equalSignToken)
      : this.expression = valueToken != null
            ? new ExpressionAst.parse(valueToken.innerValue.lexeme,
                sourceUrl: sourceFile.url.toString())
            : null,
        super.parsed(
          beginToken,
          valueToken == null ? nameToken.suffixToken : valueToken.rightQuote,
          sourceFile,
        );

  String get _nameWithoutParentheses {
    return nameToken.identifierToken.lexeme;
  }

  @override
  final ExpressionAst expression;

  @override
  String get name => _nameWithoutParentheses.split('.').first;

  @override
  int get nameOffset => nameToken.identifierToken.offset;

  @override
  int get specialPrefixOffset => nameToken.prefixToken.offset;

  @override
  int get specialSuffixOffset => nameToken.suffixToken.offset;

  String get value => valueToken?.innerValue?.lexeme;

  @override
  int get valueOffset => valueToken?.innerValue?.offset;

  @override
  int get quotedValueOffset => valueToken?.leftQuote?.offset;

  @override
  int get equalSignOffset => equalSignToken.offset;

  @override
  String get postfix {
    final split = _nameWithoutParentheses.split('.');
    return split.length > 1 ? split.last : null;
  }
}

class _SyntheticEventAst extends SyntheticTemplateAst with EventAst {
  @override
  final String name;

  @override
  final ExpressionAst expression;

  @override
  final String postfix;

  _SyntheticEventAst(this.name, this.expression, [this.postfix]);

  _SyntheticEventAst.from(
    TemplateAst origin,
    this.name,
    this.expression, [
    this.postfix,
  ])
      : super.from(origin);
}
