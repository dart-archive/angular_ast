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
        CloseElementAst,
        CommentAst,
        ElementAst,
        EventAst,
        ExpressionAst,
        InterpolationAst,
        ParsedAttributeAst,
        ParsedBananaAst,
        ParsedCloseElementAst,
        ParsedDecoratorAst,
        ParsedEventAst,
        ParsedInterpolationAst,
        ParsedElementAst,
        ParsedPropertyAst,
        ParsedReferenceAst,
        ParsedStarAst,
        PropertyAst,
        ReferenceAst,
        StandaloneTemplateAst,
        StarAst,
        SyntheticTemplateAst,
        TagOffsetInfo,
        TemplateAst,
        TextAst;
export 'package:angular_ast/src/exception_handler/exception_handler.dart'
    show ExceptionHandler, RecoveringExceptionHandler, ThrowingExceptionHandler;
export 'package:angular_ast/src/lexer.dart' show NgLexer;
export 'package:angular_ast/src/parser.dart' show NgParser;
export 'package:angular_ast/src/token/tokens.dart'
    show NgToken, NgTokenType, NgAttributeValueToken;
export 'package:angular_ast/src/visitor.dart'
    show
        ExpressionParserVisitor,
        HumanizingTemplateAstVisitor,
        IdentityTemplateAstVisitor,
        TemplateAstVisitor,
        DesugarVisitor;
export 'package:angular_ast/src/exception_handler/exception_handler.dart';
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
  bool parseExpressions: true,
  ExceptionHandler exceptionHandler: const ThrowingExceptionHandler(),
}) {
  var parser = toolFriendlyAst
      ? const NgParser(toolFriendlyAstOrigin: true)
      : const NgParser();

  return parser.parse(
    template,
    sourceUrl: sourceUrl,
    exceptionHandler: exceptionHandler,
    desugar: desugar,
    parseExpressions: parseExpressions,
  );
}
