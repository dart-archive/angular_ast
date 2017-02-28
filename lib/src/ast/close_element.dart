// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:source_span/source_span.dart';

/// Represents the closing DOM element that was parsed.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class CloseElementAst implements TemplateAst {
  /// Creates a synthetic close element AST.
  factory CloseElementAst(
    String name, {
    List<WhitespaceAst> whitespaces,
  }) = _SyntheticCloseElementAst;

  /// Creates a synthetic close element AST from an existing AST node.
  factory CloseElementAst.from(
    TemplateAst origin,
    String name, {
    List<WhitespaceAst> whitespaces,
  }) = _SyntheticCloseElementAst.from;

  /// Creates a new close element AST from a parsed source
  factory CloseElementAst.parsed(
    SourceFile sourceFile,
    NgToken closeTagStart,
    NgToken nameToken,
    NgToken closeTagEnd, {
    ElementAst openComplement,
    List<WhitespaceAst> whitespaces,
  }) = ParsedCloseElementAst;

  @override
  bool operator ==(Object o) {
    if (o is CloseElementAst) {
      return name == o.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  /*=R*/ accept/*<R, C>*/(TemplateAstVisitor/*<R, C>*/ visitor, [C context]) {
    return visitor.visitCloseElement(this, context);
  }

  /// Whether this is a `</template>` tag and should be directly rendered.
  bool get isEmbeddedTemplate => name == 'template';

  /// Name (tag) of the close element.
  String get name;

  /// Whitespaces at the end
  List<WhitespaceAst> get whitespaces;

  @override
  String toString() {
    final buffer = new StringBuffer('$CloseElementAst <$name> { ');
    if (whitespaces.isNotEmpty) {
      buffer
        ..write('whitespaces=')
        ..writeAll(whitespaces, ', ')
        ..write(' ');
    }
    return (buffer..write('}')).toString();
  }
}

/// Represents a real, non-synthetic DOM close element that was parsed,
/// that could be upgraded.abstract
///
/// Clients should not extned, implement, or mix-in this class.
class ParsedCloseElementAst extends TemplateAst with CloseElementAst {
  /// [NgToken] that represents the identifier tag in `</tag>`.
  final NgToken identifierToken;

  ParsedCloseElementAst(
    SourceFile sourceFile,
    NgToken closeElementStart,
    this.identifierToken,
    NgToken closeElementEnd, {
    ElementAst openComplement,
    this.whitespaces: const [],
  })
      : super.parsed(closeElementStart, closeElementEnd, sourceFile);

  @override
  String get name => identifierToken.lexeme;

  /// Whitespaces
  @override
  final List<WhitespaceAst> whitespaces;
}

class _SyntheticCloseElementAst extends SyntheticTemplateAst
    with CloseElementAst {
  _SyntheticCloseElementAst(
    this.name, {
    this.whitespaces: const [],
  });

  _SyntheticCloseElementAst.from(
    TemplateAst origin,
    this.name, {
    this.whitespaces: const [],
  })
      : super.from(origin);

  @override
  final String name;

  @override
  final List<WhitespaceAst> whitespaces;
}
