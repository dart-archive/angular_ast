import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token.dart';
import 'package:collection/collection.dart';
import 'package:source_span/source_span.dart';
import 'package:quiver/core.dart';

const _listEquals = const ListEquality();

/// Represents a DOM element that was parsed, that could be upgraded.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class ElementAst implements StandaloneTemplateAst {
  /// Create a synthetic element AST.
  factory ElementAst(
    String name, {
    List<AttributeAst> attributes,
    List<StandaloneTemplateAst> childNodes,
    List<EventAst> events,
    List<PropertyAst> properties,
    List<ReferenceAst> references,
  }) = _SyntheticElementAst;

  /// Create a synthetic element AST from an existing AST node.
  factory ElementAst.from(
    TemplateAst origin,
    String name, {
    List<AttributeAst> attributes,
    List<StandaloneTemplateAst> childNodes,
    List<EventAst> events,
    List<PropertyAst> properties,
    List<ReferenceAst> references,
  }) = _SyntheticElementAst.from;

  /// Create a new element AST from parsed source.
  factory ElementAst.parsed(
    SourceFile sourceFile,
    NgToken beginToken,
    NgToken nameToken,
    NgToken endToken, {
    List<AttributeAst> attributes,
    List<StandaloneTemplateAst> childNodes,
    List<EventAst> events,
    List<PropertyAst> properties,
    List<ReferenceAst> references,
  }) = _ParsedElementAst;

  @override
  bool operator ==(Object o) {
    if (o is ElementAst) {
      return name == o.name &&
          _listEquals.equals(attributes, o.attributes) &&
          _listEquals.equals(childNodes, o.childNodes) &&
          _listEquals.equals(events, o.events) &&
          _listEquals.equals(properties, o.properties) &&
          _listEquals.equals(references, o.references);
    }
    return false;
  }

  @override
  int get hashCode {
    return hashObjects([
      name,
      _listEquals.hash(attributes),
      _listEquals.hash(childNodes),
      _listEquals.hash(events),
      _listEquals.hash(properties),
      _listEquals.hash(references),
    ]);
  }

  /// Whether this is a `<template>` tag and should not be directly rendered.
  bool get isEmbeddedTemplate => name == 'template';

  /// Name (tag) of the element.
  String get name;

  /// Attributes.
  List<AttributeAst> get attributes;

  /// Event listeners.
  List<EventAst> get events;

  /// Property assignments.
  List<PropertyAst> get properties;

  /// Reference assignments.
  List<ReferenceAst> get references;

  @override
  String toString() {
    final buffer = new StringBuffer('$ElementAst <$name> { ');
    if (attributes.isNotEmpty) {
      buffer
        ..write('attributes=')
        ..writeAll(attributes, ', ')
        ..write(' ');
    }
    if (events.isNotEmpty) {
      buffer
        ..write('events=')
        ..writeAll(events, ', ')
        ..write(' ');
    }
    if (properties.isNotEmpty) {
      buffer
        ..write('properties=')
        ..writeAll(properties, ', ')
        ..write(' ');
    }
    if (references.isNotEmpty) {
      buffer
        ..write('references=')
        ..writeAll(references, ', ')
        ..write(' ');
    }
    if (childNodes.isNotEmpty) {
      buffer
        ..write('childNodes=')
        ..writeAll(childNodes, ', ')
        ..write(' ');
    }
    return (buffer..write('}')).toString();
  }
}

class _ParsedElementAst extends TemplateAst with ElementAst {
  final NgToken _nameToken;

  _ParsedElementAst(
    SourceFile sourceFile,
    NgToken beginToken,
    this._nameToken,
    NgToken endToken, {
    this.attributes: const [],
    this.childNodes: const [],
    this.events: const [],
    this.properties: const [],
    this.references: const [],
  })
      : super.parsed(beginToken, endToken, sourceFile);

  @override
  String get name => _nameToken.lexeme;

  @override
  final List<AttributeAst> attributes;

  @override
  final List<StandaloneTemplateAst> childNodes;

  @override
  final List<EventAst> events;

  @override
  final List<PropertyAst> properties;

  @override
  final List<ReferenceAst> references;
}

class _SyntheticElementAst extends SyntheticTemplateAst with ElementAst {
  _SyntheticElementAst(
    this.name, {
    this.attributes: const [],
    this.childNodes: const [],
    this.events: const [],
    this.properties: const [],
    this.references: const [],
  });

  _SyntheticElementAst.from(
    TemplateAst origin,
    this.name, {
    this.attributes: const [],
    this.childNodes: const [],
    this.events: const [],
    this.properties: const [],
    this.references: const [],
  })
      : super.from(origin);

  @override
  final String name;

  @override
  final List<AttributeAst> attributes;

  @override
  final List<StandaloneTemplateAst> childNodes;

  @override
  final List<EventAst> events;

  @override
  final List<PropertyAst> properties;

  @override
  final List<ReferenceAst> references;
}
