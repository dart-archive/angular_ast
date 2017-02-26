// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:source_span/source_span.dart';
import 'package:quiver/core.dart';

// TODO: Interpolation within the value

/// Represents a static attribute assignment (i.e. not bound to an expression).
///
/// Clients should not extend, implement, or mix-in this class.
abstract class AttributeAst implements TemplateAst {
  /// Create a new synthetic [AttributeAst] with a string [value].
  factory AttributeAst(
    String name, [
    String value,
  ]) = _SyntheticAttributeAst;

  /// Create a new synthetic [AttributeAst] that originated from node [origin].
  factory AttributeAst.from(
    TemplateAst origin,
    String name, [
    String value,
  ]) = _SyntheticAttributeAst.from;

  /// Create a new [AttributeAst] parsed from tokens from [sourceFile].
  factory AttributeAst.parsed(
    SourceFile sourceFile,
    NgToken beginToken,
    NgToken nameToken, [
    NgAttributeValueToken valueToken,
    NgToken equalSignToken,
  ]) = ParsedAttributeAst;

  @override
  /*=R*/ accept/*<R, C>*/(TemplateAstVisitor/*<R, C>*/ visitor, [C context]) {
    return visitor.visitAttribute(this, context);
  }

  @override
  bool operator ==(Object o) {
    if (o is AttributeAst) {
      return name == o.name && value == o.value;
    }
    return false;
  }

  @override
  int get hashCode => hash2(name, value);

  /// Static attribute name.
  String get name;

  /// Static attribute value; may be `null` to have no value.
  String get value;

  /// Static attribute value with quotes attached;
  /// may be `null` to have no value.
  String get quotedValue;

  @override
  String toString() {
    if (quotedValue != null) {
      return '$AttributeAst {$name=$quotedValue}';
    }
    return '$AttributeAst {$name}';
  }
}

/// Represents a real(non-synthetic) parsed AttributeAst. Preserves offsets.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedAttributeAst extends TemplateAst with AttributeAst, TagOffsetInfo {
  /// [NgToken] that represents the attribute name.
  final NgToken nameToken;

  /// [NgAttributeValueToken] that represents the attribute value. May be `null`
  /// to have no value.
  final NgAttributeValueToken valueToken;

  /// [NgToken] that represents the equal sign token. May be `null` to have no
  /// value.
  final NgToken equalSignToken;

  ParsedAttributeAst(
    SourceFile sourceFile,
    NgToken beginToken,
    this.nameToken, [
    this.valueToken,
    this.equalSignToken,
  ])
      : super.parsed(
          beginToken,
          (valueToken == null ? nameToken : valueToken.rightQuote),
          sourceFile,
        );

  /// Static attribute name.
  @override
  String get name => nameToken.lexeme;

  /// Static attribute name offset.
  @override
  int get nameOffset => nameToken.offset;

  /// Static offset of equal sign; may be `null` to have no value.
  @override
  int get equalSignOffset => equalSignToken?.offset;

  /// Static attribute value; may be `null` to have no value.
  @override
  String get value => valueToken?.innerValue?.lexeme;

  /// Static attribute value including quotes; may be `null` to have no value.
  @override
  String get quotedValue => valueToken?.lexeme;

  /// Static attribute value offset; may be `null` to have no value.
  @override
  int get valueOffset => valueToken?.innerValue?.offset;

  /// Static attribute value including quotes offset; may be `null` to have no
  /// value.
  @override
  int get quotedValueOffset => valueToken?.leftQuote?.offset;
}

class _SyntheticAttributeAst extends SyntheticTemplateAst with AttributeAst {
  @override
  final String name;

  @override
  final String value;

  @override
  String get quotedValue => value == null ? null : '"$value"';

  _SyntheticAttributeAst(this.name, [this.value]);

  _SyntheticAttributeAst.from(
    TemplateAst origin,
    this.name, [
    this.value,
  ])
      : super.from(origin);
}
