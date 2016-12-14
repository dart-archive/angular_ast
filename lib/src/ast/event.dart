// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token.dart';
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
    NgToken nameToken,
    ExpressionAst expression,
    NgToken endToken,
  ) = _ParsedEventAst;

  @override
  bool operator ==(Object o) =>
      o is EventAst &&
      name == o.name &&
      expression == o.expression &&
      postfix == o.postfix;

  @override
  int get hashCode => hash3(name, expression, postfix);

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

class _ParsedEventAst extends TemplateAst with EventAst {
  final NgToken _nameToken;

  _ParsedEventAst(
    SourceFile sourceFile,
    NgToken beginToken,
    this._nameToken,
    this.expression,
    NgToken endToken,
  )
      : super.parsed(
          beginToken,
          endToken,
          sourceFile,
        );

  String get _nameWithoutParentheses {
    return _nameToken.lexeme.substring(1, _nameToken.lexeme.length - 1);
  }

  @override
  final ExpressionAst expression;

  @override
  String get name => _nameWithoutParentheses.split('.').first;

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
