// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token.dart';
import 'package:source_span/source_span.dart';
import 'package:quiver/core.dart';

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
    NgToken nameToken, [
    NgToken valueToken,
    NgToken endValueToken,
  ]) = _ParsedAttributeAst;

  @override
  bool operator ==(Object o) =>
      o is AttributeAst && name == o.name && value == o.value;

  @override
  int get hashCode => hash2(name, value);

  /// Static attribute name.
  String get name;

  /// Static attribute value; may be `null` to have no value.
  String get value;

  @override
  String toString() {
    if (value != null) {
      return '$AttributeAst {$name="$value"}';
    }
    return '$AttributeAst {$name}';
  }
}

class _ParsedAttributeAst extends TemplateAst with AttributeAst {
  final NgToken _nameToken;
  final NgToken _valueToken;

  _ParsedAttributeAst(
    SourceFile sourceFile,
    NgToken nameToken, [
    this._valueToken,
    NgToken endValueToken,
  ])
      : _nameToken = nameToken,
        super.parsed(nameToken, endValueToken ?? nameToken, sourceFile);

  @override
  String get name => _nameToken.lexeme;

  @override
  String get value => _valueToken?.lexeme;
}

class _SyntheticAttributeAst extends SyntheticTemplateAst with AttributeAst {
  @override
  final String name;

  @override
  final String value;

  _SyntheticAttributeAst(this.name, [this.value]);

  _SyntheticAttributeAst.from(
    TemplateAst origin,
    this.name, [
    this.value,
  ])
      : super.from(origin);
}
