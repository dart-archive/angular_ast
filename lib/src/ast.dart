import 'package:angular_ast/src/ast/attribute.dart'
    show AttributeAst, SyntheticAttributeAst;
import 'package:angular_ast/src/ast/element.dart' show SyntheticElementAst;
import 'package:angular_ast/src/ast/text.dart' show SyntheticTextAst;
import 'package:source_span/source_span.dart';

export 'package:angular_ast/src/ast/attribute.dart'
    show AttributeAst, AttributeAstMixin;
export 'package:angular_ast/src/ast/element.dart'
    show ElementAst, ElementAstMixin;
export 'package:angular_ast/src/ast/text.dart' show TextAst, TextAstMixin;

abstract class TemplateAst {
  factory TemplateAst.attribute(
    String name, [
    String value,
  ]) = SyntheticAttributeAst;

  factory TemplateAst.element(
    String name, {
    List<AttributeAst> attributes,
    List<TemplateAst> children,
  }) = SyntheticElementAst;

  factory TemplateAst.text(String value) = SyntheticTextAst;

  SourceSpan sourceSpan(SourceFile file);
}

throwUnsupported() => throw new UnsupportedError('Not from source');
