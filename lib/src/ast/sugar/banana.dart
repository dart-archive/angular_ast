// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:source_span/source_span.dart';
import 'package:quiver/core.dart';

/// Represents the `[(property)]="value"` syntax.
///
/// This AST may only exist in the parses that do not de-sugar directives (i.e.
/// useful for tooling, but not useful for compilers).
///
/// Clients should not extend, implement, or mix-in this class.
abstract class BananaAst implements TemplateAst {
  /// Create a new synthetic [BananaAst] with a string [field].
  factory BananaAst(
    String name, [
    String field,
  ]) = _SyntheticBananaAst;

  /// Create a new synthetic [BananaAst] that originated from node [origin].
  factory BananaAst.from(
    TemplateAst origin,
    String name, [
    String field,
  ]) = _SyntheticBananaAst.from;

  /// Create a new [BananaAst] parsed from tokens from [sourceFile].
  factory BananaAst.parsed(
      SourceFile sourceFile,
      NgToken beginToken,
      NgSpecialAttributeToken nameToken,
      NgAttributeValueToken valueToken,
      NgToken equalSignToken) = _ParsedBananaAst;

  @override
  /*=R*/ accept/*<R, C>*/(TemplateAstVisitor/*<R, C>*/ visitor, [C context]) {
    return visitor.visitBanana(this, context);
  }

  @override
  bool operator ==(Object o) {
    if (o is BananaAst) {
      return name == o.name && value == o.value;
    }
    return false;
  }

  @override
  int get hashCode => hash2(name, value);

  /// Name of the property.
  String get name;

  /// Value bound to.
  String get value;

  @override
  String toString() {
    return '$BananaAst {$name="$value"}';
  }
}

class _ParsedBananaAst extends TemplateAst
    with BananaAst, OffsetInfo, SpecialOffsetInfo {
  final NgSpecialAttributeToken nameToken;
  final NgAttributeValueToken valueToken;
  final NgToken equalSignToken;

  _ParsedBananaAst(SourceFile sourceFile, NgToken beginToken, this.nameToken,
      this.valueToken, this.equalSignToken)
      : super.parsed(
            beginToken,
            (valueToken == null
                ? valueToken.rightQuote
                : nameToken.suffixToken),
            sourceFile);

  @override
  String get name => nameToken.identifierToken.lexeme;

  @override
  int get nameOffset => nameToken.identifierToken.offset;

  @override
  int get equalSignOffset => equalSignToken?.offset;

  @override
  String get value => valueToken?.innerValue?.lexeme;

  @override
  int get valueOffset => valueToken?.innerValue?.offset;

  @override
  int get quotedValueOffset => valueToken?.leftQuote?.offset;

  @override
  int get specialPrefixOffset => nameToken.prefixToken.offset;

  @override
  int get specialSuffixOffset => nameToken.suffixToken?.offset;
}

class _SyntheticBananaAst extends SyntheticTemplateAst with BananaAst {
  @override
  final String name;

  @override
  final String value;

  _SyntheticBananaAst(this.name, [this.value]);

  _SyntheticBananaAst.from(
    TemplateAst origin,
    this.name, [
    this.value,
  ])
      : super.from(origin);
}
