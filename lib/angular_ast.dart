// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/exception_handler/exception_handler.dart';
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
        ParsedAttributeAst,
        ParsedBananaAst,
        ParsedEventAst,
        ParsedElementAst,
        ParsedPropertyAst,
        ParsedReferenceAst,
        ParsedStarAst,
        PropertyAst,
        ReferenceAst,
        StandaloneTemplateAst,
        StarAst,
        SyntheticTemplateAst,
        TemplateAst,
        TextAst,
        WhitespaceAst;
export 'package:angular_ast/src/lexer.dart' show NgLexer;
export 'package:angular_ast/src/parser.dart' show NgParser;
export 'package:angular_ast/src/token/tokens.dart'
    show NgToken, NgTokenType, NgAttributeValueToken;
export 'package:angular_ast/src/visitor.dart'
    show
        HumanizingTemplateAstVisitor,
        IdentityTemplateAstVisitor,
        TemplateAstVisitor,
        DesugarVisitor;
export 'package:angular_ast/src/exception_handler/exception_handler.dart'
    show RecoveringExceptionHandler, ExceptionHandler, ThrowingExceptionHandler;
export 'package:angular_ast/src/recovery_protocol/recovery_protocol.dart';

/// Returns [template] parsed as an abstract syntax tree.
///
/// Optional bool flag [desugar] desugars syntactic sugaring of * template
/// notations and banana syntax used in two-way binding.
/// Optional bool flag [toolFriendlyAst] provides a reference to the original
/// non-desugared nodes after desugaring occurs.
/// Optional exceptionHandler. Pass in either [RecoveringExceptionHandler] or
/// [ThrowingExceptionHandler] (default).
List<TemplateAst> parse(
  String template, {
  @required String sourceUrl,
  bool toolFriendlyAst: false, // Only needed if desugar = true
  bool desugar: true,
  ExceptionHandler exceptionHandler: const ThrowingExceptionHandler(),
}) {
  final parser = toolFriendlyAst
      ? const NgParser(toolFriendlyAstOrigin: true)
      : const NgParser();
  if (desugar) {
    return parser.parse(
      template,
      sourceUrl: sourceUrl,
      exceptionHandler: exceptionHandler,
    );
  } else {
    return parser.parsePreserve(
      template,
      sourceUrl: sourceUrl,
      exceptionHandler: exceptionHandler,
    );
  }
}
