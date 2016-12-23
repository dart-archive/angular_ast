import 'package:angular_ast/src/ast/attribute.dart';
import 'package:angular_ast/src/ast/comment.dart';
import 'package:angular_ast/src/ast/content.dart';
import 'package:angular_ast/src/ast/element.dart';
import 'package:angular_ast/src/ast/event.dart';
import 'package:angular_ast/src/ast/interface.dart';
import 'package:angular_ast/src/ast/interpolation.dart';
import 'package:angular_ast/src/ast/property.dart';
import 'package:angular_ast/src/ast/reference.dart';
import 'package:angular_ast/src/ast/template.dart';
import 'package:angular_ast/src/ast/text.dart';
import 'package:angular_ast/src/visitor.dart';

/// Provides a human-readable view of a template AST tree.
class HumanizingTemplateAstVisitor extends TemplateAstVisitor<String, StringBuffer> {
  const HumanizingTemplateAstVisitor();

  @override
  String visit(TemplateAst astNode, [StringBuffer context]) {
    context ??= new StringBuffer();
    super.visit(astNode, context);
    return context.toString();
  }

  @override
  String visitAttribute(AttributeAst astNode, [_]) {
    if (astNode.value != null) {
      return '${astNode.name}="${astNode.value}"';
    } else {
      return '${astNode.name}';
    }
  }

  @override
  String visitComment(CommentAst astNode, [_]) {
    return '<!--${astNode.value}-->';
  }

  @override
  String visitElement(ElementAst astNode, [StringBuffer context]) {
    context ??= new StringBuffer();
    context
      ..write('<')
      ..write(astNode.name);
    if (astNode.attributes.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.attributes.map(visitAttribute), ' ');
    }
    if (astNode.events.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.events.map(visitEvent), ' ');
    }
    if (astNode.properties.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.properties.map(visitProperty), ' ');
    }
    if (astNode.references.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.references.map(visitReference), ' ');
    }
    context.write('>');
    if (astNode.childNodes.isNotEmpty) {
      context.writeAll(astNode.childNodes.map(visit));
    }
    context
      ..write('</')
      ..write(astNode.name)
      ..write('>');
    return context.toString();
  }

  @override
  String visitEmbeddedContent(EmbeddedContentAst astNode, [_]) {
    // TODO: implement visitEmbeddedContent
  }

  @override
  String visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [StringBuffer context]) {
    // TODO: implement visitEmbeddedTemplate
  }

  @override
  String visitEvent(EventAst astNode, [StringBuffer context]) {
    // TODO: implement visitEvent
  }

  @override
  String visitInterpolation(InterpolationAst astNode, [StringBuffer context]) {
    // TODO: implement visitInterpolation
  }

  @override
  String visitProperty(PropertyAst astNode, [StringBuffer context]) {
    // TODO: implement visitProperty
  }

  @override
  String visitReference(ReferenceAst astNode, [StringBuffer context]) {
    // TODO: implement visitReference
  }

  @override
  String visitText(TextAst astNode, [StringBuffer context]) {
    // TODO: implement visitText
  }
}
