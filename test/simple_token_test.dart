import 'package:angular_ast/src/simple_token.dart';
import 'package:test/test.dart';

void main() {
  NgSimpleToken token;

  test('bang', () {
    token = new NgSimpleToken.bang(0);
    expect(token.lexeme, '!');
    expect(token.end, 1);
    expect(token.length, 1);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.bang);
  });

  test('closeBracket', () {
    token = new NgSimpleToken.closeBracket(0);
    expect(token.lexeme, ']');
    expect(token.end, 1);
    expect(token.length, 1);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.closeBracket);
  });

  test('closeParen', () {
    token = new NgSimpleToken.closeParen(0);
    expect(token.lexeme, ')');
    expect(token.end, 1);
    expect(token.length, 1);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.closeParen);
  });

  test('commentBegin', () {
    token = new NgSimpleToken.commentBegin(0);
    expect(token.lexeme, '<!--');
    expect(token.end, 4);
    expect(token.length, 4);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.commentBegin);
  });

  test('commentEnd', () {
    token = new NgSimpleToken.commentEnd(0);
    expect(token.lexeme, '-->');
    expect(token.end, 3);
    expect(token.length, 3);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.commentEnd);
  });

  test('dash', () {
    token = new NgSimpleToken.dash(0);
    expect(token.lexeme, '-');
    expect(token.end, 1);
    expect(token.length, 1);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.dash);
  });

  test('dashedIdenifier', () {
    token = new NgSimpleToken.dashedIdentifier(0, 'some_dashed-identifier');
    expect(token.lexeme, 'some_dashed-identifier');
    expect(token.end, 22);
    expect(token.length, 22);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.dashedIdentifier);
  });

  test('tagStart', () {
    token = new NgSimpleToken.tagStart(0);
    expect(token.lexeme, '<');
    expect(token.end, 1);
    expect(token.length, 1);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.tagStart);
  });

  test('tagEnd', () {
    token = new NgSimpleToken.tagEnd(0);
    expect(token.lexeme, '>');
    expect(token.end, 1);
    expect(token.length, 1);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.tagEnd);
  });

  test('equalSign', () {
    token = new NgSimpleToken.equalSign(0);
    expect(token.lexeme, '=');
    expect(token.end, 1);
    expect(token.length, 1);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.equalSign);
  });

  test('forwardSlash', () {
    token = new NgSimpleToken.forwardSlash(0);
    expect(token.lexeme, '/');
    expect(token.end, 1);
    expect(token.length, 1);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.forwardSlash);
  });

  test('hash', () {
    token = new NgSimpleToken.hash(0);
    expect(token.lexeme, '#');
    expect(token.end, 1);
    expect(token.length, 1);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.hash);
  });

  test('identifier', () {
    token = new NgSimpleToken.identifier(0, 'some_tag_identifier');
    expect(token.lexeme, 'some_tag_identifier');
    expect(token.end, 19);
    expect(token.length, 19);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.identifier);
  });

  test('openBracket', () {
    token = new NgSimpleToken.openBracket(0);
    expect(token.lexeme, '[');
    expect(token.end, 1);
    expect(token.length, 1);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.openBracket);
  });

  test('openParen', () {
    token = new NgSimpleToken.openParen(0);
    expect(token.lexeme, '(');
    expect(token.end, 1);
    expect(token.length, 1);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.openParen);
  });

  test('period', () {
    token = new NgSimpleToken.period(0);
    expect(token.lexeme, '.');
    expect(token.end, 1);
    expect(token.length, 1);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.period);
  });

  test('star', () {
    token = new NgSimpleToken.star(0);
    expect(token.end, 1);
    expect(token.length, 1);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.star);
  });

  test('text', () {
    token = new NgSimpleToken.text(0, 'some long text string');
    expect(token.lexeme, 'some long text string');
    expect(token.end, 21);
    expect(token.length, 21);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.text);
  });

  test('unexpectedChar', () {
    token = new NgSimpleToken.unexpectedChar(0, '!@#\$');
    expect(token.lexeme, '!@#\$');
    expect(token.end, 4);
    expect(token.length, 4);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.unexpectedChar);
  });

  test('whitespace', () {
    token = new NgSimpleToken.whitespace(0, '     \t\t\n');
    expect(token.lexeme, '     \t\t\n');
    expect(token.end, 8);
    expect(token.length, 8);
    expect(token.offset, 0);
    expect(token.type, NgSimpleTokenType.whitespace);
  });

  test('doubleQuotedText - closed', () {
    NgSimpleQuoteToken quoteToken = new NgSimpleQuoteToken.doubleQuotedText(
        0, '"this is a \"quoted\" text"', true);
    expect(quoteToken.lexeme, 'this is a \"quoted\" text');
    expect(quoteToken.end, 24);
    expect(quoteToken.length, 23);
    expect(quoteToken.offset, 1);
    expect(quoteToken.quoteEndOffset, 25);
    expect(quoteToken.quoteOffset, 0);
    expect(quoteToken.quotedLexeme, '"this is a \"quoted\" text"');
    expect(quoteToken.quotedLength, 25);
    expect(quoteToken.type, NgSimpleTokenType.doubleQuote);
  });

  test('doubleQuotedText - open', () {
    NgSimpleQuoteToken quoteToken = new NgSimpleQuoteToken.doubleQuotedText(
        0, '"this is a \"quoted\" text', false);
    expect(quoteToken.lexeme, 'this is a \"quoted\" text');
    expect(quoteToken.end, 24);
    expect(quoteToken.length, 23);
    expect(quoteToken.offset, 1);
    expect(quoteToken.quoteEndOffset, null);
    expect(quoteToken.quoteOffset, 0);
    expect(quoteToken.quotedLexeme, '"this is a \"quoted\" text');
    expect(quoteToken.quotedLength, 24);
    expect(quoteToken.type, NgSimpleTokenType.doubleQuote);
  });

  test('singleQuotedText - closed', () {
    NgSimpleQuoteToken quoteToken = new NgSimpleQuoteToken.singleQuotedText(
        0, "'this is a \'quoted\' text'", true);
    expect(quoteToken.lexeme, "this is a \'quoted\' text");
    expect(quoteToken.end, 24);
    expect(quoteToken.length, 23);
    expect(quoteToken.offset, 1);
    expect(quoteToken.quoteEndOffset, 25);
    expect(quoteToken.quoteOffset, 0);
    expect(quoteToken.quotedLexeme, "'this is a \'quoted\' text'");
    expect(quoteToken.quotedLength, 25);
    expect(quoteToken.type, NgSimpleTokenType.singleQuote);
  });

  test('doubleQuotedText - open', () {
    NgSimpleQuoteToken quoteToken = new NgSimpleQuoteToken.singleQuotedText(
        0, "'this is a \'quoted\' text", false);
    expect(quoteToken.lexeme, "this is a \'quoted\' text");
    expect(quoteToken.end, 24);
    expect(quoteToken.length, 23);
    expect(quoteToken.offset, 1);
    expect(quoteToken.quoteEndOffset, null);
    expect(quoteToken.quoteOffset, 0);
    expect(quoteToken.quotedLexeme, "'this is a \'quoted\' text");
    expect(quoteToken.quotedLength, 24);
    expect(quoteToken.type, NgSimpleTokenType.singleQuote);
  });
}
