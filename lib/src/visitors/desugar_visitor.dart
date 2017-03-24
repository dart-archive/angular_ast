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
class DesugarVisitor implements TemplateAstVisitor<TemplateAst, String> {
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
    var origin = _toolFriendlyAstOrigin ? astNode : null;

    var appendedValue = (flag == 'event') ? ' = \$event' : '';
    if (astNode.value != null) {
      if (flag == 'event') {
        return new EventAst.from(
          origin,
          astNode.name + 'Changed',
          astNode.value + appendedValue,
        );
      }
      if (flag == 'property') {
        return new PropertyAst.from(
          origin,
          astNode.name,
          astNode.value,
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
    astNode.childNodes.forEach((child) {
      child.accept(this);
    });

    if (astNode.bananas.isNotEmpty) {
      for (BananaAst bananaAst in astNode.bananas) {
        var toAddEvent = visitBanana(bananaAst, 'event');
        astNode.events.add(toAddEvent);

        var toAddProperty = visitBanana(bananaAst, 'property');
        astNode.properties.add(toAddProperty);
      }
      astNode.bananas.clear();
    }

    if (astNode.stars.isNotEmpty) {
      var starAst = astNode.stars[0];
      var origin = _toolFriendlyAstOrigin ? starAst : null;
      var starExpression = starAst.value;
      var expressionOffset =
          (starAst as ParsedStarAst).valueToken.innerValue.offset;
      var directiveName = starAst.name;
      EmbeddedTemplateAst newAst;
      var propertiesToAdd = <PropertyAst>[];
      var referencesToAdd = <ReferenceAst>[];

      // Only add property/reference if they weren't created
      // by desugaring a banana.
      for (var property in astNode.properties) {
        if (!property.isSynthetic) propertiesToAdd.add(property);
      }
      for (var reference in astNode.references) {
        if (!reference.isSynthetic) referencesToAdd.add(reference);
      }

      if (isMicroExpression(starExpression)) {
        NgMicroAst micro;
        try {
          micro = parseMicroExpression(
            directiveName,
            starExpression,
            expressionOffset,
            sourceUrl: astNode.sourceUrl,
          );
        } catch (e) {
          exceptionHandler.handle(e);
          return astNode;
        }
        if (micro != null) {
          propertiesToAdd.addAll(micro.properties);
          referencesToAdd.addAll(micro.assignments);
        }

        newAst = new EmbeddedTemplateAst.from(
          origin,
          childNodes: [
            astNode,
          ],
          attributes: [
            new AttributeAst(directiveName),
          ],
          properties: propertiesToAdd,
          references: referencesToAdd,
        );
      } else {
        propertiesToAdd.add(new PropertyAst(
          directiveName,
          starExpression,
        ));
        newAst = new EmbeddedTemplateAst.from(
          origin,
          childNodes: [
            astNode,
          ],
          properties: propertiesToAdd,
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
}
