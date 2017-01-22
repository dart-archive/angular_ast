import 'package:angular_ast/src/simple_tokenizer.dart';
import 'package:angular_ast/src/simple_token.dart';
import 'package:test/test.dart';

void main() {
  Iterable<NgSimpleToken> tokenize(String html) =>
      new NgSimpleTokenizer(html).tokenize();
  String untokenize(Iterable<NgSimpleToken> tokens) => tokens
      .fold(new StringBuffer(), (buffer, token) => buffer..write(token.lexeme))
      .toString();

  /**
  test('', () {
    expect(
      tokenize(''),
      [
      ]
    );
  });
  **/

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
    expect(tokenize('<button title="Submit"></button>'), [
      new NgSimpleToken.tagStart(0),
      new NgSimpleToken.text(1, 'button'),
      new NgSimpleToken.whitespace(7, ' '),
      new NgSimpleToken.text(8, 'title'),
      new NgSimpleToken.equalSign(13),
      new NgSimpleToken.doubleQuotedText(14, '"Submit"'),
      new NgSimpleToken.tagEnd(22),
      new NgSimpleToken.tagStart(23),
      new NgSimpleToken.forwardSlash(24),
      new NgSimpleToken.text(25, 'button'),
      new NgSimpleToken.tagEnd(31)
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
}
