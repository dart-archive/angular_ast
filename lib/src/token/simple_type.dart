// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of angular_ast.src.simple_token;

class NgSimpleTokenType {
  //probably not needed
  static const closeBrace =
      const NgSimpleTokenType._('closeBrace', lexeme: '}');

  static const closeBracket =
      const NgSimpleTokenType._('closeBracket', lexeme: ']');

  static const closeParen =
      const NgSimpleTokenType._('closeParen', lexeme: ')');

  static const commentBegin =
      const NgSimpleTokenType._('commentBegin', lexeme: '!--');

  static const commentEnd =
      const NgSimpleTokenType._('commendEnd', lexeme: '--');

  static const doubleQuote =
      const NgSimpleTokenType._('doubleQuote', lexeme: '"');

  static const elementStart = const NgSimpleTokenType._(
    'elementStart',
    lexeme: '<',
  );

  static const elementEnd =
      const NgSimpleTokenType._('elementEnd', lexeme: '>');

  static const elementEndVoid =
      const NgSimpleTokenType._('elementEndVoid', lexeme: '/>');

  static const equalSign = const NgSimpleTokenType._('equalSign', lexeme: '=');

  static const EOF = const NgSimpleTokenType._('EOF', lexeme: '');

  static const forwardSlash =
      const NgSimpleTokenType._('forwardSlash', lexeme: '/');

  static const hash = const NgSimpleTokenType._('hash', lexeme: '#');

  //Probably not needed
  static const openBrace = const NgSimpleTokenType._('openBrace', lexeme: '{');

  static const openBracket =
      const NgSimpleTokenType._('openBracket', lexeme: '[');

  static const openParen = const NgSimpleTokenType._('openParen', lexeme: '(');

  static const singleQuote =
      const NgSimpleTokenType._('singleQuote', lexeme: "'");

  NgSimpleTokenType.textType(this.lexeme) : this.name = 'text';

  NgSimpleTokenType.unexpectedChar(this.lexeme) : this.name = 'unexpectedChar';

  NgSimpleTokenType.whitespaceType(this.lexeme) : this.name = 'whitespace';

  const NgSimpleTokenType._(this.name, {this.lexeme});

  NgSimpleTokenType(this.name, this.lexeme);

  final String name;
  final String lexeme;

  @override
  String toString() => '#$NgSimpleTokenType {$name}';

  @override
  bool operator ==(Object o) {
    if (o is NgSimpleTokenType) {
      return o.name == name && o.lexeme == lexeme;
    }
    return false;
  }

  @override
  int get hashCode => hash2(name, lexeme);
}
