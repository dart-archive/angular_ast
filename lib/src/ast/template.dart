// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:collection/collection.dart';
import 'package:quiver/core.dart';
import 'package:source_span/source_span.dart';

const _listEquals = const ListEquality();

/// Represents an embedded template (i.e. is not directly rendered in DOM).
///
/// It shares many properties with an [ElementAst], but is not one. It may be
/// considered invalid to a `<template>` without any [properties] or
/// [references].
///
/// Clients should not extend, implement, or mix-in this class.
abstract class EmbeddedTemplateAst implements StandaloneTemplateAst {
  factory EmbeddedTemplateAst({
    List<AttributeAst> attributes,
    List<StandaloneTemplateAst> childNodes,
    List<PropertyAst> properties,
    List<ReferenceAst> references,
  }) = _SyntheticEmbeddedTemplateAst;

  factory EmbeddedTemplateAst.from(
    TemplateAst origin, {
    List<AttributeAst> attributes,
    List<StandaloneTemplateAst> childNodes,
    List<PropertyAst> properties,
    List<ReferenceAst> references,
  }) = _SyntheticEmbeddedTemplateAst.from;

  factory EmbeddedTemplateAst.parsed(
    SourceFile sourceFile,
    NgToken beginToken,
    NgToken endToken, {
    List<AttributeAst> attributes,
    List<StandaloneTemplateAst> childNodes,
    List<PropertyAst> properties,
    List<ReferenceAst> references,
  }) = _ParsedEmbeddedTemplateAst;

  @override
  /*=R*/ accept/*<R, C>*/(TemplateAstVisitor/*<R, C>*/ visitor, [C context]) {
    return visitor.visitEmbeddedTemplate(this, context);
  }

  /// Attributes.
  ///
  /// Within a `<template>` tag, it may be assumed that this is a directive.
  List<AttributeAst> get attributes;

  /// Property assignments.
  ///
  /// For an embedded template, it may be assumed that all of this will be one
  /// or more structural directives (i.e. like `ngForOf`), as the template
  /// itself does not have properties.
  List<PropertyAst> get properties;

  /// References to the template.
  ///
  /// Unlike a reference to a DOM element, this will be a `TemplateRef`.
  List<ReferenceAst> get references;

  @override
  bool operator ==(Object o) {
    if (o is EmbeddedTemplateAst) {
      return _listEquals.equals(properties, o.properties) &&
          _listEquals.equals(childNodes, o.childNodes) &&
          _listEquals.equals(references, o.references);
    }
    return false;
  }

  @override
  int get hashCode {
    return hash3(
      _listEquals.hash(properties),
      _listEquals.hash(childNodes),
      _listEquals.hash(references),
    );
  }

  @override
  String toString() {
    final buffer = new StringBuffer('$EmbeddedTemplateAst{ ');
    if (attributes.isNotEmpty) {
      buffer
        ..write('attributes=')
        ..writeAll(attributes, ', ')
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

class _ParsedEmbeddedTemplateAst extends TemplateAst with EmbeddedTemplateAst {
  _ParsedEmbeddedTemplateAst(
    SourceFile sourceFile,
    NgToken beginToken,
    NgToken endToken, {
    this.attributes: const [],
    this.childNodes: const [],
    this.properties: const [],
    this.references: const [],
  })
      : super.parsed(beginToken, endToken, sourceFile);

  @override
  final List<AttributeAst> attributes;

  @override
  final List<StandaloneTemplateAst> childNodes;

  @override
  final List<PropertyAst> properties;

  @override
  final List<ReferenceAst> references;
}

class _SyntheticEmbeddedTemplateAst extends SyntheticTemplateAst
    with EmbeddedTemplateAst {
  _SyntheticEmbeddedTemplateAst({
    this.attributes: const [],
    this.childNodes: const [],
    this.properties: const [],
    this.references: const [],
  });

  _SyntheticEmbeddedTemplateAst.from(
    TemplateAst origin, {
    this.attributes: const [],
    this.childNodes: const [],
    this.properties: const [],
    this.references: const [],
  });

  @override
  final List<AttributeAst> attributes;

  @override
  final List<StandaloneTemplateAst> childNodes;

  @override
  final List<PropertyAst> properties;

  @override
  final List<ReferenceAst> references;
}
