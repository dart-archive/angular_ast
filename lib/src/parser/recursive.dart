// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/exception_handler/angular_parser_exception.dart';
import 'package:angular_ast/src/parser/reader.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:source_span/source_span.dart';

/// A recursive descent AST parser from a series of tokens.
class RecursiveAstParser {
  final NgTokenReversibleReader _reader;
  final SourceFile _source;
  final List<String> _voidElements;
  final exceptionHandler;

  RecursiveAstParser(
    SourceFile sourceFile,
    Iterable<NgToken> tokens,
    this._voidElements,
    this.exceptionHandler,
  )
      : _reader = new NgTokenReversibleReader<NgTokenType>(sourceFile, tokens),
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

  /// Parses and returns a [CloseElementAst].
  CloseElementAst parseCloseElement(NgToken beginToken) {
    var nameToken = _reader.expect(NgTokenType.elementIdentifier);
    if (_voidElements.contains(nameToken.lexeme)) {
      exceptionHandler.handle(new AngularParserException(
        "${nameToken.lexeme} is a void element and cannot be used in a close element tag",
        nameToken.lexeme,
        nameToken.offset,
      ));
    }

    //TODO: Max: remove entirely
    @deprecated
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
  StandaloneTemplateAst parseElement(
      NgToken beginToken, Queue<String> tagStack) {
    // Parse the element identifier.
    final nameToken = _reader.expect(NgTokenType.elementIdentifier);
    //TODO: do we want to allow trailing spaces in content/template tags?
    if (nameToken.lexeme == 'ng-content') {
      return parseEmbeddedContent(beginToken, nameToken);
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
            exceptionHandler.handle(new AngularParserException(
              'Already found an *-directive, limit 1 per element, but also '
                  'found ${decoratorAst.sourceSpan.highlight()}',
              decoratorAst.value,
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

    // TODO: Potentially check if openElementEndVoid is being used on a
    // TODO: non-valid element name

    // If not a void element, look for closing tag OR child nodes.
    if (!isVoidElement && nextToken.type != NgTokenType.openElementEndVoid) {
      tagStack.addFirst(nameToken.lexeme);
      var closingTagFound = false;

      while (!closingTagFound) {
        nextToken = _reader.next();

        if (nextToken == null) {
          exceptionHandler.handle(new AngularParserException(
            "Expected close element for '${nameToken.lexeme}'",
            nameToken.lexeme,
            nameToken.offset,
          ));
          closeElementAst = new CloseElementAst(nameToken.lexeme);
          closingTagFound = true;
        } else if (nextToken.type == NgTokenType.closeElementStart) {
          var closeNameToken = _reader.peek();

          if (closeNameToken.lexeme != nameToken.lexeme) {
            // Found a closing tag, but not matching current [ElementAst].
            exceptionHandler.handle(new AngularParserException(
              'Invalid closing tag: $closeNameToken (expected $nameToken)',
              closeNameToken.lexeme,
              closeNameToken.offset,
            ));
            if (tagStack.contains(closeNameToken.lexeme)) {
              // If the closing tag is in the seen [ElementAst] stack,
              // leave it alone. Instead create a synthetic close.
              _reader.putBack(nextToken);
              closeElementAst = new CloseElementAst(nameToken.lexeme);
              closingTagFound = true;
            } else {
              // If the closing tag is not in the stack, create a synthetic
              // [ElementAst] to pair the dangling close and add as child.
              exceptionHandler.handle(new AngularParserException(
                'Dangling closing tag: $closeNameToken',
                closeNameToken.lexeme,
                closeNameToken.offset,
              ));
              childNodes.add(_handleDanglingCloseElement(nextToken));
            }
          } else {
            closeElementAst = parseCloseElement(nextToken);
            closingTagFound = true;
          }
        } else {
          TemplateAst childAst = parseStandalone(nextToken, tagStack);
          childNodes.add(childAst);
        }
      }
      tagStack.removeFirst();
    }

    final element = new ElementAst.parsed(
      _source,
      beginToken,
      nameToken,
      endToken,
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
  EmbeddedContentAst parseEmbeddedContent(
      NgToken beginToken, NgToken elementIdentifierToken) {
    NgToken selectToken, equalSign, endToken;
    NgAttributeValueToken valueToken;
    bool selectAttributeFound = false;
    CloseElementAst closeElementAst;

    // Ensure that ng-content has only 'select' attribute, if any. Also
    // catch for multiple 'select'; if multiple, accept the first one seen.
    while (_reader.peekType() == NgTokenType.beforeElementDecorator) {
      var beforeElementDecorator = _reader.next();
      var nextToken = _reader.next();

      if (nextToken.type != NgTokenType.elementDecorator ||
          nextToken.lexeme != 'select') {
        var errorString = _accumulateInvalidNgContentDecoratorValue(
            beforeElementDecorator, nextToken);
        var e = new AngularParserException(
          'Only "select" is a valid attribute in <ng-content>, got '
              '"${errorString}"',
          errorString,
          beforeElementDecorator.offset,
        );
        exceptionHandler.handle(e);
      } else {
        if (selectAttributeFound) {
          var errorString = _accumulateInvalidNgContentDecoratorValue(
              beforeElementDecorator, nextToken);
          var e = new AngularParserException(
            'Only one "select" attribute can exist in <ng-content>, got '
                'duplicate ${errorString}',
            errorString,
            beforeElementDecorator.offset,
          );
          exceptionHandler.handle(e);
        } else {
          selectAttributeFound = true;
          selectToken = nextToken;
          _consumeWhitespaces();
          equalSign = _reader.next();
          _consumeWhitespaces();
          valueToken = _reader.next();
        }
      }
    }

    _consumeWhitespaces();

    // Ensure closed by '>' and not '/>'.
    endToken = _reader.next();
    if (endToken.type == NgTokenType.openElementEndVoid) {
      var e = new AngularParserException(
        '"ng-content" is not a valid void element',
        endToken.lexeme,
        endToken.offset,
      );
      exceptionHandler.handle(e);
      endToken = new NgToken.generateErrorSynthetic(
        endToken.offset,
        NgTokenType.openElementEnd,
      );
    }

    // Ensure closing </ng-content> exists.
    if (_reader.peekType() != NgTokenType.closeElementStart) {
      var e = new AngularParserException(
        'Expected closing tag for "ng-content".',
        _reader.peek().lexeme,
        _reader.peek().offset,
      );
      exceptionHandler.handle(e);
      closeElementAst = new CloseElementAst('ng-content');
    } else {
      var closeElementStart = _reader.next();
      var closeElementName = _reader.peek().lexeme;
      var closeElementOffset = _reader.peek().offset;

      if (closeElementName != 'ng-content') {
        var e = new AngularParserException(
          'Expected closing tag to match "ng-content", instead got $closeElementName',
          closeElementName,
          closeElementOffset,
        );
        exceptionHandler.handle(e);
        _reader.putBack(closeElementStart);
        closeElementAst = new CloseElementAst('ng-content');
      } else {
        closeElementAst = parseCloseElement(closeElementStart);
      }
    }
    return new EmbeddedContentAst.parsed(
      _source,
      beginToken,
      elementIdentifierToken,
      endToken,
      closeElementAst,
      selectToken,
      equalSign,
      valueToken,
    );
  }

  /// Helper function that accumulates all parts of attribute-value variant
  /// and returns it as a single string. Should be used to gather any
  /// non-'select' decorator. Consumes all necessary erroneous tokens.
  String _accumulateInvalidNgContentDecoratorValue(
      NgToken beforeElementDecorator, NgToken nextToken) {
    var sb = new StringBuffer();
    sb.write(beforeElementDecorator.lexeme);
    sb.write(nextToken.lexeme);

    if (nextToken.type == NgTokenType.bananaPrefix ||
        nextToken.type == NgTokenType.eventPrefix ||
        nextToken.type == NgTokenType.propertyPrefix) {
      sb.write(_reader.next()); // Decorator
      sb.write(_reader.next()); // Suffix
    } else if (nextToken.type == NgTokenType.templatePrefix ||
        nextToken.type == NgTokenType.referencePrefix) {
      sb.write(_reader.next()); // Decorator
    }
    _consumeWhitespaces();
    if (_reader.peekType() == NgTokenType.beforeElementDecoratorValue) {
      sb.write(_reader.next()); // '=' sign
    }
    _consumeWhitespaces();
    sb.write(_reader.next()); //Attribute value
    return sb.toString();
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
    ExpressionAst expressionAst = parseExpression(valueToken?.lexeme);
    return new InterpolationAst.parsed(
      _source,
      beginToken,
      valueToken.lexeme,
      expressionAst,
      endToken,
    );
  }

  /// Returns and parses a top-level AST structure.
  StandaloneTemplateAst parseStandalone(
    NgToken token, [
    Queue<String> tagStack,
  ]) {
    tagStack = tagStack ?? new Queue();
    switch (token.type) {
      case NgTokenType.commentStart:
        return parseComment(token);
      case NgTokenType.openElementStart:
        return parseElement(token, tagStack);
      case NgTokenType.interpolationStart:
        return parseInterpolation(token);
      case NgTokenType.text:
        return parseText(token);
      // Dangling close tag. If error recovery is enabled, returns
      // a synthetic open with the dangling close. If not enabled,
      // simply throws error.
      case NgTokenType.closeElementStart:
        exceptionHandler.handle(new AngularParserException(
          "Close element cannot exist before matching open element",
          token.lexeme,
          token.offset,
        ));
        return _handleDanglingCloseElement(token);
      default:
        _reader.error('Expected standalone token, got ${token.type}');
        return null;
    }
  }

  /// Given a dangling [CloseElementAst], creates a synthetic [ElementAst]
  /// and links the dangling [CloseElementAst] to it, and returns the
  /// synthetic [ElementAst].
  StandaloneTemplateAst _handleDanglingCloseElement(NgToken closeStart) {
    var closeElementAst = parseCloseElement(closeStart);
    var elementName = closeElementAst.name;

    if (elementName == 'ng-content') {
      var synthContentAst = new EmbeddedContentAst();
      synthContentAst.closeComplement = closeElementAst;
      return synthContentAst;
    }
    var synthElementAst = new ElementAst(closeElementAst.name, closeElementAst);
    return synthElementAst;
  }

  void _consumeWhitespaces() {
    while (_reader.peekType() != null &&
        _reader.peekType == NgSimpleTokenType.whitespace) {
      _reader.next();
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
