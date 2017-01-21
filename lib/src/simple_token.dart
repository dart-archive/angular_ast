library angular_ast.src.simple_token;

import 'package:quiver/core.dart';

part 'token/simple_type.dart';

class NgSimpleToken {
  //Probably don't need
  factory NgSimpleToken.closeBrace(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.closeBrace, offset);
  }

  factory NgSimpleToken.closeBracket(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.closeBracket, offset);
  }

  factory NgSimpleToken.closeParen(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.closeParen, offset);
  }

  factory NgSimpleToken.commentBegin(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.commentBegin, offset);
  }

  factory NgSimpleToken.commentEnd(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.commentEnd, offset);
  }

  factory NgSimpleToken.doubleQuote(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.doubleQuote, offset);
  }

  factory NgSimpleToken.elementStart(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.elementStart, offset);
  }

  factory NgSimpleToken.elementEnd(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.elementEnd, offset);
  }

  factory NgSimpleToken.elementEndVoid(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.elementEndVoid, offset);
  }

  factory NgSimpleToken.EOF(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.EOF, offset);
  }

  factory NgSimpleToken.equalSign(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.equalSign, offset);
  }

  factory NgSimpleToken.forwardSlash(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.forwardSlash, offset);
  }

  factory NgSimpleToken.hash(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.hash, offset);
  }

  //Probably don't need
  factory NgSimpleToken.openBrace(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.openBrace, offset);
  }

  factory NgSimpleToken.openBracket(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.openBracket, offset);
  }

  factory NgSimpleToken.openParen(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.openParen, offset);
  }

  factory NgSimpleToken.singleQuote(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.singleQuote, offset);
  }

  factory NgSimpleToken.text(int offset, String lexeme) {
    return new NgSimpleToken(new NgSimpleTokenType.textType(lexeme), offset);
  }

  factory NgSimpleToken.unexpectedChar(int offset, String lexeme) {
    return new NgSimpleToken(
        new NgSimpleTokenType.unexpectedChar(lexeme), offset);
  }

  factory NgSimpleToken.whitespace(int offset, String lexeme) {
    return new NgSimpleToken(
        new NgSimpleTokenType.whitespaceType(lexeme), offset);
  }

  const NgSimpleToken._(this.type, this.offset);

  NgSimpleToken(this.type, this.offset);

  @override
  bool operator ==(Object o) {
    if (o is NgSimpleToken) {
      return o.offset == offset && o.type == type;
    }
    return false;
  }

  @override
  int get hashCode => hash2(offset, type);

  int get end => offset + length;
  int get length => lexeme.length;
  String get lexeme => type.lexeme;

  final int offset;
  final NgSimpleTokenType type;

  @override
  String toString() => '#$NgSimpleToken(${type.name}) {$offset:$lexeme}';
}
