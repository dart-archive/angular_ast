// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/visitor.dart';
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
    List<BananaAst> bananas,
    List<StarAst> stars,
    List<WhitespaceAst> whitespaces,
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
    List<BananaAst> bananas,
    List<StarAst> stars,
    List<WhitespaceAst> whitespaces,
  }) = _SyntheticElementAst.from;

  /// Create a new element AST from parsed source.
  factory ElementAst.parsed(
    SourceFile sourceFile,
    NgToken beginToken,
    NgToken nameToken,
    int openTagEnd,
    int closeTagStart,
    NgToken endToken, {
    List<AttributeAst> attributes,
    List<StandaloneTemplateAst> childNodes,
    List<EventAst> events,
    List<PropertyAst> properties,
    List<ReferenceAst> references,
    List<BananaAst> bananas,
    List<StarAst> stars,
    List<WhitespaceAst> whitespaces,
  }) = ParsedElementAst;

  @override
  bool operator ==(Object o) {
    if (o is ElementAst) {
      return name == o.name &&
          _listEquals.equals(attributes, o.attributes) &&
          _listEquals.equals(childNodes, o.childNodes) &&
          _listEquals.equals(events, o.events) &&
          _listEquals.equals(properties, o.properties) &&
          _listEquals.equals(references, o.references) &&
          _listEquals.equals(bananas, o.bananas) &&
          _listEquals.equals(stars, o.stars);
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
      _listEquals.hash(bananas),
      _listEquals.hash(stars),
    ]);
  }

  @override
  /*=R*/ accept/*<R, C>*/(TemplateAstVisitor/*<R, C>*/ visitor, [C context]) {
    return visitor.visitElement(this, context);
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

  /// Bananas assignments.
  List<BananaAst> get bananas;

  /// Star assignments.
  List<StarAst> get stars;

  /// Whitespaces
  List<WhitespaceAst> get whitespaces;

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
    if (bananas.isNotEmpty) {
      buffer
        ..write('bananas=')
        ..writeAll(bananas, ', ')
        ..write(' ');
    }
    if (stars.isNotEmpty) {
      buffer
        ..write('stars=')
        ..writeAll(stars, ', ')
        ..write(' ');
    }
    if (whitespaces.isNotEmpty) {
      buffer
        ..write('whitespaces=')
        ..writeAll(whitespaces, ', ')
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

/// Represents a real, non-synthetic DOM element that was parsed,
/// that could be upgraded.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedElementAst extends TemplateAst with ElementAst {
  /// [NgToken] that represents the identifier tag in `<tag ...>`.
  final NgToken identifierToken;

  /// Offset of `>` in `<tag ...>` or of `/` in `<voidtag ... />`.
  final int openTagEndOffset;

  /// Offset of `</` in `</tag>`.
  /// May be null if a void <tag /> element (no closing tag).
  final int closeTagStartOffset;

  ParsedElementAst(
    SourceFile sourceFile,
    NgToken beginToken,
    this.identifierToken,
    this.openTagEndOffset,
    this.closeTagStartOffset,
    NgToken endToken, {
    this.attributes: const [],
    this.childNodes: const [],
    this.events: const [],
    this.properties: const [],
    this.references: const [],
    this.bananas: const [],
    this.stars: const [],
    this.whitespaces: const [],
  })
      : super.parsed(beginToken, endToken, sourceFile);

  /// Name (tag) of the element.
  @override
  String get name => identifierToken.lexeme;

  /// Attributes
  @override
  final List<AttributeAst> attributes;

  /// Children nodes.
  @override
  final List<StandaloneTemplateAst> childNodes;

  /// Event listeners.
  @override
  final List<EventAst> events;

  /// Property assignments.
  @override
  final List<PropertyAst> properties;

  /// Reference assignments.
  @override
  final List<ReferenceAst> references;

  /// Banana assignments.
  @override
  final List<BananaAst> bananas;

  /// Star assignments.
  @override
  final List<StarAst> stars;

  /// Whitespaces
  @override
  final List<WhitespaceAst> whitespaces;
}

class _SyntheticElementAst extends SyntheticTemplateAst with ElementAst {
  _SyntheticElementAst(
    this.name, {
    this.attributes: const [],
    this.childNodes: const [],
    this.events: const [],
    this.properties: const [],
    this.references: const [],
    this.bananas: const [],
    this.stars: const [],
    this.whitespaces: const [],
  });

  _SyntheticElementAst.from(
    TemplateAst origin,
    this.name, {
    this.attributes: const [],
    this.childNodes: const [],
    this.events: const [],
    this.properties: const [],
    this.references: const [],
    this.bananas: const [],
    this.stars: const [],
    this.whitespaces: const [],
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

  @override
  final List<BananaAst> bananas;

  @override
  final List<StarAst> stars;

  @override
  final List<WhitespaceAst> whitespaces;
}
