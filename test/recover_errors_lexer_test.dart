// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/angular_ast.dart';
import 'package:test/test.dart';

// TODO: add error listener to accumulate errors and test

void main() {
  // Returns the html parsed as a series of tokens.
  AccumulatingExceptionHandler exceptionHandler =
      new AccumulatingExceptionHandler();
  Iterable<NgToken> tokenize(String html) {
    exceptionHandler.exceptions.clear();
    return const NgLexer().tokenize(html, exceptionHandler, recoverError: true);
  }

  // Returns the html parsed as a series of tokens, then back to html.
  String untokenize(Iterable<NgToken> tokens) => tokens
      .fold(new StringBuffer(), (buffer, token) => buffer..write(token.lexeme))
      .toString();

  test('should resolve: unexpected EOF following afterComment', () {
    List<NgToken> results = tokenize('<!-- some comment ');
    expect(
      results,
      [
        new NgToken.commentStart(0),
        new NgToken.commentValue(4, ' some comment '),
        new NgToken.commentEnd(18)
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '');
    expect(e.offset, 18);
  });

  test('should resolve: unexpected ! following afterElementDecorator', () {
    List<NgToken> results = tokenize('<div blah!></div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.openElementEnd(10),
        new NgToken.closeElementStart(11),
        new NgToken.elementIdentifier(13, 'div'),
        new NgToken.closeElementEnd(16),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '!');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah></div>');
  });

  test('should resolve: unexpected [ following afterElementDecorator', () {
    List<NgToken> results = tokenize('<div blah[someProp]="x"></div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.beforeElementDecorator(9, ' '), //Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.propertyPrefix(9),
          new NgToken.elementDecorator(10, 'someProp'),
          new NgToken.propertySuffix(18),
        ),
        new NgToken.beforeElementDecoratorValue(19),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(20),
          new NgToken.elementDecoratorValue(21, 'x'),
          new NgToken.doubleQuote(22),
        ),
        new NgToken.openElementEnd(23),
        new NgToken.closeElementStart(24),
        new NgToken.elementIdentifier(26, 'div'),
        new NgToken.closeElementEnd(29),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '[');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah [someProp]="x"></div>');
  });

  test('should resolve: unexpected ] following afterElementDecorator', () {
    List<NgToken> results = tokenize('<div blah]="x"></div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.beforeElementDecorator(9, ' '), //Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.propertyPrefix(9), //Synthetic
          new NgToken.elementDecorator(9, ''), //Synthetic
          new NgToken.propertySuffix(9),
        ),
        new NgToken.beforeElementDecoratorValue(10),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(11),
          new NgToken.elementDecoratorValue(12, 'x'),
          new NgToken.doubleQuote(13),
        ),
        new NgToken.openElementEnd(14),
        new NgToken.closeElementStart(15),
        new NgToken.elementIdentifier(17, 'div'),
        new NgToken.closeElementEnd(20),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ']');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah []="x"></div>');
  });

  test('should resolve: unexpected ( following afterElementDecorator', () {
    List<NgToken> results = tokenize('<div blah(someProp)="x"></div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.beforeElementDecorator(9, ' '), //Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.eventPrefix(9),
          new NgToken.elementDecorator(10, 'someProp'),
          new NgToken.eventSuffix(18),
        ),
        new NgToken.beforeElementDecoratorValue(19),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(20),
          new NgToken.elementDecoratorValue(21, 'x'),
          new NgToken.doubleQuote(22),
        ),
        new NgToken.openElementEnd(23),
        new NgToken.closeElementStart(24),
        new NgToken.elementIdentifier(26, 'div'),
        new NgToken.closeElementEnd(29),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '(');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah (someProp)="x"></div>');
  });

  test('should resolve: unexpected ) following afterElementDecorator', () {
    List<NgToken> results = tokenize('<div blah)="x"></div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.beforeElementDecorator(9, ' '), //Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.eventPrefix(9), //Synthetic
          new NgToken.elementDecorator(9, ''), //Synthetic
          new NgToken.eventSuffix(9),
        ),
        new NgToken.beforeElementDecoratorValue(10),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(11),
          new NgToken.elementDecoratorValue(12, 'x'),
          new NgToken.doubleQuote(13),
        ),
        new NgToken.openElementEnd(14),
        new NgToken.closeElementStart(15),
        new NgToken.elementIdentifier(17, 'div'),
        new NgToken.closeElementEnd(20),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ')');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah ()="x"></div>');
  });

  test('should resolve: unexpected <!-- following afterElementDecorator', () {
    List<NgToken> results = tokenize('<div blah<!-- comment -->');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.openElementEnd(9), // Synthetic
        new NgToken.commentStart(9),
        new NgToken.commentValue(13, ' comment '),
        new NgToken.commentEnd(22),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '<!--');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah><!-- comment -->');
  });

  test('should resolve: unexpected < following afterElementDecorator', () {
    List<NgToken> results = tokenize('<div blah<span>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.openElementEnd(9), // Synthetic
        new NgToken.openElementStart(9),
        new NgToken.elementIdentifier(10, 'span'),
        new NgToken.openElementEnd(14),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '<');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah><span>');
  });

  test('should resolve: unexpected EOF following afterElementDecorator', () {
    List<NgToken> results = tokenize('<div blah');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.openElementEnd(9), // Synthetic
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah>');
  });

  test('should resolve: unexpected # following afterElementDecorator', () {
    List<NgToken> results = tokenize('<div blah#someRef>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.beforeElementDecorator(9, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.referencePrefix(9),
          new NgToken.elementDecorator(10, 'someRef'),
          null,
        ),
        new NgToken.openElementEnd(17)
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '#');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah #someRef>');
  });

  test('should resolve: unexpected * following afterElementDecorator', () {
    List<NgToken> results = tokenize('<div blah*myTemp>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.beforeElementDecorator(9, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.templatePrefix(9),
          new NgToken.elementDecorator(10, 'myTemp'),
          null,
        ),
        new NgToken.openElementEnd(16)
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '*');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah *myTemp>');
  });

  // TODO: danging prefix tokens tests

  test('should resolve: unexpected quotedText following afterElementDecorator',
      () {
    List<NgToken> results = tokenize('<div blah"quotedText">');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.beforeElementDecoratorValue(9), // Synthetic
        new NgAttributeValueToken.generate(
            new NgToken.doubleQuote(9),
            new NgToken.elementDecoratorValue(10, 'quotedText'),
            new NgToken.doubleQuote(20)),
        new NgToken.openElementEnd(21),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '"quotedText"');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah="quotedText">');
  });

  test('should resolve: unexpected character following afterElementDecorator',
      () {
    List<NgToken> results = tokenize('<div blah@>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.openElementEnd(10),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '@');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah>');
  });

  test('should resolve: unexpected ! following afterElementDecoratorValue', () {
    List<NgToken> results = tokenize('<div someName="someValue"!>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.openElementEnd(26),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '!');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue">');
  });

  test('should resolve: unexpected [ following afterElementDecoratorValue', () {
    List<NgToken> results = tokenize('<div someName="someValue"[someProp]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.beforeElementDecorator(25, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.propertyPrefix(25),
          new NgToken.elementDecorator(26, 'someProp'),
          new NgToken.propertySuffix(34),
        ),
        new NgToken.openElementEnd(35),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '[');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue" [someProp]>');
  });

  test('should resolve: unexpected ] following afterElementDecoratorValue', () {
    List<NgToken> results = tokenize('<div someName="someValue"]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.beforeElementDecorator(25, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.propertyPrefix(25), // Synthetic
          new NgToken.elementDecorator(25, ''), // Synthetic
          new NgToken.propertySuffix(25),
        ),
        new NgToken.openElementEnd(26),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ']');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue" []>');
  });

  test('should resolve: unexpected ( following afterElementDecoratorValue', () {
    List<NgToken> results = tokenize('<div someName="someValue"(someEvent)>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.beforeElementDecorator(25, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.eventPrefix(25),
          new NgToken.elementDecorator(26, 'someEvent'),
          new NgToken.eventSuffix(35),
        ),
        new NgToken.openElementEnd(36),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '(');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue" (someEvent)>');
  });

  test('should resolve: unexpected ) following afterElementDecoratorValue', () {
    List<NgToken> results = tokenize('<div someName="someValue")>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.beforeElementDecorator(25, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.eventPrefix(25), // Synthetic
          new NgToken.elementDecorator(25, ''), // Synthetic
          new NgToken.eventSuffix(25),
        ),
        new NgToken.openElementEnd(26),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ')');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue" ()>');
  });

  test('should resolve: unexpected <!-- following afterElementDecoratorValue',
      () {
    List<NgToken> results =
        tokenize('<div someName="someValue"<!-- comment -->');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.openElementEnd(25), // Synthetic
        new NgToken.commentStart(25),
        new NgToken.commentValue(29, ' comment '),
        new NgToken.commentEnd(38),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '<!--');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue"><!-- comment -->');
  });

  test('should resolve: unexpected - following afterElementDecoratorValue', () {
    List<NgToken> results = tokenize('<div someName="someValue"->');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.openElementEnd(26),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '-');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue">');
  });

  test('should resolve: unexpected < following afterElementDecoratorValue', () {
    List<NgToken> results = tokenize('<div someName="someValue"<span>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.openElementEnd(25), // Synthetic
        new NgToken.openElementStart(25),
        new NgToken.elementIdentifier(26, 'span'),
        new NgToken.openElementEnd(30),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '<');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue"><span>');
  });

  test('should resolve: unexpected EOF following afterElementDecoratorValue',
      () {
    List<NgToken> results = tokenize('<div someName="someValue"');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.openElementEnd(25), // Synthetic
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue">');
  });

  test('should resolve: unexpected = following afterElementDecoratorValue', () {
    List<NgToken> results = tokenize('<div someName="someValue"="otherValue">');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.beforeElementDecorator(25, ' '), // Synthetic
        new NgToken.elementDecorator(25, ''), // Synthetic
        new NgToken.beforeElementDecoratorValue(25),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(26),
          new NgToken.elementDecoratorValue(27, 'otherValue'),
          new NgToken.doubleQuote(37),
        ),
        new NgToken.openElementEnd(38),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '=');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue" ="otherValue">');
  });

  test('should resolve: unexpected * following afterElementDecoratorValue', () {
    List<NgToken> results = tokenize('<div someName="someValue"*someTemp>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.beforeElementDecorator(25, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.templatePrefix(25),
          new NgToken.elementDecorator(26, 'someTemp'),
          null,
        ),
        new NgToken.openElementEnd(34),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '*');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue" *someTemp>');
  });

  test('should resolve: unexpected # following afterElementDecoratorValue', () {
    List<NgToken> results = tokenize('<div someName="someValue"#someRef>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.beforeElementDecorator(25, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.referencePrefix(25),
          new NgToken.elementDecorator(26, 'someRef'),
          null,
        ),
        new NgToken.openElementEnd(33),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '#');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue" #someRef>');
  });

  test(
      'should resolve: unexpected identifier following afterElementDecoratorValue',
      () {
    List<NgToken> results = tokenize('<div someName="someValue"someOther>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.beforeElementDecorator(25, ' '), // Synthetic
        new NgToken.elementDecorator(25, 'someOther'),
        new NgToken.openElementEnd(34),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, 'someOther');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue" someOther>');
  });

  test('should resolve: unexpected . following afterElementDecoratorValue', () {
    List<NgToken> results = tokenize('<div someName="someValue".>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.openElementEnd(26),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '.');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue">');
  });

  test(
      'should resolve: unexpected quotedText following afterElementDecoratorValue',
      () {
    List<NgToken> results = tokenize('<div someName="someValue""quotedText">');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.beforeElementDecorator(25, ' '), // Synthetic
        new NgToken.elementDecorator(25, ''), // Synthetic
        new NgToken.beforeElementDecoratorValue(25), // Synthetic
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(25),
          new NgToken.elementDecoratorValue(26, 'quotedText'),
          new NgToken.doubleQuote(36),
        ),
        new NgToken.openElementEnd(37),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '"quotedText"');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue" ="quotedText">');
  });

  test('should resolve: unexpected char following afterElementDecoratorValue',
      () {
    List<NgToken> results = tokenize('<div someName="someValue"@>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.openElementEnd(26),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '@');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue">');
  });

  test('should resolve: unexpected ! following elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div!>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'someName'),
        new NgToken.beforeElementDecoratorValue(13),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(14),
          new NgToken.elementDecoratorValue(15, 'someValue'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.openElementEnd(26),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '@');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue">');
  });
}
