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
      .fold(
          new StringBuffer(),
          (buffer, token) => buffer
            ..write((token is NgSimpleQuoteToken)
                ? token.quotedLexeme
                : token.lexeme))
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
      new NgSimpleToken.identifier(1, 'div'),
      new NgSimpleToken.tagEnd(4),
      new NgSimpleToken.tagStart(5),
      new NgSimpleToken.forwardSlash(6),
      new NgSimpleToken.identifier(7, 'div'),
      new NgSimpleToken.tagEnd(10)
    ]);
  });

  test('should tokenize an HTML element with dash', () {
    expect(tokenize('''<my-tag></my-tag>'''), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.dashedIdentifier(1, 'my-tag'),
      new NgSimpleToken.tagEnd(7),
      new NgSimpleToken.tagStart(8),
      new NgSimpleToken.forwardSlash(9),
      new NgSimpleToken.dashedIdentifier(10, 'my-tag'),
      new NgSimpleToken.tagEnd(16)
    ]);
  });

  test('should tokenize an HTML element with local variable', () {
    expect(tokenize('''<div #myDiv></div>'''), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.identifier(1, 'div'),
      new NgSimpleToken.whitespace(4, ' '),
      new NgSimpleToken.hash(5),
      new NgSimpleToken.identifier(6, 'myDiv'),
      new NgSimpleToken.tagEnd(11),
      new NgSimpleToken.tagStart(12),
      new NgSimpleToken.forwardSlash(13),
      new NgSimpleToken.identifier(14, 'div'),
      new NgSimpleToken.tagEnd(17)
    ]);
  });

  test('should tokenize an HTML element with void', () {
    expect(tokenize('<hr/>'), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.identifier(1, "hr"),
      new NgSimpleToken.forwardSlash(3),
      new NgSimpleToken.tagEnd(4)
    ]);
  });

  test('should tokenize nested HTML elements', () {
    expect(tokenize('<div><span></span></div>'), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.identifier(1, 'div'),
      new NgSimpleToken.tagEnd(4),
      new NgSimpleToken.tagStart(5),
      new NgSimpleToken.identifier(6, 'span'),
      new NgSimpleToken.tagEnd(10),
      new NgSimpleToken.tagStart(11),
      new NgSimpleToken.forwardSlash(12),
      new NgSimpleToken.identifier(13, 'span'),
      new NgSimpleToken.tagEnd(17),
      new NgSimpleToken.tagStart(18),
      new NgSimpleToken.forwardSlash(19),
      new NgSimpleToken.identifier(20, 'div'),
      new NgSimpleToken.tagEnd(23)
    ]);
  });

  test('should tokenize HTML elements mixed with plain text', () {
    expect(tokenize('<div>Hello this is text</div>'), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.identifier(1, 'div'),
      new NgSimpleToken.tagEnd(4),
      new NgSimpleToken.text(5, 'Hello this is text'),
      new NgSimpleToken.tagStart(23),
      new NgSimpleToken.forwardSlash(24),
      new NgSimpleToken.identifier(25, 'div'),
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
      new NgSimpleToken.identifier(1, 'button'),
      new NgSimpleToken.whitespace(7, ' '),
      new NgSimpleToken.identifier(8, 'title'),
      new NgSimpleToken.equalSign(13),
      new NgSimpleQuoteToken.doubleQuotedText(
          14, '"Submit \"quoted text\""', true),
      new NgSimpleToken.tagEnd(38),
      new NgSimpleToken.tagStart(39),
      new NgSimpleToken.forwardSlash(40),
      new NgSimpleToken.identifier(41, 'button'),
      new NgSimpleToken.tagEnd(47)
    ]);
  });

  test('should tokenize an HTML element with bracket and period in decorator',
      () {
    expect(tokenize('''<my-tag [attr.x]="y"></my-tag>'''), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.dashedIdentifier(1, 'my-tag'),
      new NgSimpleToken.whitespace(7, ' '),
      new NgSimpleToken.openBracket(8),
      new NgSimpleToken.identifier(9, 'attr'),
      new NgSimpleToken.period(13),
      new NgSimpleToken.identifier(14, 'x'),
      new NgSimpleToken.closeBracket(15),
      new NgSimpleToken.equalSign(16),
      new NgSimpleQuoteToken.doubleQuotedText(17, '"y"', true),
      new NgSimpleToken.tagEnd(20),
      new NgSimpleToken.tagStart(21),
      new NgSimpleToken.forwardSlash(22),
      new NgSimpleToken.dashedIdentifier(23, 'my-tag'),
      new NgSimpleToken.tagEnd(29)
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
            <button disabled [attr.x]="y">3</button>
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
      new NgSimpleToken.identifier(1, "span"),
      new NgSimpleToken.whitespace(5, ' '),
      new NgSimpleToken.star(6),
      new NgSimpleToken.identifier(7, 'ngIf'),
      new NgSimpleToken.equalSign(11),
      new NgSimpleQuoteToken.doubleQuotedText(12, '"some bool"', true),
      new NgSimpleToken.tagEnd(23),
      new NgSimpleToken.tagStart(24),
      new NgSimpleToken.forwardSlash(25),
      new NgSimpleToken.identifier(26, 'span'),
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
      new NgSimpleToken.identifier(1, 'div'),
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
          new NgSimpleToken.identifier(1, 'div'),
          new NgSimpleToken.tagEnd(4),
          new NgSimpleToken.text(5, ' some text stuff here '),
          new NgSimpleToken.tagStart(27),
          new NgSimpleToken.identifier(28, 'span'),
          new NgSimpleToken.tagStart(32),
          new NgSimpleToken.forwardSlash(33),
          new NgSimpleToken.identifier(34, 'div'),
          new NgSimpleToken.tagEnd(37)
        ]);
  });

  test('should tokenize dangling double quote', () {
    expect(tokenize('''<div [someInput]=" (someEvent)='do something'>'''), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.identifier(1, 'div'),
      new NgSimpleToken.whitespace(4, ' '),
      new NgSimpleToken.openBracket(5),
      new NgSimpleToken.identifier(6, 'someInput'),
      new NgSimpleToken.closeBracket(15),
      new NgSimpleToken.equalSign(16),
      new NgSimpleQuoteToken.doubleQuotedText(
          17, '" (someEvent)=\'do something\'>', false),
    ]);
  });

  test('should tokenize dangling single quote', () {
    expect(tokenize('''<div [someInput]=' (someEvent)="do something">'''), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.identifier(1, 'div'),
      new NgSimpleToken.whitespace(4, ' '),
      new NgSimpleToken.openBracket(5),
      new NgSimpleToken.identifier(6, 'someInput'),
      new NgSimpleToken.closeBracket(15),
      new NgSimpleToken.equalSign(16),
      new NgSimpleQuoteToken.singleQuotedText(
          17, "' (someEvent)=\"do something\">", false),
    ]);
  });

  test('should tokenize unclosed attr hitting EOF', () {
    expect(tokenize('<div someAttr '), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.identifier(1, 'div'),
      new NgSimpleToken.whitespace(4, ' '),
      new NgSimpleToken.identifier(5, 'someAttr'),
      new NgSimpleToken.whitespace(13, ' '),
    ]);
  });

  test('should tokenize unclosed attr value hitting EOF', () {
    expect(tokenize('<div someAttr ='), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.identifier(1, 'div'),
      new NgSimpleToken.whitespace(4, ' '),
      new NgSimpleToken.identifier(5, 'someAttr'),
      new NgSimpleToken.whitespace(13, ' '),
      new NgSimpleToken.equalSign(14),
    ]);
  });
}
