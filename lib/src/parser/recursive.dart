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
  final exceptionHandler;

  RecursiveAstParser(SourceFile sourceFile, Iterable<NgToken> tokens,
      this._voidElements, this.exceptionHandler)
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

  CloseElementAst parseCloseElement(NgToken beginToken) {
    final nameToken = _reader.expect(NgTokenType.elementIdentifier);
    if (_voidElements.contains(nameToken.lexeme)) {
      exceptionHandler.handle(new FormatException(
        "${nameToken.lexeme} is a void element and cannot be used in a close element tag",
        _source.getText(0),
        nameToken.offset,
      ));
    }

    List<WhitespaceAst> whitespaces = <WhitespaceAst>[];
    while (_reader.peekType() == NgTokenType.whitespace) {
      whitespaces.add(new WhitespaceAst(_source, _reader.next()));
    }
    final closeElementEnd = _reader.expect(NgTokenType.closeElementEnd);
    return new CloseElementAst.parsed(
      _source,
      beginToken,
      nameToken,
      closeElementEnd,
      whitespaces: whitespaces,
    );
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
        ExpressionAst expressionAst =
            parseExpression(valueToken?.innerValue?.lexeme);
        return new EventAst.parsed(
          _source,
          beginToken,
          prefixToken,
          decoratorToken,
          suffixToken,
          valueToken,
          expressionAst,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.propertyPrefix) {
        ExpressionAst expressionAst =
            parseExpression(valueToken?.innerValue?.lexeme);
        return new PropertyAst.parsed(
          _source,
          beginToken,
          prefixToken,
          decoratorToken,
          suffixToken,
          valueToken,
          expressionAst,
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
            exceptionHandler.handle(new FormatException(
              'Already found an *-directive, limit 1 per element, but also '
                  'found ${decoratorAst.sourceSpan.highlight()}',
              _source.getText(0),
              decoratorAst.beginToken.offset,
            ));
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

    NgToken endToken = nextToken;
    CloseElementAst closeElementAst;
    int scopeEnd = endToken.end;

    // TODO: Potentially check if openElementEndVoid is being used on a
    // TODO: non-valid element name

    // If not a void element, look for closing tag OR child nodes.
    if (!isVoidElement && nextToken.type != NgTokenType.openElementEndVoid) {
      // Collect child nodes.
      nextToken = _reader.next();
      // Guaranteed by scanner w/ recovery that next token is beginning of a
      // a standaloneAst-starting token OR null.
      while (nextToken != null &&
          nextToken.type != NgTokenType.closeElementStart) {
        TemplateAst childAst = parseStandalone(nextToken);
        if (childAst is ElementAst &&
            childAst.closeComplement != null &&
            !childAst.closeComplement.isSynthetic) {
          scopeEnd = childAst.closeComplement.endToken.end;
        } else {
          scopeEnd = childAst.endToken.end;
        }
        childNodes.add(childAst);
        nextToken = _reader.next();
      }
      if (nextToken == null) {
        exceptionHandler.handle(new FormatException(
          "Expected close element for '${nameToken.lexeme}'",
          _source.getText(0), // TODO: Inefficient - remove later
          scopeEnd,
        ));
        closeElementAst = new CloseElementAst(nameToken.lexeme);
      } else {
        final closeNameToken = _reader.peek();
        if (closeNameToken.lexeme != nameToken.lexeme) {
          exceptionHandler.handle(new FormatException(
            'Invalid closing tag: $closeNameToken (expected $nameToken)',
            _source.getText(0),
            closeNameToken.offset,
          ));
          _reader.putBack(nextToken);
          closeElementAst = new CloseElementAst(nameToken.lexeme);
        } else {
          closeElementAst = parseCloseElement(nextToken);
        }
      }
    }

    final element = new ElementAst.parsed(
      _source,
      beginToken,
      nameToken,
      endToken,
      isVoidElement: isVoidElement,
      attributes: attributes,
      childNodes: childNodes,
      events: events,
      properties: properties,
      references: references,
      bananas: bananas,
      stars: stars,
      whitespaces: whitespaces,
      closeComplement: closeElementAst,
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
  ///
  /// [CloseElementAst] is returned if and only if it cannot be
  /// matched to an [ElementAst] and only if errorRecovery is enabled.
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
      // Always an error case
      case NgTokenType.closeElementStart:
        exceptionHandler.handle(new FormatException(
          "Close element cannot exist before matching open element",
          _source.getText(0),
          token.offset,
        ));
        CloseElementAst closeElementAst = parseCloseElement(token);
        ElementAst synthElementAst = new ElementAst(closeElementAst.name);
        synthElementAst.closeComplement = closeElementAst;
        return synthElementAst;
      default:
        _reader.error('Expected standalone token, got ${token.type}');
        return null;
    }
  }

  /// Returns and parses a text AST.
  TextAst parseText(NgToken token) => new TextAst.parsed(_source, token);

  /// Parse expression
  ExpressionAst parseExpression(String expression) {
    try {
      if (expression == null) {
        return null;
      }
      return new ExpressionAst.parse(expression,
          sourceUrl: _source.url.toString());
    } catch (e) {
      exceptionHandler.handle(e);
    }
    return null;
  }
}
