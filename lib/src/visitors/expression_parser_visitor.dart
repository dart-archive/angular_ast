// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/error/error.dart';
import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/exception_handler/exception_handler.dart';
import 'package:angular_ast/src/visitor.dart';

class ExpressionParserVisitor<C> implements TemplateAstVisitor<TemplateAst, C> {
  final ExceptionHandler exceptionHandler;
  final String sourceUrl;

  ExpressionParserVisitor(this.sourceUrl, {ExceptionHandler exceptionHandler})
      : exceptionHandler = exceptionHandler ?? new ThrowingExceptionHandler();

  @override
  TemplateAst visitAttribute(AttributeAst astNode, [_]) => astNode;

  @override
  TemplateAst visitBanana(BananaAst astNode, [_]) => astNode;

  @override
  TemplateAst visitCloseElement(CloseElementAst astNode, [_]) => astNode;

  @override
  TemplateAst visitComment(CommentAst astNode, [_]) => astNode;

  @override
  TemplateAst visitEmbeddedContent(EmbeddedContentAst astNode, [_]) => astNode;

  @override
  TemplateAst visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [_]) {
    astNode.properties.forEach((property) {
      property.accept(this);
    });
    astNode.childNodes.forEach((child) {
      child.accept(this);
    });
    return astNode;
  }

  @override
  TemplateAst visitElement(ElementAst astNode, [_]) {
    astNode.events.forEach((event) {
      event.accept(this);
    });
    astNode.properties.forEach((property) {
      property.accept(this);
    });
    astNode.childNodes.forEach((child) {
      child.accept(this);
    });
    return astNode;
  }

  @override
  TemplateAst visitEvent(EventAst astNode, [_]) {
    ExpressionAst expression;
    if (astNode is ParsedEventAst && astNode.valueToken != null) {
      var innerValue = astNode.valueToken.innerValue;
      expression = _parseExpression(innerValue.lexeme, innerValue.offset);
    } else {
      expression = _parseExpression(astNode.value, 0);
    }
    astNode.expression = expression;
    return astNode;
  }

  @override
  TemplateAst visitExpression(ExpressionAst astNode, [_]) => astNode;

  @override
  TemplateAst visitInterpolation(InterpolationAst astNode, [_]) {
    ExpressionAst expression;
    if (astNode is ParsedInterpolationAst && astNode.value != null) {
      expression = _parseExpression(
          astNode.valueToken.lexeme, astNode.valueToken.offset);
    } else {
      expression = _parseExpression(astNode.value, 0);
    }
    astNode.expression = expression;
    return astNode;
  }

  @override
  TemplateAst visitProperty(PropertyAst astNode, [_]) {
    ExpressionAst expression;
    if (astNode is ParsedPropertyAst && astNode.valueToken != null) {
      var valueToken = astNode.valueToken.innerValue;
      expression = _parseExpression(
        valueToken.lexeme,
        valueToken.offset,
      );
    } else {
      expression = _parseExpression(astNode.value, 0);
    }
    astNode.expression = expression;
    return astNode;
  }

  @override
  TemplateAst visitReference(ReferenceAst astNode, [_]) => astNode;

  @override
  TemplateAst visitStar(StarAst astNode, [_]) => astNode;

  @override
  TemplateAst visitText(TextAst astNode, [_]) => astNode;

  /// Parse expression
  ExpressionAst _parseExpression(String expression, int offset) {
    try {
      if (expression == null) {
        return null;
      }
      return new ExpressionAst.parse(
        expression,
        offset,
        sourceUrl: sourceUrl,
      );
    } on AnalysisError catch (e) {
      exceptionHandler.handle(new AngularParserException(
        e.errorCode,
        e.offset,
        e.length,
      ));
    } on AngularParserException catch (e) {
      exceptionHandler.handle(e);
    }
    return null;
  }
}