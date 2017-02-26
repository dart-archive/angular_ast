// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/parser/reader.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:source_span/source_span.dart';

/// A recursive descent AST parser from a series of tokens.
class RecursiveAstParser {
  final NgTokenReversibleReader _reader;
  final SourceFile _source;
  final List<String> _voidElements;

  RecursiveAstParser(
    SourceFile sourceFile,
    Iterable<NgToken> tokens,
    this._voidElements,
  )
      : _reader = new NgTokenReversibleReader(sourceFile, tokens),
        _source = sourceFile;

  /// Iterates through and returns the top-level AST nodes from the tokens.
  List<StandaloneTemplateAst> parse() {
    // Start with an empty list.
    final nodes = <StandaloneTemplateAst>[];
    NgToken token;

    // Iterate through until and wait until EOF.
    //
    // Collects comments, elements, and text.
    //
    // Any other AST structure should be handled by the parseElement case.
    while ((token = _reader.next()) != null) {
      nodes.add(parseStandalone(token));
    }

    // Return the collected nodes.
    return nodes;
  }

  /// Parses and returns a comment beginning at the token provided.
  CommentAst parseComment(NgToken beginToken) {
    final valueToken = _reader.expect(NgTokenType.commentValue);
    final endToken = _reader.expect(NgTokenType.commentEnd);
    return new CommentAst.parsed(
      _source,
      beginToken,
      valueToken,
      endToken,
    );
  }

