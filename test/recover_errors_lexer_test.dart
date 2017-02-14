// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/angular_ast.dart';
import 'package:test/test.dart';

void main() {
  // Returns the html parsed as a series of tokens.
  Iterable<NgToken> tokenize(String html) =>
      const NgLexer().tokenize(html, recoverError: true);

  // Returns the html parsed as a series of tokens, then back to html.
  String untokenize(Iterable<NgToken> tokens) => tokens
      .fold(new StringBuffer(), (buffer, token) => buffer..write(token.lexeme))
      .toString();

  test('should drop: unexpected ! following afterElementDecorator', () {
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
    expect(untokenize(results), '<div blah #someRef>');
  });

  test('should resolve: unexpected * following afterElemnetDecorator', () {
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
    expect(untokenize(results), '<div blah *myTemp>');
  });
}
