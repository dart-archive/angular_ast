import 'package:angular_ast/src/ast.dart';
import 'package:source_span/source_span.dart';
import 'package:quiver/core.dart';

/// Represents an HTML attribute assignment.
///
/// Has an optional [value], which is a simple string.
abstract class AttributeAst implements TemplateAst {
  /// Name of the attribute.
  String get name;

  /// Static string value.
  String get value;
}

// Internal.
abstract class AttributeAstMixin implements AttributeAst {
  @override
  bool operator ==(Object o) =>
      o is AttributeAst && o.name == name && o.value == value;

  @override
  int get hashCode => hash2(name, value);

  @override
  String toString() {
    if (value == null) {
      return '#$AttributeAst {$name}';
    }
    return '#$AttributeAst {$name=$value}';
  }
}

// AST node that was created programmatically.
class SyntheticAttributeAst extends Object
    with AttributeAstMixin
    implements AttributeAst {
  @override
  final String name;

  @override
  final String value;

  SyntheticAttributeAst(this.name, [this.value]);

  @override
  SourceSpan sourceSpan(_) => throwUnsupported();
}