  /// Parses and returns a template AST beginning at the token provided.
  /// No desugaring of any kind occurs here.
  TemplateAst parseDecorator(NgToken beginToken) {
    // The first token is the decorator/name.
    NgToken prefixToken;
    NgToken decoratorToken;
    NgToken suffixToken;

    NgTokenType peekType = _reader.peekType();
    if (peekType == NgTokenType.bananaPrefix ||
        peekType == NgTokenType.eventPrefix ||
        peekType == NgTokenType.propertyPrefix) {
      prefixToken = _reader.next();
      decoratorToken = _reader.next();
      suffixToken = _reader.next();
    } else if (peekType == NgTokenType.referencePrefix ||
        peekType == NgTokenType.templatePrefix) {
      prefixToken = _reader.next();
      decoratorToken = _reader.next();
    } else {
      decoratorToken = _reader.next();
    }

    NgAttributeValueToken valueToken;
    NgToken equalSignToken;

    if (_reader.peekTypeIgnoringType(NgTokenType.whitespace) ==
        NgTokenType.beforeElementDecoratorValue) {
      while (_reader.peekType() == NgTokenType.whitespace) {
        _reader.next();
      }
      equalSignToken = _reader.next();
      valueToken = _reader.expectTypeIgnoringType(
              NgTokenType.elementDecoratorValue, NgTokenType.whitespace)
          as NgAttributeValueToken;
    }

    if (prefixToken != null) {
      NgTokenType prefixType = prefixToken.type;

      if (prefixType == NgTokenType.bananaPrefix) {
        return new BananaAst.parsed(
          _source,
          beginToken,
          prefixToken,
          decoratorToken,
          suffixToken,
          valueToken,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.eventPrefix) {
        return new EventAst.parsed(
          _source,
          beginToken,
          prefixToken,
          decoratorToken,
          suffixToken,
          valueToken,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.propertyPrefix) {
        return new PropertyAst.parsed(
          _source,
          beginToken,
          prefixToken,
          decoratorToken,
          suffixToken,
          valueToken,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.referencePrefix) {
        return new ReferenceAst.parsed(
          _source,
          beginToken,
          prefixToken,
          decoratorToken,
          valueToken,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.templatePrefix) {
        return new StarAst.parsed(
          _source,
          beginToken,
          prefixToken,
          decoratorToken,
          valueToken,
          equalSignToken,
        );
      }
    }
    return new AttributeAst.parsed(
      _source,
      beginToken,
      decoratorToken,
      valueToken,
      equalSignToken,
    );
  }

  /// Returns a DOM element AST starting at the provided token.
  ///
  /// It's possible the element will end up not being an [ElementAst].
  StandaloneTemplateAst parseElement(NgToken beginToken) {
    // Parse the element identifier.
    final nameToken = _reader.expect(NgTokenType.elementIdentifier);
    //TODO: do we want to allow trailing spaces in content/template tags?
    if (nameToken.lexeme == 'ng-content') {
      return parseEmbeddedContent(beginToken);
    } else if (nameToken.lexeme == 'template') {
      return parseEmbeddedTemplate(beginToken);
    }
    final isVoidElement = _voidElements.contains(nameToken.lexeme);

    // Start collecting decorators.
    final attributes = <AttributeAst>[];
    final childNodes = <StandaloneTemplateAst>[];
    final events = <EventAst>[];
    final properties = <PropertyAst>[];
    final references = <ReferenceAst>[];
    final bananas = <BananaAst>[];
    final stars = <StarAst>[];
    final whitespaces = <WhitespaceAst>[];
    int openTagEnd;
    int closeTagStart;
    NgToken nextToken;

    // Start looping and get all of the decorators within the element.
    do {
      nextToken = _reader.next();
      if (nextToken.type == NgTokenType.beforeElementDecorator) {
        var decoratorAst = parseDecorator(nextToken);
        if (decoratorAst is AttributeAst) {
          attributes.add(decoratorAst);
        } else if (decoratorAst is StarAst) {
          if (stars.isNotEmpty) {
            _reader.error(''
                'Already found an *-directive, limit 1 per element, but also '
                'found ${decoratorAst.sourceSpan.highlight()}');
            return null;
          }
          stars.add(decoratorAst);
        } else if (decoratorAst is EventAst) {
          events.add(decoratorAst);
        } else if (decoratorAst is PropertyAst) {
          properties.add(decoratorAst);
        } else if (decoratorAst is BananaAst) {
          bananas.add(decoratorAst);
        } else if (decoratorAst is ReferenceAst) {
          references.add(decoratorAst);
        } else {
          throw new StateError('Invalid decorator AST: $decoratorAst');
        }
      }
      if (nextToken.type == NgTokenType.whitespace) {
        whitespaces.add(new WhitespaceAst(_source, nextToken));
      }
    } while (nextToken.type != NgTokenType.openElementEnd &&
        nextToken.type != NgTokenType.openElementEndVoid);

    // If this is a void element, skip this part
    var endToken = nextToken;
    openTagEnd = endToken.offset;
    //Look for closing tag
    if (!isVoidElement && nextToken.type != NgTokenType.openElementEndVoid) {
      // Collect child nodes.
      nextToken = _reader.next();
      while (nextToken.type != NgTokenType.closeElementStart) {
        childNodes.add(parseStandalone(nextToken));
        nextToken = _reader.next();
      }
      closeTagStart = nextToken.offset;
      // Finally return the element.
      final closeName = _reader.expect(NgTokenType.elementIdentifier);
      if (closeName.lexeme != nameToken.lexeme) {
        _reader.error('Invalid closing tag: $closeName (expected $nameToken)');
      }
      while (_reader.peekType() == NgTokenType.whitespace) {
        _reader.next();
      }
      endToken = _reader.expect(NgTokenType.closeElementEnd);
    }

    final element = new ElementAst.parsed(
      _source,
      beginToken,
      nameToken,
      openTagEnd,
      closeTagStart,
      endToken,
      attributes: attributes,
      childNodes: childNodes,
      events: events,
      properties: properties,
      references: references,
      bananas: bananas,
      stars: stars,
      whitespaces: whitespaces,
    );
    return element;
  }

  /// Returns and parses an embedded content directive/transclusions.
  EmbeddedContentAst parseEmbeddedContent(NgToken beginToken) {
    NgAttributeValueToken valueToken;
    final nextToken = _reader.next();
    if (nextToken.type == NgTokenType.beforeElementDecorator) {
      final decorator = _reader.expect(NgTokenType.elementDecorator);
      if (decorator.lexeme != 'select') {
        _reader.error(''
            'Only "select" is a valid attriubute on <ng-content>, got '
            '"${decorator.lexeme}"');
        return null;
      }
      _reader.expect(NgTokenType.beforeElementDecoratorValue);
      valueToken = _reader.expect(NgTokenType.elementDecoratorValue);
      _reader.expect(NgTokenType.openElementEnd);
    } else if (nextToken.type != NgTokenType.openElementEnd) {
      _reader.error('Expected ">", got $nextToken');
      return null;
    }
    _reader.expect(NgTokenType.closeElementStart);
    final closeName = _reader.expect(NgTokenType.elementIdentifier);
    if (closeName.lexeme != 'ng-content') {
      _reader.error(''
          'Expected closing tag for "ng-content", got '
          '"${closeName.lexeme}"');
      return null;
    }
    final endToken = _reader.expect(NgTokenType.closeElementEnd);
    return new EmbeddedContentAst.parsed(
      _source,
      beginToken,
      endToken,
      valueToken?.innerValue,
    );
  }

  /// Returns and parses an embedded `<template>`.
  EmbeddedTemplateAst parseEmbeddedTemplate(NgToken beginToken) {
    // Start collecting decorators.
    final childNodes = <StandaloneTemplateAst>[];
    final properties = <PropertyAst>[];
    final references = <ReferenceAst>[];
    NgToken nextToken;

    // Start looping and get all of the decorators within the element.
    do {
      nextToken = _reader.next();
      if (nextToken.type == NgTokenType.beforeElementDecorator) {
        var decoratorAst = parseDecorator(nextToken);
        if (decoratorAst is PropertyAst) {
          properties.add(decoratorAst);
        } else if (decoratorAst is ReferenceAst) {
          references.add(decoratorAst);
        } else {
          throw new StateError('Invalid decorator AST: $decoratorAst');
        }
      }
    } while (nextToken.type != NgTokenType.openElementEnd);

    // Collect child nodes.
    while ((nextToken = _reader.next()).type != NgTokenType.closeElementStart) {
      childNodes.add(parseStandalone(nextToken));
    }

    // Finally return the element.
    final closeName = _reader.expect(NgTokenType.elementIdentifier);
    if (closeName.lexeme != 'template') {
      _reader.error('Invalid closing tag: $closeName (expected "template")');
    }

    final endToken = _reader.expect(NgTokenType.closeElementEnd);
    return new EmbeddedTemplateAst.parsed(
      _source,
      beginToken,
      endToken,
      childNodes: childNodes,
      properties: properties,
      references: references,
    );
  }

  /// Returns and parses an interpolation AST.
  InterpolationAst parseInterpolation(NgToken beginToken) {
    final valueToken = _reader.expect(NgTokenType.interpolationValue);
    final endToken = _reader.expect(NgTokenType.interpolationEnd);
    return new InterpolationAst.parsed(
      _source,
      beginToken,
      valueToken.lexeme,
      endToken,
    );
  }

  /// Returns and parses a top-level AST structure.
  StandaloneTemplateAst parseStandalone(NgToken token) {
    switch (token.type) {
      case NgTokenType.commentStart:
        return parseComment(token);
      case NgTokenType.openElementStart:
        return parseElement(token);
      case NgTokenType.interpolationStart:
        return parseInterpolation(token);
      case NgTokenType.text:
        return parseText(token);
      default:
        _reader.error('Expected standalone token, got ${token.type}');
        return null;
    }
  }

  /// Returns and parses a text AST.
  TextAst parseText(NgToken token) => new TextAst.parsed(_source, token);
}
