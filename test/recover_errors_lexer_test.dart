// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/angular_ast.dart';
import 'package:test/test.dart';

RecoveringExceptionHandler exceptionHandler = new RecoveringExceptionHandler();

Iterable<NgToken> tokenize(String html) {
  exceptionHandler.exceptions.clear();
  return const NgLexer().tokenize(html, exceptionHandler, recoverError: true);
}

String untokenize(Iterable<NgToken> tokens) => tokens
    .fold(new StringBuffer(), (buffer, token) => buffer..write(token.lexeme))
    .toString();

void main() {
  afterComment();
  afterElementDecorator();
  afterElementDecoratorValue();
  elementDecorator();
  elementDecoratorValue();
  elementIdentifierOpen();
  scanAfterElementIdentifierOpen();
}

void afterComment() {
  test('should resolve: unexpected EOF in afterComment', () {
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
}

void afterElementDecorator() {
  test('should resolve: unexpected ! in afterElementDecorator', () {
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

  test('should resolve: unexpected [ in afterElementDecorator', () {
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

  test('should resolve: unexpected ] in afterElementDecorator', () {
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

  test('should resolve: unexpected ( in afterElementDecorator', () {
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

  test('should resolve: unexpected ) in afterElementDecorator', () {
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

  test('should resolve: unexpected [( in afterElementDecorator', () {
    List<NgToken> results = tokenize('<div blah[(someBnna)]="x"></div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.beforeElementDecorator(9, ' '), //Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.bananaPrefix(9),
          new NgToken.elementDecorator(11, 'someBnna'),
          new NgToken.bananaSuffix(19),
        ),
        new NgToken.beforeElementDecoratorValue(21),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(22),
          new NgToken.elementDecoratorValue(23, 'x'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.openElementEnd(25),
        new NgToken.closeElementStart(26),
        new NgToken.elementIdentifier(28, 'div'),
        new NgToken.closeElementEnd(31),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '[(');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah [(someBnna)]="x"></div>');
  });

  test('should resolve: unexpected )] in afterElementDecorator', () {
    List<NgToken> results = tokenize('<div bnna)]="x"></div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'bnna'),
        new NgToken.beforeElementDecorator(9, ' '), //Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.bananaPrefix(9), //Synthetic
          new NgToken.elementDecorator(9, ''), //Synthetic
          new NgToken.bananaSuffix(9),
        ),
        new NgToken.beforeElementDecoratorValue(11),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(12),
          new NgToken.elementDecoratorValue(13, 'x'),
          new NgToken.doubleQuote(14),
        ),
        new NgToken.openElementEnd(15),
        new NgToken.closeElementStart(16),
        new NgToken.elementIdentifier(18, 'div'),
        new NgToken.closeElementEnd(21),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ')]');
    expect(e.offset, 9);

    expect(untokenize(results), '<div bnna [()]="x"></div>');
  });

  test('should resolve: unexpected <!-- in afterElementDecorator', () {
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

  test('should resolve: unexpected < in afterElementDecorator', () {
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

  test('should resolve: unexpected </ in afterElementDecorator', () {
    List<NgToken> results = tokenize('<div blah</div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.openElementEnd(9), // Synthetic
        new NgToken.closeElementStart(9),
        new NgToken.elementIdentifier(11, 'div'),
        new NgToken.closeElementEnd(14),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '</');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah></div>');
  });

  test('should resolve: unexpected EOF in afterElementDecorator', () {
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

  test('should resolve: unexpected # in afterElementDecorator', () {
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

  test('should resolve: unexpected * in afterElementDecorator', () {
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

  test('should resolve: unexpected quotedText in afterElementDecorator', () {
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

  test('should resolve: unexpected character in afterElementDecorator', () {
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
}

void afterElementDecoratorValue() {
  afterComment();
  afterElementDecorator();
  test('should resolve: unexpected ! in afterElementDecorator', () {
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

  test('should resolve: unexpected [ in afterElementDecorator', () {
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

  test('should resolve: unexpected ] in afterElementDecorator', () {
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

  test('should resolve: unexpected ( in afterElementDecorator', () {
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

  test('should resolve: unexpected ) in afterElementDecorator', () {
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

  test('should resolve: unexpected [( in afterElementDecorator', () {
    List<NgToken> results = tokenize('<div blah[(someBnna)]="x"></div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.beforeElementDecorator(9, ' '), //Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.bananaPrefix(9),
          new NgToken.elementDecorator(11, 'someBnna'),
          new NgToken.bananaSuffix(19),
        ),
        new NgToken.beforeElementDecoratorValue(21),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(22),
          new NgToken.elementDecoratorValue(23, 'x'),
          new NgToken.doubleQuote(24),
        ),
        new NgToken.openElementEnd(25),
        new NgToken.closeElementStart(26),
        new NgToken.elementIdentifier(28, 'div'),
        new NgToken.closeElementEnd(31),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '[(');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah [(someBnna)]="x"></div>');
  });

  test('should resolve: unexpected )] in afterElementDecorator', () {
    List<NgToken> results = tokenize('<div bnna)]="x"></div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'bnna'),
        new NgToken.beforeElementDecorator(9, ' '), //Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.bananaPrefix(9), //Synthetic
          new NgToken.elementDecorator(9, ''), //Synthetic
          new NgToken.bananaSuffix(9),
        ),
        new NgToken.beforeElementDecoratorValue(11),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(12),
          new NgToken.elementDecoratorValue(13, 'x'),
          new NgToken.doubleQuote(14),
        ),
        new NgToken.openElementEnd(15),
        new NgToken.closeElementStart(16),
        new NgToken.elementIdentifier(18, 'div'),
        new NgToken.closeElementEnd(21),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ')]');
    expect(e.offset, 9);

    expect(untokenize(results), '<div bnna [()]="x"></div>');
  });

  test('should resolve: unexpected <!-- in afterElementDecorator', () {
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

  test('should resolve: unexpected < in afterElementDecorator', () {
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

  test('should resolve: unexpected </ in afterElementDecorator', () {
    List<NgToken> results = tokenize('<div blah</div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'blah'),
        new NgToken.openElementEnd(9), // Synthetic
        new NgToken.closeElementStart(9),
        new NgToken.elementIdentifier(11, 'div'),
        new NgToken.closeElementEnd(14),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '</');
    expect(e.offset, 9);

    expect(untokenize(results), '<div blah></div>');
  });

  test('should resolve: unexpected EOF in afterElementDecorator', () {
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

  test('should resolve: unexpected # in afterElementDecorator', () {
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

  test('should resolve: unexpected * in afterElementDecorator', () {
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

  test('should resolve: unexpected quotedText in afterElementDecorator', () {
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

  test('should resolve: unexpected character in afterElementDecorator', () {
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

  test('should resolve: unexpected ! in afterElementDecoratorValue', () {
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

  test('should resolve: unexpected [ in afterElementDecoratorValue', () {
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

  test('should resolve: unexpected ] in afterElementDecoratorValue', () {
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

  test('should resolve: unexpected ( in afterElementDecoratorValue', () {
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

  test('should resolve: unexpected ) in afterElementDecoratorValue', () {
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

  test('should resolve: unexpected [( in afterElementDecoratorValue', () {
    List<NgToken> results = tokenize('<div someName="someValue"[(someEvent)]>');
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
          new NgToken.bananaPrefix(25),
          new NgToken.elementDecorator(27, 'someEvent'),
          new NgToken.bananaSuffix(36),
        ),
        new NgToken.openElementEnd(38),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '[(');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue" [(someEvent)]>');
  });

  test('should resolve: unexpected )] in afterElementDecoratorValue', () {
    List<NgToken> results = tokenize('<div someName="someValue")]>');
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
          new NgToken.bananaPrefix(25), // Synthetic
          new NgToken.elementDecorator(25, ''), // Synthetic
          new NgToken.bananaSuffix(25),
        ),
        new NgToken.openElementEnd(27),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ')]');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue" [()]>');
  });

  test('should resolve: unexpected <!-- in afterElementDecoratorValue', () {
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

  test('should resolve: unexpected - in afterElementDecoratorValue', () {
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

  test('should resolve: unexpected < in afterElementDecoratorValue', () {
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

  test('should resolve: unexpected </ in afterElementDecoratorValue', () {
    List<NgToken> results = tokenize('<div someName="someValue"</div>');
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
        new NgToken.closeElementStart(25),
        new NgToken.elementIdentifier(27, 'div'),
        new NgToken.closeElementEnd(30),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '</');
    expect(e.offset, 25);

    expect(untokenize(results), '<div someName="someValue"></div>');
  });

  test('should resolve: unexpected EOF in afterElementDecoratorValue', () {
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

  test('should resolve: unexpected = in afterElementDecoratorValue', () {
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

  test('should resolve: unexpected * in afterElementDecoratorValue', () {
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

  test('should resolve: unexpected # in afterElementDecoratorValue', () {
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

  test('should resolve: unexpected identifier in afterElementDecoratorValue',
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

  test('should resolve: unexpected . in afterElementDecoratorValue', () {
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

  test('should resolve: unexpected quotedText in afterElementDecoratorValue',
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

  test('should resolve: unexpected char in afterElementDecoratorValue', () {
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
}

void elementDecorator() {
  test('should resolve: unexpected ] in elementDecorator', () {
    List<NgToken> results = tokenize('<div ]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgSpecialAttributeToken.generate(
          new NgToken.propertyPrefix(5), // Synthetic
          new NgToken.elementDecorator(5, ''), // Synthetic
          new NgToken.propertySuffix(5),
        ),
        new NgToken.openElementEnd(6)
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ']');
    expect(e.offset, 5);

    expect(untokenize(results), '<div []>');
  });

  test('should resolve: unexpected ) in elementDecorator', () {
    List<NgToken> results = tokenize('<div )>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgSpecialAttributeToken.generate(
          new NgToken.eventPrefix(5), // Synthetic
          new NgToken.elementDecorator(5, ''), // Synthetic
          new NgToken.eventSuffix(5),
        ),
        new NgToken.openElementEnd(6)
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ')');
    expect(e.offset, 5);

    expect(untokenize(results), '<div ()>');
  });

  test('should resolve: unexpected )] in elementDecorator', () {
    List<NgToken> results = tokenize('<div )]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgSpecialAttributeToken.generate(
          new NgToken.bananaPrefix(5), // Synthetic
          new NgToken.elementDecorator(5, ''), // Synthetic
          new NgToken.bananaSuffix(5),
        ),
        new NgToken.openElementEnd(7)
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ')]');
    expect(e.offset, 5);

    expect(untokenize(results), '<div [()]>');
  });

  test('should resolve: unexpected <!-- in elementDecorator', () {
    List<NgToken> results = tokenize('<div <!-- comment -->');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, ''), // Synthetic
        new NgToken.openElementEnd(5), // Synthetic
        new NgToken.commentStart(5),
        new NgToken.commentValue(9, ' comment '),
        new NgToken.commentEnd(18),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '<!--');
    expect(e.offset, 5);

    expect(untokenize(results), '<div ><!-- comment -->');
  });

  test('should resolve: unexpected < in elementDecorator', () {
    List<NgToken> results = tokenize('<div <span>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, ''), // Synthetic
        new NgToken.openElementEnd(5), // Synthetic
        new NgToken.openElementStart(5),
        new NgToken.elementIdentifier(6, 'span'),
        new NgToken.openElementEnd(10),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '<');
    expect(e.offset, 5);

    expect(untokenize(results), '<div ><span>');
  });

  test('should resolve: unexpected </ in elementDecorator', () {
    List<NgToken> results = tokenize('<div </div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, ''), // Synthetic
        new NgToken.openElementEnd(5), // Synthetic
        new NgToken.closeElementStart(5),
        new NgToken.elementIdentifier(7, 'div'),
        new NgToken.closeElementEnd(10),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '</');
    expect(e.offset, 5);

    expect(untokenize(results), '<div ></div>');
  });

  test('should resolve: unexpected EOF in elementDecorator', () {
    List<NgToken> results = tokenize('<div ');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, ''), // Synthetic
        new NgToken.openElementEnd(5), // Synthetic
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '');
    expect(e.offset, 5);

    expect(untokenize(results), '<div >');
  });

  test('should resolve: unexpected - in elementDecorator', () {
    List<NgToken> results = tokenize('<div ->');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, ''), // Synthetic
        new NgToken.openElementEnd(6),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '-');
    expect(e.offset, 5);

    expect(untokenize(results), '<div >');
  });

  test('should resolve: unexpected char in elementDecorator', () {
    List<NgToken> results = tokenize('<div @>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, ''), // Synthetic
        new NgToken.openElementEnd(6),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '@');
    expect(e.offset, 5);

    expect(untokenize(results), '<div >');
  });

  test('should resolve: unexpected char in elementDecorator', () {
    List<NgToken> results = tokenize('<div .>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, ''), // Synthetic
        new NgToken.openElementEnd(6),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '.');
    expect(e.offset, 5);

    expect(untokenize(results), '<div >');
  });

  test('should resolve: unexpected quotedText in elementDecorator', () {
    List<NgToken> results = tokenize('<div "blah">');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, ''), // Synthetic
        new NgToken.beforeElementDecoratorValue(5), // Synthetic
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(5),
          new NgToken.elementDecoratorValue(6, 'blah'),
          new NgToken.doubleQuote(10),
        ),
        new NgToken.openElementEnd(11),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '"blah"');
    expect(e.offset, 5);

    expect(untokenize(results), '<div ="blah">');
  });

  test('should resolve: unexpected = in elementDecorator', () {
    List<NgToken> results = tokenize('<div ="blah">');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, ''), //Synthetic
        new NgToken.beforeElementDecoratorValue(5),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(6),
          new NgToken.elementDecoratorValue(7, 'blah'),
          new NgToken.doubleQuote(11),
        ),
        new NgToken.openElementEnd(12),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '=');
    expect(e.offset, 5);

    expect(untokenize(results), '<div ="blah">');
  });
}

void elementDecoratorValue() {
  test('should resolve: unexpected ! in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=!>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(11), // Synthetic
          new NgToken.elementDecoratorValue(11, ''), // Synthetic
          new NgToken.doubleQuote(11), // Synthetic
        ),
        new NgToken.openElementEnd(11),
      ],
    );
    expect(exceptionHandler.exceptions.length, 2);
    FormatException e1 = exceptionHandler.exceptions[0];
    expect(e1.source, '!');
    expect(e1.offset, 10);
    FormatException e2 = exceptionHandler.exceptions[1];
    expect(e2.source, '>');
    expect(e2.offset, 11);

    expect(untokenize(results), '<div attr="">');
  });

  test('should resolve: unexpected - in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=->');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(11), // Synthetic
          new NgToken.elementDecoratorValue(11, ''), // Synthetic
          new NgToken.doubleQuote(11), // Synthetic
        ),
        new NgToken.openElementEnd(11),
      ],
    );
    expect(exceptionHandler.exceptions.length, 2);
    FormatException e1 = exceptionHandler.exceptions[0];
    expect(e1.source, '-');
    expect(e1.offset, 10);
    FormatException e2 = exceptionHandler.exceptions[1];
    expect(e2.source, '>');
    expect(e2.offset, 11);

    expect(untokenize(results), '<div attr="">');
  });

  test('should resolve: unexpected char in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=@>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(11), // Synthetic
          new NgToken.elementDecoratorValue(11, ''), // Synthetic
          new NgToken.doubleQuote(11), // Synthetic
        ),
        new NgToken.openElementEnd(11),
      ],
    );
    expect(exceptionHandler.exceptions.length, 2);
    FormatException e1 = exceptionHandler.exceptions[0];
    expect(e1.source, '@');
    expect(e1.offset, 10);
    FormatException e2 = exceptionHandler.exceptions[1];
    expect(e2.source, '>');
    expect(e2.offset, 11);

    expect(untokenize(results), '<div attr="">');
  });

  test('should resolve: unexpected . in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=.>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(11), // Synthetic
          new NgToken.elementDecoratorValue(11, ''), // Synthetic
          new NgToken.doubleQuote(11), // Synthetic
        ),
        new NgToken.openElementEnd(11),
      ],
    );
    expect(exceptionHandler.exceptions.length, 2);
    FormatException e1 = exceptionHandler.exceptions[0];
    expect(e1.source, '.');
    expect(e1.offset, 10);
    FormatException e2 = exceptionHandler.exceptions[1];
    expect(e2.source, '>');
    expect(e2.offset, 11);

    expect(untokenize(results), '<div attr="">');
  });

  test('should resolve: unexpected / in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=/ >');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgToken.whitespace(11, ' '),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(12), // Synthetic
          new NgToken.elementDecoratorValue(12, ''), // Synthetic
          new NgToken.doubleQuote(12), // Synthetic
        ),
        new NgToken.openElementEnd(12),
      ],
    );
    expect(exceptionHandler.exceptions.length, 2);
    FormatException e1 = exceptionHandler.exceptions[0];
    expect(e1.source, '/');
    expect(e1.offset, 10);
    FormatException e2 = exceptionHandler.exceptions[1];
    expect(e2.source, '>');
    expect(e2.offset, 12);

    expect(untokenize(results), '<div attr= "">');
  });

  test('should resolve: unexpected # in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=#someRef>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.beforeElementDecorator(10, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.referencePrefix(10),
          new NgToken.elementDecorator(11, 'someRef'),
        ),
        new NgToken.openElementEnd(18),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '#');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr="" #someRef>');
  });

  test('should resolve: unexpected * in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=*someTemp>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.beforeElementDecorator(10, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.templatePrefix(10),
          new NgToken.elementDecorator(11, 'someTemp'),
        ),
        new NgToken.openElementEnd(19),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '*');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr="" *someTemp>');
  });

  test('should resolve: unexpected identifier in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=blah>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.beforeElementDecorator(10, ' '), // Synthetic
        new NgToken.elementDecorator(10, 'blah'),
        new NgToken.openElementEnd(14),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, 'blah');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr="" blah>');
  });

  test('should resolve: unexpected [ in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=[someProp]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.beforeElementDecorator(10, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.propertyPrefix(10),
          new NgToken.elementDecorator(11, 'someProp'),
          new NgToken.propertySuffix(19),
        ),
        new NgToken.openElementEnd(20),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '[');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr="" [someProp]>');
  });

  test('should resolve: unexpected ] in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.beforeElementDecorator(10, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.propertyPrefix(10), // Synthetic
          new NgToken.elementDecorator(10, ''), // Synthetic
          new NgToken.propertySuffix(10),
        ),
        new NgToken.openElementEnd(11),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ']');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr="" []>');
  });

  test('should resolve: unexpected ( in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=(someEvnt)>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.beforeElementDecorator(10, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.eventPrefix(10),
          new NgToken.elementDecorator(11, 'someEvnt'),
          new NgToken.eventSuffix(19),
        ),
        new NgToken.openElementEnd(20),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '(');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr="" (someEvnt)>');
  });

  test('should resolve: unexpected ) in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=)>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.beforeElementDecorator(10, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.eventPrefix(10), // Synthetic
          new NgToken.elementDecorator(10, ''), // Synthetic
          new NgToken.eventSuffix(10),
        ),
        new NgToken.openElementEnd(11),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ')');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr="" ()>');
  });

  test('should resolve: unexpected [( in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=[(someBnna)]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.beforeElementDecorator(10, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.bananaPrefix(10),
          new NgToken.elementDecorator(12, 'someBnna'),
          new NgToken.bananaSuffix(20),
        ),
        new NgToken.openElementEnd(22),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '[(');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr="" [(someBnna)]>');
  });

  test('should resolve: unexpected )] in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=)]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.beforeElementDecorator(10, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.bananaPrefix(10), // Synthetic
          new NgToken.elementDecorator(10, ''), // Synthetic
          new NgToken.bananaSuffix(10),
        ),
        new NgToken.openElementEnd(12),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ')]');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr="" [()]>');
  });

  test('should resolve: unexpected <!-- in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=<!-- comment -->');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.openElementEnd(10), // Synthetic
        new NgToken.commentStart(10),
        new NgToken.commentValue(14, ' comment '),
        new NgToken.commentEnd(23)
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '<!--');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr=""><!-- comment -->');
  });

  test('should resolve: unexpected < in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=<span>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.openElementEnd(10), // Synthetic
        new NgToken.openElementStart(10),
        new NgToken.elementIdentifier(11, 'span'),
        new NgToken.openElementEnd(15),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '<');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr=""><span>');
  });

  test('should resolve: unexpected </ in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=</div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.openElementEnd(10), // Synthetic
        new NgToken.closeElementStart(10),
        new NgToken.elementIdentifier(12, 'div'),
        new NgToken.closeElementEnd(15),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '</');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr=""></div>');
  });

  test('should resolve: unexpected > in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.openElementEnd(10),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '>');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr="">');
  });

  test('should resolve: unexpected /> in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=/>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.openElementEndVoid(10),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '/>');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr=""/>');
  });

  test('should resolve: unexpected = in elementDecoratorValue', () {
    List<NgToken> results = tokenize('<div attr=="blah">');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '),
        new NgToken.elementDecorator(5, 'attr'),
        new NgToken.beforeElementDecoratorValue(9),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(10), // Synthetic
          new NgToken.elementDecoratorValue(10, ''), // Synthetic
          new NgToken.doubleQuote(10), // Synthetic
        ),
        new NgToken.beforeElementDecorator(10, ' '), // Synthetic
        new NgToken.elementDecorator(10, ''), // Synthetic
        new NgToken.beforeElementDecoratorValue(10),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(11),
          new NgToken.elementDecoratorValue(12, 'blah'),
          new NgToken.doubleQuote(16),
        ),
        new NgToken.openElementEnd(17),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '=');
    expect(e.offset, 10);

    expect(untokenize(results), '<div attr="" ="blah">');
  });
}

