// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library angular_ast.src.simple_token;

import 'package:quiver/core.dart';

part 'token/simple_type.dart';

class NgSimpleToken {
  factory NgSimpleToken.bang(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.bang, offset);
  }

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

  factory NgSimpleToken.dash(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.dash, offset);
  }

  factory NgSimpleToken.doubleQuote(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.doubleQuote, offset);
  }

  factory NgSimpleToken.doubleQuotedText(int offset, String lexeme) {
    return new NgSimpleToken(
        new NgSimpleTokenType.doubleQuotedText(lexeme), offset);
  }

  factory NgSimpleToken.tagStart(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.tagStart, offset);
  }

  factory NgSimpleToken.tagEnd(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.tagEnd, offset);
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

  factory NgSimpleToken.singleQuotedText(int offset, String lexeme) {
    return new NgSimpleToken(
        new NgSimpleTokenType.singleQuotedText(lexeme), offset);
  }

  factory NgSimpleToken.star(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.star, offset);
  }

  factory NgSimpleToken.text(int offset, String lexeme) {
    return new NgSimpleToken(new NgSimpleTokenType.text(lexeme), offset);
  }

  factory NgSimpleToken.unexpectedChar(int offset, String lexeme) {
    return new NgSimpleToken(
        new NgSimpleTokenType.unexpectedChar(lexeme), offset);
  }

  factory NgSimpleToken.whitespace(int offset, String lexeme) {
    return new NgSimpleToken(new NgSimpleTokenType.whitespace(lexeme), offset);
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
