// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:meta/meta.dart';

/// A visitor for [TemplateAst] trees that may process each node.
///
/// An implementation may return element [R], and optionally use [C] as context.
abstract class TemplateAstVisitor<R, C> {
  const TemplateAstVisitor();

  /// Visits an [astNode] tree, passing along [context] if given.
  ///
  /// Based on the subtype other `visit` methods are called.
  R visit(TemplateAst astNode, [C context]) {
    if (astNode is AttributeAst) {
      return visitAttribute(astNode, context);
    }
    if (astNode is CommentAst) {
      return visitComment(astNode, context);
    }
    if (astNode is EmbeddedContentAst) {
      return visitEmbeddedContent(astNode, context);
    }
    if (astNode is EmbeddedTemplateAst) {
      return visitEmbeddedTemplate(astNode, context);
    }
    if (astNode is ElementAst) {
      return visitElement(astNode, context);
    }
    if (astNode is EventAst) {
      return visitEvent(astNode, context);
    }
    if (astNode is InterpolationAst) {
      return visitInterpolation(astNode, context);
    }
    if (astNode is PropertyAst) {
      return visitProperty(astNode, context);
    }
    if (astNode is ReferenceAst) {
      return visitReference(astNode, context);
    }
    if (astNode is TextAst) {
      return visitText(astNode, context);
    }
    throw new UnsupportedError('${astNode.runtimeType}');
  }

  /// Visits all attribute ASTs.
  R visitAttribute(AttributeAst astNode, [C context]);

  /// Visits all comment ASTs.
  R visitComment(CommentAst astNode, [C context]);

  /// Visits all embedded content ASTs.
  @mustCallSuper
  R visitEmbeddedContent(EmbeddedContentAst astNode, [C context]) {
    astNode.childNodes.forEach((c) => visit(c, context));
    return null;
  }

  /// Visits all embedded template ASTs.
  R visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [C context]) {
    astNode
      ..childNodes.forEach((c) => visit(c, context))
      ..properties.forEach((p) => visitProperty(p, context))
      ..references.forEach((r) => visitReference(r, context));
    return null;
  }

  /// Visits all element ASTs.
  @mustCallSuper
  R visitElement(ElementAst astNode, [C context]) {
    astNode
      ..attributes.forEach((a) => visitAttribute(a, context))
      ..childNodes.forEach((c) => visit(c, context))
      ..events.forEach((e) => visitEvent(e, context))
      ..properties.forEach((p) => visitProperty(p, context))
      ..references.forEach((r) => visitReference(r, context));
    return null;
  }

  /// Visits all event ASTs.
  R visitEvent(EventAst astNode, [C context]);

  /// Visits all interpolation ASTs.
  R visitInterpolation(InterpolationAst astNode, [C context]);

  /// Visits all property ASTs.
  R visitProperty(PropertyAst astNode, [C context]);

  /// Visits all reference ASTs.
  R visitReference(ReferenceAst astNode, [C context]);

  /// Visits all text ASTs.
  R visitText(TextAst astNode, [C context]);
}
