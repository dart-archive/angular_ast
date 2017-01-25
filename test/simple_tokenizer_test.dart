// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/simple_tokenizer.dart';
import 'package:angular_ast/src/simple_token.dart';
import 'package:test/test.dart';

void main() {
  Iterable<NgSimpleToken> tokenize(String html) =>
      new NgSimpleTokenizer().tokenize(html);
  String untokenize(Iterable<NgSimpleToken> tokens) => tokens
      .fold(new StringBuffer(), (buffer, token) => buffer..write(token.lexeme))
      .toString();

  test('should tokenize plain text', () {
    expect(tokenize('Hello World'), [
      new NgSimpleToken.text(0, 'Hello World'),
    ]);
  });

  test('should tokenize multiline text', () {
    expect(
        tokenize('Hello\nWorld'), [new NgSimpleToken.text(0, 'Hello\nWorld')]);
  });

  test('should tokenize an HTML element', () {
    expect(tokenize('''<div></div>'''), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.text(1, 'div'),
      new NgSimpleToken.tagEnd(4),
      new NgSimpleToken.tagStart(5),
      new NgSimpleToken.forwardSlash(6),
      new NgSimpleToken.text(7, 'div'),
      new NgSimpleToken.tagEnd(10)
    ]);
  });

  test('should tokenize an HTML element with local variable', () {
    expect(tokenize('''<div #myDiv></div>'''), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.text(1, 'div'),
      new NgSimpleToken.whitespace(4, ' '),
      new NgSimpleToken.hash(5),
      new NgSimpleToken.text(6, 'myDiv'),
      new NgSimpleToken.tagEnd(11),
      new NgSimpleToken.tagStart(12),
      new NgSimpleToken.forwardSlash(13),
      new NgSimpleToken.text(14, 'div'),
      new NgSimpleToken.tagEnd(17)
    ]);
  });

  test('should tokenize an HTML element with void', () {
    expect(tokenize('<hr/>'), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.text(1, "hr"),
      new NgSimpleToken.forwardSlash(3),
      new NgSimpleToken.tagEnd(4)
    ]);
  });

  test('should tokenize nested HTML elements', () {
    expect(tokenize('<div><span></span></div>'), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.text(1, 'div'),
      new NgSimpleToken.tagEnd(4),
      new NgSimpleToken.tagStart(5),
      new NgSimpleToken.text(6, 'span'),
      new NgSimpleToken.tagEnd(10),
      new NgSimpleToken.tagStart(11),
      new NgSimpleToken.forwardSlash(12),
      new NgSimpleToken.text(13, 'span'),
      new NgSimpleToken.tagEnd(17),
      new NgSimpleToken.tagStart(18),
      new NgSimpleToken.forwardSlash(19),
      new NgSimpleToken.text(20, 'div'),
      new NgSimpleToken.tagEnd(23)
    ]);
  });

  test('should tokenize HTML elements mixed with plain text', () {
    expect(tokenize('<div>Hello this is text</div>'), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.text(1, 'div'),
      new NgSimpleToken.tagEnd(4),
      new NgSimpleToken.text(5, 'Hello this is text'),
      new NgSimpleToken.tagStart(23),
      new NgSimpleToken.forwardSlash(24),
      new NgSimpleToken.text(25, 'div'),
      new NgSimpleToken.tagEnd(28)
    ]);
  });

  test('should tokenize an HTML template and untokenize back', () {
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

  test('should tokenize an element with a decorator with a value', () {
    expect(tokenize(r'<button title="Submit \"quoted text\""></button>'), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.text(1, 'button'),
      new NgSimpleToken.whitespace(7, ' '),
      new NgSimpleToken.text(8, 'title'),
      new NgSimpleToken.equalSign(13),
      new NgSimpleToken.doubleQuotedText(14, '"Submit \"quoted text\""'),
      new NgSimpleToken.tagEnd(38),
      new NgSimpleToken.tagStart(39),
      new NgSimpleToken.forwardSlash(40),
      new NgSimpleToken.text(41, 'button'),
      new NgSimpleToken.tagEnd(47)
    ]);
  });

  test('should tokenize a HTML template with decorator values and back', () {
    const html = r'''
      <div>
        <span hidden>Hello World</span>
        <a href="www.somelink.com/index.html">Click me!</a>
        <!-- some random comment inserted here -->
        <ul>
          <li>1</li>
          <li>
            <textarea disabled name="box" readonly>Test</textarea>
          </li>
          <li>
            <myTag myAttr="some value "literal""></myTag>
            <button disabled>3</button>
          </li>
        </ul>
      </div>
    ''';
    expect(untokenize(tokenize(html)), html);
  });

  test('should tokenize a comment', () {
    expect(tokenize('<!--Hello World-->'), [
      new NgSimpleToken.commentBegin(0),
      new NgSimpleToken.text(4, 'Hello World'),
      new NgSimpleToken.commentEnd(15)
    ]);
  });

  test('should tokenize copyright comments', () {
    expect(
      tokenize(''
          '<!--\n'
          '  Copyright (c) 2016, the Dart project authors.\n'
          '-->'),
      [
        new NgSimpleToken.commentBegin(0),
        new NgSimpleToken.text(
          4,
          '\n  Copyright (c) 2016, the Dart project authors.\n',
        ),
        new NgSimpleToken.commentEnd(53),
      ],
    );
  });

  test('should tokenize asterisks', () {
    expect(tokenize('<span *ngIf="some bool"></span>'), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.text(1, "span"),
      new NgSimpleToken.whitespace(5, ' '),
      new NgSimpleToken.star(6),
      new NgSimpleToken.text(7, 'ngIf'),
      new NgSimpleToken.equalSign(11),
      new NgSimpleToken.doubleQuotedText(12, '"some bool"'),
      new NgSimpleToken.tagEnd(23),
      new NgSimpleToken.tagStart(24),
      new NgSimpleToken.forwardSlash(25),
      new NgSimpleToken.text(26, 'span'),
      new NgSimpleToken.tagEnd(30)
    ]);
  });

  //Error cases

  test('should tokenize unclosed comments', () {
    expect(
        tokenize(''
            '<!--\n'
            '  Copyright (c) 2016, the Dart project authors.\n'),
        [
          new NgSimpleToken.commentBegin(0),
          new NgSimpleToken.text(
            4,
            '\n  Copyright (c) 2016, the Dart project authors.\n',
          ),
        ]);
  });

  test('should tokenize unclosed element tag hitting EOF', () {
    expect(tokenize('<div '), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.text(1, 'div'),
      new NgSimpleToken.whitespace(4, ' ')
    ]);
  });

  test('should tokenize unclosed element tags', () {
    expect(
        tokenize(''
            '<div>'
            ' some text stuff here '
            '<span'
            '</div>'),
        [
          new NgSimpleToken.tagStart(0),
          new NgSimpleToken.text(1, 'div'),
          new NgSimpleToken.tagEnd(4),
          new NgSimpleToken.text(5, ' some text stuff here '),
          new NgSimpleToken.tagStart(27),
          new NgSimpleToken.text(28, 'span'),
          new NgSimpleToken.tagStart(32),
          new NgSimpleToken.forwardSlash(33),
          new NgSimpleToken.text(34, 'div'),
          new NgSimpleToken.tagEnd(37)
        ]);
  });

  test('should tokenize dangling double quote', () {
    expect(tokenize('''<div [someInput]=" (someEvent)='do something'>'''), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.text(1, 'div'),
      new NgSimpleToken.whitespace(4, ' '),
      new NgSimpleToken.openBracket(5),
      new NgSimpleToken.text(6, 'someInput'),
      new NgSimpleToken.closeBracket(15),
      new NgSimpleToken.equalSign(16),
      new NgSimpleToken.doubleQuote(17),
      new NgSimpleToken.whitespace(18, ' '),
      new NgSimpleToken.openParen(19),
      new NgSimpleToken.text(20, 'someEvent'),
      new NgSimpleToken.closeParen(29),
      new NgSimpleToken.equalSign(30),
      new NgSimpleToken.singleQuotedText(31, "'do something'"),
      new NgSimpleToken.tagEnd(45)
    ]);
  });

  test('should tokenize unclosed attr hitting EOF', () {
    expect(tokenize('<div someAttr '), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.text(1, 'div'),
      new NgSimpleToken.whitespace(4, ' '),
      new NgSimpleToken.text(5, 'someAttr'),
      new NgSimpleToken.whitespace(13, ' '),
    ]);
  });

  test('should tokenize unclosed attr value hitting EOF', () {
    expect(tokenize('<div someAttr ='), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.text(1, 'div'),
      new NgSimpleToken.whitespace(4, ' '),
      new NgSimpleToken.text(5, 'someAttr'),
      new NgSimpleToken.whitespace(13, ' '),
      new NgSimpleToken.equalSign(14),
    ]);
  });
}
