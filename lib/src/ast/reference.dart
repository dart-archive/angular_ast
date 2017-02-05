// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token/tokens.dart';
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
  factory ReferenceAst.parsed(SourceFile sourceFile, NgToken beginToken,
      NgSpecialAttributeToken nameToken,
      [NgAttributeValueToken valueToken,
      NgToken equalSignToken]) = _ParsedReferenceAst;

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

class _ParsedReferenceAst extends TemplateAst
    with ReferenceAst, OffsetInfo, SpecialOffsetInfo {
  final NgSpecialAttributeToken nameToken;
  final NgAttributeValueToken valueToken;
  final NgToken equalSignToken;

  _ParsedReferenceAst(SourceFile sourceFile, NgToken beginToken, this.nameToken,
      [this.valueToken, this.equalSignToken])
      : super.parsed(
          beginToken,
          valueToken != null
              ? valueToken.rightQuote
              : nameToken.identifierToken,
          sourceFile,
        );

  @override
  int get nameOffset => nameToken.identifierToken.offset;

  @override
  int get valueOffset => valueToken?.innerValue?.offset;

  @override
  int get quotedValueOffset => valueToken?.leftQuote?.offset;

  @override
  int get equalSignOffset => equalSignToken.offset;

  @override
  int get specialPrefixOffset => nameToken.prefixToken.offset;

  @override
  int get specialSuffixOffset => null;

  @override
  String get identifier => valueToken?.innerValue?.lexeme;

  @override
  String get variable => nameToken.identifierToken.lexeme;
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