void elementIdentifierOpen() {
  test('should resolve: unexpected ! in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<!>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.openElementEnd(2),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '!');
    expect(e.offset, 1);

    expect(untokenize(results), '<>');
  });

  test('should resolve: unexpected - in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<->');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.openElementEnd(2),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '-');
    expect(e.offset, 1);

    expect(untokenize(results), '<>');
  });

  test('should resolve: unexpected . in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<.>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.openElementEnd(2),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '.');
    expect(e.offset, 1);

    expect(untokenize(results), '<>');
  });

  test('should resolve: unexpected [ in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<[someProp]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.beforeElementDecorator(1, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.propertyPrefix(1),
          new NgToken.elementDecorator(2, 'someProp'),
          new NgToken.propertySuffix(10),
        ),
        new NgToken.openElementEnd(11),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '[');
    expect(e.offset, 1);

    expect(untokenize(results), '< [someProp]>');
  });

  test('should resolve: unexpected ] in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.beforeElementDecorator(1, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.propertyPrefix(1), // Synthetic
          new NgToken.elementDecorator(1, ''), //Synthetic
          new NgToken.propertySuffix(1),
        ),
        new NgToken.openElementEnd(2),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ']');
    expect(e.offset, 1);

    expect(untokenize(results), '< []>');
  });

  test('should resolve: unexpected ( in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<(someEvnt)>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.beforeElementDecorator(1, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.eventPrefix(1),
          new NgToken.elementDecorator(2, 'someEvnt'),
          new NgToken.eventSuffix(10),
        ),
        new NgToken.openElementEnd(11),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '(');
    expect(e.offset, 1);

    expect(untokenize(results), '< (someEvnt)>');
  });

  test('should resolve: unexpected ) in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<)>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.beforeElementDecorator(1, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.eventPrefix(1), // Synthetic
          new NgToken.elementDecorator(1, ''), //Synthetic
          new NgToken.eventSuffix(1),
        ),
        new NgToken.openElementEnd(2),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ')');
    expect(e.offset, 1);

    expect(untokenize(results), '< ()>');
  });

  test('should resolve: unexpected [( in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<[(someBnna)]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.beforeElementDecorator(1, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.bananaPrefix(1),
          new NgToken.elementDecorator(3, 'someBnna'),
          new NgToken.bananaSuffix(11),
        ),
        new NgToken.openElementEnd(13),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '[(');
    expect(e.offset, 1);

    expect(untokenize(results), '< [(someBnna)]>');
  });

  test('should resolve: unexpected )] in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<)]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.beforeElementDecorator(1, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.bananaPrefix(1), // Synthetic
          new NgToken.elementDecorator(1, ''), //Synthetic
          new NgToken.bananaSuffix(1),
        ),
        new NgToken.openElementEnd(3),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ')]');
    expect(e.offset, 1);

    expect(untokenize(results), '< [()]>');
  });

  test('should resolve: unexpected # in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<#someRef>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.beforeElementDecorator(1, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.referencePrefix(1),
          new NgToken.elementDecorator(2, 'someRef'),
        ),
        new NgToken.openElementEnd(9),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '#');
    expect(e.offset, 1);

    expect(untokenize(results), '< #someRef>');
  });

  test('should resolve: unexpected * in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<*someTemp>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.beforeElementDecorator(1, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.templatePrefix(1),
          new NgToken.elementDecorator(2, 'someTemp'),
        ),
        new NgToken.openElementEnd(10),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '*');
    expect(e.offset, 1);

    expect(untokenize(results), '< *someTemp>');
  });

  test('should resolve: unexpected <!-- in ElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<<!-- comment -->');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.openElementEnd(1), // Synthetic
        new NgToken.commentStart(1),
        new NgToken.commentValue(5, ' comment '),
        new NgToken.commentEnd(14),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '<!--');
    expect(e.offset, 1);

    expect(untokenize(results), '<><!-- comment -->');
  });

  test('should resolve: unexpected < in ElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<<div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.openElementEnd(1), // Synthetic
        new NgToken.openElementStart(1),
        new NgToken.elementIdentifier(2, 'div'),
        new NgToken.openElementEnd(5),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '<');
    expect(e.offset, 1);

    expect(untokenize(results), '<><div>');
  });

  test('should resolve: unexpected </ in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<</div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.openElementEnd(1), // Synthetic
        new NgToken.closeElementStart(1),
        new NgToken.elementIdentifier(3, 'div'),
        new NgToken.closeElementEnd(6),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '</');
    expect(e.offset, 1);

    expect(untokenize(results), '<></div>');
  });

  test('should resolve: unexpected > in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.openElementEnd(1),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '>');
    expect(e.offset, 1);

    expect(untokenize(results), '<>');
  });

  test('should resolve: unexpected EOF in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.openElementEnd(1), // Synthetic
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '');
    expect(e.offset, 1);

    expect(untokenize(results), '<>');
  });

  test('should resolve: unexpected quotedText in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<"blah">');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.beforeElementDecorator(1, ' '), // Synthetic
        new NgToken.elementDecorator(1, ''), //Synthetic
        new NgToken.beforeElementDecoratorValue(1), // Synthetic
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(1),
          new NgToken.elementDecoratorValue(2, 'blah'),
          new NgToken.doubleQuote(6),
        ),
        new NgToken.openElementEnd(7),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '"blah"');
    expect(e.offset, 1);

    expect(untokenize(results), '< ="blah">');
  });

  test('should resolve: unexpected = in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<="blah">');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.beforeElementDecorator(1, ' '), // Synthetic
        new NgToken.elementDecorator(1, ''), //Synthetic
        new NgToken.beforeElementDecoratorValue(1),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(2),
          new NgToken.elementDecoratorValue(3, 'blah'),
          new NgToken.doubleQuote(7),
        ),
        new NgToken.openElementEnd(8),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '=');
    expect(e.offset, 1);

    expect(untokenize(results), '< ="blah">');
  });

  test('should resolve: unexpected whitespace in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('< >');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.whitespace(1, ' '),
        new NgToken.openElementEnd(2),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ' ');
    expect(e.offset, 1);

    expect(untokenize(results), '< >');
  });

  test('should resolve: unexpected char in elementIdentifierOpen', () {
    List<NgToken> results = tokenize('<@>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, ''), // Synthetic
        new NgToken.openElementEnd(2),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '@');
    expect(e.offset, 1);

    expect(untokenize(results), '<>');
  });
}

