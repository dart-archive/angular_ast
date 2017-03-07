// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/exception_handler/exception_handler.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:angular_ast/src/expression/micro.dart';

/// A visitor that desugars banana and template nodes
/// within a given AST. Ignores non-desugarable nodes.
/// This modifies the structure, and the original version of
/// each desugared node can be accessed by 'origin'.
class DesugarVisitor extends TemplateAstVisitor<TemplateAst, String> {
  final bool _toolFriendlyAstOrigin;
  final ExceptionHandler exceptionHandler;

  DesugarVisitor({
    bool toolFriendlyAstOrigin: false,
    ExceptionHandler exceptionHandler,
  })
      : exceptionHandler = exceptionHandler ?? new ThrowingExceptionHandler(),
        _toolFriendlyAstOrigin = toolFriendlyAstOrigin;

  @override
  TemplateAst visitAttribute(AttributeAst astNode, [_]) => astNode;

  @override
  TemplateAst visitBanana(BananaAst astNode, [String flag]) {
    TemplateAst origin = _toolFriendlyAstOrigin ? astNode : null;

    String appendedValue = (flag == 'event') ? ' = \$event' : '';
    ExpressionAst expressionAst;
    if (astNode.value != null) {
      try {
        expressionAst = new ExpressionAst.parse(astNode.value + appendedValue,
            sourceUrl: astNode.sourceUrl);
      } catch (e) {
        exceptionHandler.handle(e);
      }
      if (flag == "event") {
        return new EventAst.from(
          origin,
          astNode.name + 'Changed',
          astNode.value + appendedValue,
          expressionAst,
        );
      }
      if (flag == "property") {
        return new PropertyAst.from(
          origin,
          astNode.name,
          astNode.value,
          expressionAst,
        );
      }
    }

    return astNode;
  }

  @override
  TemplateAst visitCloseElement(CloseElementAst astNode, [_]) => astNode;

  @override
  TemplateAst visitComment(CommentAst astNode, [_]) => astNode;

  @override
  TemplateAst visitElement(ElementAst astNode, [_]) {
    if (astNode.bananas.isNotEmpty) {
      for (BananaAst bananaAst in astNode.bananas) {
        TemplateAst toAddEvent = visitBanana(bananaAst, "event");
        astNode.events.add(toAddEvent);

        TemplateAst toAddProperty = visitBanana(bananaAst, "property");
        astNode.properties.add(toAddProperty);
      }
      astNode.bananas.clear();
    }

    if (astNode.stars.isNotEmpty) {
      StarAst starAst = astNode.stars[0];
      TemplateAst origin = _toolFriendlyAstOrigin ? starAst : null;
      final starExpression = starAst.value;
      final directiveName = starAst.name;
      TemplateAst newAst;

      if (isMicroExpression(starExpression)) {
        NgMicroAst micro;
        try {
          micro = parseMicroExpression(
            directiveName,
            starExpression,
            sourceUrl: astNode.sourceUrl,
          );
        } catch (e) {
          exceptionHandler.handle(e);
        }
        List<PropertyAst> properties =
            micro == null ? <PropertyAst>[] : micro.properties;
        List<ReferenceAst> references =
            micro == null ? <ReferenceAst>[] : micro.assignments;
        newAst = new EmbeddedTemplateAst.from(
          origin,
          childNodes: [
            astNode,
          ],
          attributes: [
            new AttributeAst(directiveName),
          ],
          properties: properties,
          references: references,
        );
      } else {
        ExpressionAst expression;
        try {
          expression = new ExpressionAst.parse(
            starExpression,
            sourceUrl: astNode.sourceUrl,
          );
        } catch (e) {
          exceptionHandler.handle(e);
        }
        newAst = new EmbeddedTemplateAst.from(
          origin,
          childNodes: [
            astNode,
          ],
          properties: [
            new PropertyAst(
              directiveName,
              starExpression,
              expression,
            ),
          ],
        );
      }

      astNode.stars.clear();
      return newAst;
    }

    return astNode;
  }

  @override
  TemplateAst visitEmbeddedContent(EmbeddedContentAst astNode, [_]) => astNode;

  @override
  TemplateAst visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [_]) =>
      astNode;

  @override
  TemplateAst visitEvent(EventAst astNode, [_]) => astNode;

  @override
  TemplateAst visitExpression(ExpressionAst astNode, [_]) => astNode;

  @override
  TemplateAst visitInterpolation(InterpolationAst astNode, [_]) => astNode;

  @override
  TemplateAst visitProperty(PropertyAst astNode, [_]) => astNode;

  @override
  TemplateAst visitReference(ReferenceAst astNode, [_]) => astNode;

  @override
  TemplateAst visitStar(StarAst astNode, [_]) => astNode;

  @override
  TemplateAst visitText(TextAst astNode, [_]) => astNode;

  @override
  TemplateAst visitWhitespace(WhitespaceAst astNode, [_]) => astNode;
}
