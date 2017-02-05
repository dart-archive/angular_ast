// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:source_span/source_span.dart';
import 'package:quiver/core.dart';

/// Represents a static attribute assignment (i.e. not bound to an expression).
///
/// Clients should not extend, implement, or mix-in this class.
abstract class AttributeAst implements TemplateAst {
  /// Create a new synthetic [AttributeAst] with a string [value].
  factory AttributeAst(String name, [String value]) = _SyntheticAttributeAst;

  /// Create a new synthetic [AttributeAst] that originated from node [origin].
  factory AttributeAst.from(
    TemplateAst origin,
    String name, [
    String value,
  ]) = _SyntheticAttributeAst.from;

  /// Create a new [AttributeAst] parsed from tokens from [sourceFile].
  factory AttributeAst.parsed(
      SourceFile sourceFile, NgToken beginToken, NgToken nameToken,
      [NgAttributeValueToken valueToken,
      NgToken equalSignToken]) = _ParsedAttributeAst;

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
    if (value != null) {
      return '$AttributeAst {$name=$value}';
    }
    return '$AttributeAst {$name}';
  }
}

class _ParsedAttributeAst extends TemplateAst with AttributeAst, OffsetInfo {
  final NgToken nameToken;
  final NgAttributeValueToken valueToken;
  final NgToken equalSignToken;

  _ParsedAttributeAst(SourceFile sourceFile, NgToken beginToken, this.nameToken,
      [this.valueToken, this.equalSignToken])
      : super.parsed(
            beginToken,
            (valueToken == null ? nameToken : valueToken.rightQuote),
            sourceFile);

  @override
  String get name => nameToken.lexeme;

  @override
  int get nameOffset => nameToken.offset;

  @override
  int get equalSignOffset => equalSignToken?.offset;

  @override
  String get value => valueToken?.innerValue?.lexeme;

  @override
  String get quotedValue => valueToken?.lexeme;

  @override
  int get valueOffset => valueToken?.innerValue?.offset;

  @override
  int get quotedValueOffset => valueToken?.leftQuote?.offset;
}

class _SyntheticAttributeAst extends SyntheticTemplateAst with AttributeAst {
  @override
  final String name;

  @override
  final String value;

  @override
  String get quotedValue => '"$value"';

  _SyntheticAttributeAst(this.name, [this.value]);

  _SyntheticAttributeAst.from(
    TemplateAst origin,
    this.name, [
    this.value,
  ])
      : super.from(origin);
}
