// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:source_span/source_span.dart';

/// Represents a generic-use whitespace ast to preserve offsets
/// where needed. This cannot exist as a synthetic and is always real.
///
/// Clients should not extend, implement, or mix-in this class.
class WhitespaceAst extends TemplateAst {
  final NgToken whitespaceToken;

  WhitespaceAst(
    SourceFile sourceFile,
    NgToken whitespaceToken,
  )
      : whitespaceToken = whitespaceToken,
        super.parsed(whitespaceToken, whitespaceToken, sourceFile);

  int get offset => whitespaceToken.offset;
  int get length => whitespaceToken.length;
  String get value => whitespaceToken.lexeme;
  int get end => whitespaceToken.end;

  @override
  /*=R*/ accept/*<R, C>*/(TemplateAstVisitor/*<R, C>*/ visitor, [C context]) {
    return visitor.visitWhitespace(this, context);
  }

  @override
  bool operator ==(Object o) {
    if (o is WhitespaceAst) {
      return whitespaceToken == o.whitespaceToken;
    }
    return false;
  }

  @override
  int get hashCode => whitespaceToken.hashCode;

  @override
  String toString() {
    return '$WhitespaceAst {$value}';
  }
}
