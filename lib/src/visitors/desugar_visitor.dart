// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:angular_ast/src/expression/micro.dart';

/// A visitor that desugars banana and template nodes
/// within a given AST. Ignores non-desugarable nodes.
/// This modifies the structure, and the original version of
/// each desugared node can be accessed by 'origin'.
class DesugarVisitor extends TemplateAstVisitor<TemplateAst, String> {
  final bool _toolFriendlyAstOrigin;

  DesugarVisitor({bool toolFriendlyAstOrigin: false})
      : _toolFriendlyAstOrigin = toolFriendlyAstOrigin;

  @override
  TemplateAst visitAttribute(AttributeAst astNode, [_]) => astNode;

  @override
  TemplateAst visitBanana(BananaAst astNode, [String flag]) {
    TemplateAst origin = _toolFriendlyAstOrigin ? astNode : null;
    if (flag == "event") {
      return new EventAst.from(
          origin,
          astNode.name + 'Changed',
          new ExpressionAst.parse('${astNode.value} = \$event',
              sourceUrl: astNode.sourceUrl));
    }
    if (flag == "property") {
      return new PropertyAst.from(origin, astNode.name,
          new ExpressionAst.parse(astNode.value, sourceUrl: astNode.sourceUrl));
    }
    return astNode;
  }

  @override
  TemplateAst visitComment(CommentAst astNode, [_]) => astNode;

  @override
  TemplateAst visitElement(ElementAst astNode, [_]) {
    if (astNode.bananas.isNotEmpty) {
      for (BananaAst bananaAst in astNode.bananas) {
        TemplateAst toAddProperty = visitBanana(bananaAst, "property");
        TemplateAst toAddEvent = visitBanana(bananaAst, "event");
        astNode.properties.add(toAddProperty);
        astNode.events.add(toAddEvent);
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
        final micro = parseMicroExpression(
          directiveName,
          starExpression,
          sourceUrl: astNode.sourceUrl,
        );
        newAst = new EmbeddedTemplateAst.from(
          origin,
          childNodes: [
            astNode,
          ],
          attributes: [
            new AttributeAst(directiveName),
          ],
          properties: micro.properties,
          references: micro.assignments,
        );
      } else {
        newAst = new EmbeddedTemplateAst.from(
          origin,
          childNodes: [
            astNode,
          ],
          properties: [
            new PropertyAst(
              directiveName,
              new ExpressionAst.parse(
                starExpression,
                sourceUrl: astNode.sourceUrl,
              ),
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
