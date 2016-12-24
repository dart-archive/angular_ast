// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:source_span/source_span.dart';
import 'package:quiver/core.dart';

/// Represents a reference to an element or exported directive instance.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class ReferenceAst implements TemplateAst {
  /// Create a new synthetic reference of [variable].
  factory ReferenceAst(
    String variable, [
    String identifier,
  ]) = _SyntheticReferenceAst;

  /// Create a new synthetic reference of [variable] from AST node [origin].
  factory ReferenceAst.from(
    TemplateAst origin,
    String variable, [
    String identifier,
  ]) = _SyntheticReferenceAst.from;

  /// Create new reference from tokens in [sourceFile].
  factory ReferenceAst.parsed(
    SourceFile sourceFile,
    NgToken nameToken, [
    NgToken identifierToken,
    NgToken endValueToken,
  ]) = _ParsedReferenceAst;

  @override
  bool operator ==(Object o) {
    if (o is ReferenceAst) {
      return identifier == o.identifier && variable == o.variable;
    }
    return false;
  }

  @override
  int get hashCode => hash2(identifier, variable);

  @override
  /*=R*/ accept/*<R, C>*/(TemplateAstVisitor/*<R, C>*/ visitor, [C context]) {
    return visitor.visitReference(this, context);
  }

  /// What `exportAs` identifier to assign to [variable].
  ///
  /// If not set (i.e. `null`), the reference is the raw DOM element.
  String get identifier;

  /// Local variable name being assigned.
  String get variable;

  @override
  String toString() {
    if (identifier != null) {
      return '$ReferenceAst {#$variable="$identifier"}';
    }
    return '$ReferenceAst {#$variable}';
  }
}

class _ParsedReferenceAst extends TemplateAst with ReferenceAst {
  final NgToken _identifierToken;
  final NgToken _variableToken;

  _ParsedReferenceAst(
    SourceFile sourceFile,
    NgToken nameToken, [
    this._identifierToken,
    NgToken endValueToken,
  ])
      : _variableToken = nameToken,
        super.parsed(
          nameToken,
          endValueToken ?? nameToken,
          sourceFile,
        );

  @override
  String get identifier => _identifierToken?.lexeme;

  @override
  String get variable => _variableToken.lexeme.substring(1);
}

class _SyntheticReferenceAst extends SyntheticTemplateAst with ReferenceAst {
  _SyntheticReferenceAst(this.variable, [this.identifier]);

  _SyntheticReferenceAst.from(
    TemplateAst origin,
    this.variable, [
    this.identifier,
  ])
      : super.from(origin);

  @override
  final String identifier;

  @override
  final String variable;
}
