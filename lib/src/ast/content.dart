// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:source_span/source_span.dart';

/// Represents an `<ng-content>` element AST.
///
/// Embedded content is _like_ an `ElementAst`, but only contains children.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class EmbeddedContentAst implements StandaloneTemplateAst {
  /// Create a synthetic embedded content AST.
  factory EmbeddedContentAst([String selector]) = _SyntheticEmbeddedContentAst;

  /// Create a synthetic [EmbeddedContentAst] that originated from [origin].
  factory EmbeddedContentAst.from(
    TemplateAst origin,
    String selector,
  ) = _SyntheticEmbeddedContentAst.from;

  /// Create a new [EmbeddedContentAst] parsed from tokens in [sourceFile].
  factory EmbeddedContentAst.parsed(
    SourceFile sourceFile,
    NgToken startElementToken,
    NgToken endElementToken, [
    NgToken selectorValueToken,
  ]) = _ParsedEmbeddedContentAst;

  @override
  /*=R*/ accept/*<R, C>*/(TemplateAstVisitor/*<R, C>*/ visitor, [C context]) {
    return visitor.visitEmbeddedContent(this, context);
  }

  /// A CSS selector denoting what elements should be embedded.
  ///
  /// May be `*` to signify _all_ elements.
  String get selector;

  @override
  bool operator ==(Object o) {
    return o is EmbeddedContentAst && o.selector == selector;
  }

  @override
  int get hashCode => selector.hashCode;

  @override
  String toString() => '$EmbeddedContentAst {$selector}';
}

class _ParsedEmbeddedContentAst extends TemplateAst with EmbeddedContentAst {
  final NgToken _selectorValueToken;

  _ParsedEmbeddedContentAst(
    SourceFile sourceFile,
    NgToken startElementToken,
    NgToken endElementToken, [
    this._selectorValueToken,
  ])
      : super.parsed(
          startElementToken,
          endElementToken,
          sourceFile,
        );

  @override
  String get selector => _selectorValueToken?.lexeme ?? '*';
}

class _SyntheticEmbeddedContentAst extends SyntheticTemplateAst
    with EmbeddedContentAst {
  @override
  final String selector;

  _SyntheticEmbeddedContentAst([this.selector = '*']);

  _SyntheticEmbeddedContentAst.from(
    TemplateAst origin, [
    this.selector = ' *',
  ])
      : super.from(origin);
}
