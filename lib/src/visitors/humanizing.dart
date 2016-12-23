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
class HumanizingTemplateAstVisitor
    extends TemplateAstVisitor<String, StringBuffer> {
  const HumanizingTemplateAstVisitor();

  @override
  String visit(TemplateAst astNode, [StringBuffer context]) {
    return super.visit(astNode, context);
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
    context..write('<')..write(astNode.name);
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
    context..write('</')..write(astNode.name)..write('>');
    return context.toString();
  }

  @override
  String visitEmbeddedContent(
    EmbeddedContentAst astNode, [
    StringBuffer context,
  ]) {
    context ??= new StringBuffer();
    if (astNode.selector != null) {
      context.write('<ng-content select="${astNode.selector}">');
    } else {
      context.write('<ng-content>');
    }
    context.write('</ng-content>');
    return context.toString();
  }

  @override
  String visitEmbeddedTemplate(
    EmbeddedTemplateAst astNode, [
    StringBuffer context,
  ]) {
    context ??= new StringBuffer();
    context..write('<template');
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
    context..write('</template>');
    return context.toString();
  }

  @override
  String visitEvent(EventAst astNode, [_]) {
    return '(${astNode.name})="${astNode.expression.expression.toSource()}"';
  }

  @override
  String visitInterpolation(InterpolationAst astNode, [_]) {
    return '{{${astNode.expression.expression.toSource()}}}';
  }

  @override
  String visitProperty(PropertyAst astNode, [_]) {
    if (astNode.expression != null) {
      return '[${astNode.name}]="${astNode.expression.expression.toSource()}"';
    } else {
      return '[${astNode.name}]';
    }
  }

  @override
  String visitReference(ReferenceAst astNode, [_]) {
    if (astNode.variable != null) {
      return '#${astNode.identifier}="${astNode.variable}"';
    } else {
      return '#${astNode.identifier}';
    }
  }

  @override
  String visitText(TextAst astNode, [_]) => astNode.value;
}
