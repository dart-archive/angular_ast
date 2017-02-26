// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/simple_tokenizer.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:test/test.dart';

void main() {
  NgSimpleToken tokenize(String html) => new NgSimpleScanner(html).scan();
  NgSimpleToken tokenizeTag(String html) =>
      new NgSimpleScanner(html, initialTextState: false).scan();

  //Text node
  test('text node: should tokenize text', () {
    expect(
      tokenize("some random text <div></div>"),
      new NgSimpleToken.text(0, "some random text "),
    );
  });

  test('text node: should tokenize elementStart tag', () {
    expect(tokenize("<div></div>"), new NgSimpleToken.openTagStart(0));
  });

  test('text node: should tokenize EOF', () {
    expect(new NgSimpleScanner("").scan(), new NgSimpleToken.EOF(0));
  });

  test('text node: should tokenize commentStart', () {
    expect(new NgSimpleScanner("<!--Hello World-->").scan(),
        new NgSimpleToken.commentBegin(0));
  });

  //Element node
  test('element: should tokenize end bracket', () {
    expect(tokenizeTag("]='someAttrValue'"), new NgSimpleToken.closeBracket(0));
  });

  test('element: should tokenize single bang', () {
    expect(tokenizeTag("!-- some comment tag -->"), new NgSimpleToken.bang(0));
  });

  test('element: should tokenize single dash', () {
    expect(tokenizeTag("-- some comment tag -->"), new NgSimpleToken.dash(0));
  });

  test('element: should tokenize closeParen', () {
    expect(tokenizeTag(")='someAttrValue'"), new NgSimpleToken.closeParen(0));
  });

  test('element: should tokenze elementEnd', () {
    expect(tokenizeTag("> some text </div>"), new NgSimpleToken.tagEnd(0));
  });

  test('element: should tokenize voidCloseTag', () {
    expect(tokenizeTag("/><div></div>"), new NgSimpleToken.voidCloseTag(0));
  });

  test('element: should tokenize openBracket', () {
    expect(tokenizeTag("[someInput]='blah'"), new NgSimpleToken.openBracket(0));
  });

  test('element: should tokenize openParen', () {
    expect(tokenizeTag("(someEvent)='do something;'"),
        new NgSimpleToken.openParen(0));
  });

  test('element: should tokenize whiteSpace', () {
    expect(tokenizeTag("  someAttr='blah'"),
        new NgSimpleToken.whitespace(0, "  "));
  });

  test('element: should tokenize identifier', () {
    expect(tokenizeTag("my-element_tag [a]='y'>"),
        new NgSimpleToken.identifier(0, "my-element_tag"));
  });

  test('element: should tokenize single letter text', () {
    expect(tokenizeTag("a href='blah>"), new NgSimpleToken.identifier(0, 'a'));
  });

  test('element: should tokenize doubleQuoted text', () {
    expect(
        tokenizeTag('"doSomething1; doSomething2"'),
        new NgSimpleQuoteToken.doubleQuotedText(
            0, '"doSomething1; doSomething2"', true));
  });

  test('element: should tokenize singleQuoted text', () {
    expect(
        tokenizeTag("'doSomething1; doSomething2'"),
        new NgSimpleQuoteToken.singleQuotedText(
            0, "'doSomething1; doSomething2'", true));
  });

  test('element: should tokenize unclosed doubleQuote', () {
    expect(tokenizeTag('" blah blah'),
        new NgSimpleQuoteToken.doubleQuotedText(0, '" blah blah', false));
  });

  test('element: should tokenize unclosed singleQuote', () {
    expect(tokenizeTag("' blah blah"),
        new NgSimpleQuoteToken.singleQuotedText(0, "' blah blah", false));
  });

  test('element: should tokenize elementStart tag', () {
    expect(tokenizeTag("<div></div>"), new NgSimpleToken.openTagStart(0));
  });

  test('element: should tokenize equalSign', () {
    expect(tokenizeTag("='SomeValue'"), new NgSimpleToken.equalSign(0));
  });
}
