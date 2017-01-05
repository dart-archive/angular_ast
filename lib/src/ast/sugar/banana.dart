// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:source_span/source_span.dart';
import 'package:quiver/core.dart';

/// Represents the `[(property)]="field"` syntax.
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
    NgToken nameToken,
    NgToken fieldToken,
    NgToken endFieldToken,
  ) = _ParsedBananaAst;

  @override
  /*=R*/ accept/*<R, C>*/(TemplateAstVisitor/*<R, C>*/ visitor, [C context]) {
    throw new UnimplementedError();
  }

  @override
  bool operator ==(Object o) {
    if (o is BananaAst) {
      return name == o.name && field == o.field;
    }
    return false;
  }

  @override
  int get hashCode => hash2(name, field);

  /// Name of the property.
  String get name;

  /// Field bound to.
  String get field;

  @override
  String toString() {
    return '$BananaAst {$name="$field"}';
  }
}

class _ParsedBananaAst extends TemplateAst with BananaAst {
  final NgToken _nameToken;
  final NgToken _fieldToken;

  _ParsedBananaAst(
    SourceFile sourceFile,
    NgToken nameToken,
    this._fieldToken,
    NgToken endValueToken,
  )
      : _nameToken = nameToken,
        super.parsed(nameToken, endValueToken, sourceFile);

  @override
  String get name =>
      _nameToken.lexeme.substring(1, _nameToken.lexeme.length - 1);

  @override
  String get field => _fieldToken.lexeme;
}

class _SyntheticBananaAst extends SyntheticTemplateAst with BananaAst {
  @override
  final String name;

  @override
  final String field;

  _SyntheticBananaAst(this.name, [this.field]);

  _SyntheticBananaAst.from(
    TemplateAst origin,
    this.name, [
    this.field,
  ])
      : super.from(origin);
}
