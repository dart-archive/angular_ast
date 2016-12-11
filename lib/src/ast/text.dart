import 'package:angular_ast/src/ast.dart';
import 'package:source_span/source_span.dart';

/// Represents a block of simple text within in the DOM.
abstract class TextAst implements TemplateAst {
  /// Text value.
  String get value;
}

// Internal.
abstract class TextAstMixin implements TextAst {
  @override
  bool operator ==(Object o) => o is TextAst && o.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '#$TextAst {$value}';
}

// AST node that was created programmatically.
class SyntheticTextAst extends Object with TextAstMixin implements TextAst {
  @override
  final String value;

  SyntheticTextAst(this.value);

  @override
  SourceSpan sourceSpan(_) => throwUnsupported();
}
