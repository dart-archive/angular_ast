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
  factory ElementAst(String name,
      {List<AttributeAst> attributes,
      List<StandaloneTemplateAst> childNodes,
      List<EventAst> events,
      List<PropertyAst> properties,
      List<ReferenceAst> references,
      List<BananaAst> bananas,
      List<StarAst> stars,
      List<WhitespaceAst> whitespaces}) = _SyntheticElementAst;

  /// Create a synthetic element AST from an existing AST node.
  factory ElementAst.from(TemplateAst origin, String name,
      {List<AttributeAst> attributes,
      List<StandaloneTemplateAst> childNodes,
      List<EventAst> events,
      List<PropertyAst> properties,
      List<ReferenceAst> references,
      List<BananaAst> bananas,
      List<StarAst> stars,
      List<WhitespaceAst> whitespaces}) = _SyntheticElementAst.from;

  /// Create a new element AST from parsed source.
  factory ElementAst.parsed(SourceFile sourceFile, NgToken beginToken,
      NgToken nameToken, int openTagEnd, int closeTagStart, NgToken endToken,
      {List<AttributeAst> attributes,
      List<StandaloneTemplateAst> childNodes,
      List<EventAst> events,
      List<PropertyAst> properties,
      List<ReferenceAst> references,
      List<BananaAst> bananas,
      List<StarAst> stars,
      List<WhitespaceAst> whitespaces}) = ParsedElementAst;

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

  ///Star assignments.
  List<StarAst> get stars;

  set bananas(List<BananaAst> l);

  set stars(List<StarAst> l);

  ///Whitespaces
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

class ParsedElementAst extends TemplateAst with ElementAst {
  final NgToken identifierToken;
  final int openTagEnd;
  final int closeTagStart; //Can be null if void element

  ParsedElementAst(
      SourceFile sourceFile,
      NgToken beginToken,
      this.identifierToken,
      this.openTagEnd,
      this.closeTagStart,
      NgToken endToken,
      {this.attributes: const [],
      this.childNodes: const [],
      this.events: const [],
      this.properties: const [],
      this.references: const [],
      this.bananas: const [],
      this.stars: const [],
      this.whitespaces: const []})
      : super.parsed(beginToken, endToken, sourceFile);

  @override
  String get name => identifierToken.lexeme;

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
  List<BananaAst> bananas;

  @override
  List<StarAst> stars;

  @override
  final List<WhitespaceAst> whitespaces;
}

class _SyntheticElementAst extends SyntheticTemplateAst with ElementAst {
  _SyntheticElementAst(this.name,
      {this.attributes: const [],
      this.childNodes: const [],
      this.events: const [],
      this.properties: const [],
      this.references: const [],
      this.bananas: const [],
      this.stars: const [],
      this.whitespaces: const []});

  _SyntheticElementAst.from(TemplateAst origin, this.name,
      {this.attributes: const [],
      this.childNodes: const [],
      this.events: const [],
      this.properties: const [],
      this.references: const [],
      this.bananas: const [],
      this.stars: const [],
      this.whitespaces: const []})
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
  List<BananaAst> bananas;

  @override
  List<StarAst> stars;

  @override
  final List<WhitespaceAst> whitespaces;
}
