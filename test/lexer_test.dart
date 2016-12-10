// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:angular_ast/angular_ast.dart';
import 'package:test/test.dart';

main() {
  // Returns the html parsed as a series of tokens.
  Iterable<NgToken> tokenize(String html) => const NgLexer().tokenize(html);

  // Returns the html parsed as a series of tokens, then back to html.
  String untokenize(Iterable<NgToken> tokens) => tokens
      .fold(new StringBuffer(), (buffer, token) => buffer..write(token.lexeme))
      .toString();

  test('should tokenize plain text', () {
    expect(
      tokenize('Hello World'),
      [
        new NgToken.text(0, 'Hello World'),
      ],
    );
  });

  test('should tokenize mulitline text', () {
    expect(
      tokenize('Hello\nWorld'),
      [
        new NgToken.text(0, 'Hello\nWorld'),
      ],
    );
  });

  test('should tokenize an HTML element', () {
    expect(
      tokenize('<div></div>'),
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.openElementEnd(4),
        new NgToken.closeElementStart(5),
        new NgToken.elementIdentifier(7, 'div'),
        new NgToken.closeElementEnd(10),
      ],
    );
  });

  test('should tokenize nested HTML elements', () {
    expect(
      tokenize('<div><span></span></div>'),
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.openElementEnd(4),
        new NgToken.openElementStart(5),
        new NgToken.elementIdentifier(6, 'span'),
        new NgToken.openElementEnd(10),
        new NgToken.closeElementStart(11),
        new NgToken.elementIdentifier(13, 'span'),
        new NgToken.closeElementEnd(17),
        new NgToken.closeElementStart(18),
        new NgToken.elementIdentifier(20, 'div'),
        new NgToken.closeElementEnd(23),
      ],
    );
  });

  test('should tokenize HTML elements mixed with plain text', () {
    expect(
      tokenize('<div>Hello</div>'),
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'div'),
        new NgToken.openElementEnd(4),
        new NgToken.text(5, 'Hello'),
        new NgToken.closeElementStart(10),
        new NgToken.elementIdentifier(12, 'div'),
        new NgToken.closeElementEnd(15),
      ],
    );
  });

  // This is both easier to write than a large Iterable<NgToken> assertion and
  // also verifies that the tokenizing is stable - that is, you can reproduce
  // the original parsed string from the tokens.
  test('should tokenize a large HTML template and untokenize back', () {
    const html = r'''
      <div>
        <span>Hello World</span>
        <ul>
          <li>1</li>
          <li>2</li>
          <li>
            <strong>3</strong>
          </li>
        </ul>
      </div>
    ''';
    expect(untokenize(tokenize(html)), html);
  });

  test('should tokenize an element with a value-less decorator', () {
    expect(
      tokenize('<button disabled></button>'),
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'button'),
        new NgToken.beforeElementDecorator(7, ' '),
        new NgToken.elementDecorator(8, 'disabled'),
        new NgToken.openElementEnd(16),
        new NgToken.closeElementStart(17),
        new NgToken.elementIdentifier(19, 'button'),
        new NgToken.closeElementEnd(25),
      ],
    );
  });

  test('should tokenize an element with multiple value-less decorators', () {
    expect(
      tokenize('<button disabled hidden></button>'),
      [
        new NgToken.openElementStart(0),
        new NgToken.elementIdentifier(1, 'button'),
        new NgToken.beforeElementDecorator(7, ' '),
        new NgToken.elementDecorator(8, 'disabled'),
        new NgToken.beforeElementDecorator(16, ' '),
        new NgToken.elementDecorator(17, 'hidden'),
        new NgToken.openElementEnd(23),
        new NgToken.closeElementStart(24),
        new NgToken.elementIdentifier(26, 'button'),
        new NgToken.closeElementEnd(32),
      ],
    );
  });

  // This is both easier to write than a large Iterable<NgToken> assertion and
  // also verifies that the tokenizing is stable - that is, you can reproduce
  // the original parsed string from the tokens.
  test('should tokenize a large HTML template with decorators and back', () {
    const html = r'''
      <div>
        <span hidden>Hello World</span>
        <ul>
          <li>1</li>
          <li>2</li>
          <li>
            <button disabled>3</button>
          </li>
        </ul>
      </div>
    ''';
    expect(untokenize(tokenize(html)), html);
  });
}
