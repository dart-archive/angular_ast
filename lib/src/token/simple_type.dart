// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of angular_ast.src.simple_token;

class NgSimpleTokenType {
  static const bang = const NgSimpleTokenType._('bang');

  //probably not needed
  static const closeBrace = const NgSimpleTokenType._('closeBrace');

  static const closeBracket = const NgSimpleTokenType._('closeBracket');

  static const closeParen = const NgSimpleTokenType._('closeParen');

  static const commentBegin = const NgSimpleTokenType._('commentBegin');

  static const commentEnd = const NgSimpleTokenType._('commentEnd');

  static const dash = const NgSimpleTokenType._('dash');

  static const doubleQuote = const NgSimpleTokenType._('doubleQuote');

  static const tagStart = const NgSimpleTokenType._(
    'tagStart',
  );

  static const tagEnd = const NgSimpleTokenType._('tagEnd');

  static const equalSign = const NgSimpleTokenType._('equalSign');

  static const EOF = const NgSimpleTokenType._('EOF');

  static const forwardSlash = const NgSimpleTokenType._('forwardSlash');

  static const hash = const NgSimpleTokenType._('hash');

  //Probably not needed
  static const openBrace = const NgSimpleTokenType._('openBrace');

  static const openBracket = const NgSimpleTokenType._('openBracket');

  static const openParen = const NgSimpleTokenType._('openParen');

  static const singleQuote = const NgSimpleTokenType._('singleQuote');

  static const star = const NgSimpleTokenType._('star');

  NgSimpleTokenType.doubleQuotedText() : this.name = 'doubleQuotedText';

  NgSimpleTokenType.singleQuotedText() : this.name = 'singleQuotedText';

  NgSimpleTokenType.text() : this.name = 'text';

  NgSimpleTokenType.unexpectedChar() : this.name = 'unexpectedChar';

  NgSimpleTokenType.whitespace() : this.name = 'whitespace';

  const NgSimpleTokenType._(this.name);

  NgSimpleTokenType(this.name);

  final String name;

  @override
  String toString() => '#$NgSimpleTokenType {$name}';

  @override
  bool operator ==(Object o) {
    if (o is NgSimpleTokenType) {
      return o.name == name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;
}
