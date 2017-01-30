// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/parser.dart';
import 'package:meta/meta.dart';
export 'package:angular_ast/src/ast.dart'
    show
        AttributeAst,
        BananaAst,
        CommentAst,
        ElementAst,
        EmbeddedContentAst,
        EmbeddedTemplateAst,
        EventAst,
        ExpressionAst,
        InterpolationAst,
        PropertyAst,
        ReferenceAst,
        StandaloneTemplateAst,
        StarAst,
        SyntheticTemplateAst,
        TemplateAst,
        TextAst;
export 'package:angular_ast/src/lexer.dart' show NgLexer;
export 'package:angular_ast/src/parser.dart' show NgParser;
export 'package:angular_ast/src/token/tokens.dart' show NgToken, NgTokenType;
export 'package:angular_ast/src/visitor.dart'
    show
        HumanizingTemplateAstVisitor,
        IdentityTemplateAstVisitor,
        TemplateAstVisitor;

/// Returns [template] parsed as an abstract syntax tree.
List<TemplateAst> parse(
  String template, {
  @required String sourceUrl,
  bool toolFriendlyAst: false,
}) {
  final parser = toolFriendlyAst
      ? const NgParser(toolFriendlyAstOrigin: true)
      : const NgParser();
  return parser.parse(template, sourceUrl: sourceUrl);
}