void scanAfterElementIdentifierOpen() {
  test('should resolve: unexpected ! in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div!>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.openElementEnd(5),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '!');
    expect(e.offset, 4);

    expect(untokenize(results), '<div>');
  });

  test('should resolve: unexpected . in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div.>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.openElementEnd(5),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '.');
    expect(e.offset, 4);

    expect(untokenize(results), '<div>');
  });

  test('should resolve: unexpected [ in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div[someProp]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.propertyPrefix(4),
          new NgToken.elementDecorator(5, 'someProp'),
          new NgToken.propertySuffix(13),
        ),
        new NgToken.openElementEnd(14),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '[');
    expect(e.offset, 4);

    expect(untokenize(results), '<div [someProp]>');
  });

  test('should resolve: unexpected ] in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.propertyPrefix(4), // Synthetic
          new NgToken.elementDecorator(4, ''), //Synthetic
          new NgToken.propertySuffix(4),
        ),
        new NgToken.openElementEnd(5),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ']');
    expect(e.offset, 4);

    expect(untokenize(results), '<div []>');
  });

  test('should resolve: unexpected ( in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div(someEvnt)>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.eventPrefix(4),
          new NgToken.elementDecorator(5, 'someEvnt'),
          new NgToken.eventSuffix(13),
        ),
        new NgToken.openElementEnd(14),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '(');
    expect(e.offset, 4);

    expect(untokenize(results), '<div (someEvnt)>');
  });

  test('should resolve: unexpected ) in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div)>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.eventPrefix(4), // Synthetic
          new NgToken.elementDecorator(4, ''), //Synthetic
          new NgToken.eventSuffix(4),
        ),
        new NgToken.openElementEnd(5),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ')');
    expect(e.offset, 4);

    expect(untokenize(results), '<div ()>');
  });

  test('should resolve: unexpected [( in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div[(someBnna)]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.bananaPrefix(4),
          new NgToken.elementDecorator(6, 'someBnna'),
          new NgToken.bananaSuffix(14),
        ),
        new NgToken.openElementEnd(16),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '[(');
    expect(e.offset, 4);

    expect(untokenize(results), '<div [(someBnna)]>');
  });

  test('should resolve: unexpected )] in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div)]>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.bananaPrefix(4), // Synthetic
          new NgToken.elementDecorator(4, ''), //Synthetic
          new NgToken.bananaSuffix(4),
        ),
        new NgToken.openElementEnd(6),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, ')]');
    expect(e.offset, 4);

    expect(untokenize(results), '<div [()]>');
  });

  test('should resolve: unexpected # in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div#someRef>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.referencePrefix(4),
          new NgToken.elementDecorator(5, 'someRef'),
        ),
        new NgToken.openElementEnd(12),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '#');
    expect(e.offset, 4);

    expect(untokenize(results), '<div #someRef>');
  });

  test('should resolve: unexpected * in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div*someTemp>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '), // Synthetic
        new NgSpecialAttributeToken.generate(
          new NgToken.templatePrefix(4),
          new NgToken.elementDecorator(5, 'someTemp'),
        ),
        new NgToken.openElementEnd(13),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '*');
    expect(e.offset, 4);

    expect(untokenize(results), '<div *someTemp>');
  });

  test('should resolve: unexpected <!-- in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div<!-- comment -->');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.openElementEnd(4), // Synthetic
        new NgToken.commentStart(4),
        new NgToken.commentValue(8, ' comment '),
        new NgToken.commentEnd(17),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '<!--');
    expect(e.offset, 4);

    expect(untokenize(results), '<div><!-- comment -->');
  });

  test('should resolve: unexpected < in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div<div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.openElementEnd(4), // Synthetic
        new NgToken.openElementStart(4),
        new NgToken.elementIdentifier(5, 'div'),
        new NgToken.openElementEnd(8),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '<');
    expect(e.offset, 4);

    expect(untokenize(results), '<div><div>');
  });

  test('should resolve: unexpected </ in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div</div>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.openElementEnd(4), // Synthetic
        new NgToken.closeElementStart(4),
        new NgToken.elementIdentifier(6, 'div'),
        new NgToken.closeElementEnd(9),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '</');
    expect(e.offset, 4);

    expect(untokenize(results), '<div></div>');
  });

  test('should resolve: unexpected EOF in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.openElementEnd(4), // Synthetic
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '');
    expect(e.offset, 4);

    expect(untokenize(results), '<div>');
  });

  test('should resolve: unexpected quotedText in afterElementIdentifierOpen',
      () {
    List<NgToken> results = tokenize('<div"blah">');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '), // Synthetic
        new NgToken.elementDecorator(4, ''), // Synthetic
        new NgToken.beforeElementDecoratorValue(4), // Synthetic
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(4),
          new NgToken.elementDecoratorValue(5, 'blah'),
          new NgToken.doubleQuote(9),
        ),
        new NgToken.openElementEnd(10),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '"blah"');
    expect(e.offset, 4);

    expect(untokenize(results), '<div ="blah">');
  });

  test('should resolve: unexpected = in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div="blah">');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.beforeElementDecorator(4, ' '), // Synthetic
        new NgToken.elementDecorator(4, ''), //Synthetic
        new NgToken.beforeElementDecoratorValue(4),
        new NgAttributeValueToken.generate(
          new NgToken.doubleQuote(5),
          new NgToken.elementDecoratorValue(6, 'blah'),
          new NgToken.doubleQuote(10),
        ),
        new NgToken.openElementEnd(11),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '=');
    expect(e.offset, 4);

    expect(untokenize(results), '<div ="blah">');
  });

  test('should resolve: unexpected char in afterElementIdentifierOpen', () {
    List<NgToken> results = tokenize('<div@>');
    expect(
      results,
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.openElementEnd(5),
      ],
    );
    expect(exceptionHandler.exceptions.length, 1);
    FormatException e = exceptionHandler.exceptions[0];
    expect(e.source, '@');
    expect(e.offset, 4);

    expect(untokenize(results), '<div>');
  });
}
