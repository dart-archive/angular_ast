import 'package:angular_ast/src/ast.dart';
import 'package:collection/collection.dart';
import 'package:source_span/source_span.dart';
import 'package:quiver/core.dart';

/// Represents a DOM element.
abstract class ElementAst implements TemplateAst {
  /// Child nodes.
  List<TemplateAst> get children;

  /// Element name.
  String get name;
}

const _listEquals = const ListEquality();

// Internal.
abstract class ElementAstMixin implements ElementAst {
  @override
  bool operator ==(Object o) =>
      o is ElementAst &&
      o.name == name &&
      _listEquals.equals(o.children, children);

  @override
  int get hashCode => hash2(name, _listEquals.hash(children));

  @override
  String toString() => '#$ElementAst {$name, children: $children}';
}

// AST node that was created programmatically.
class SyntheticElementAst extends Object
    with ElementAstMixin
    implements ElementAst {
  @override
  final List<TemplateAst> children;

  @override
  final String name;

  SyntheticElementAst(this.name, {this.children: const []});

  @override
  SourceSpan sourceSpan(_) => throwUnsupported();
}
