// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library angular_ast.src.token.tokens;

import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

part 'lexeme.dart';
part 'token_types.dart';

abstract class NgBaseToken {
  int get offset;
  int get end;
  int get length;
  String get lexeme;
  NgBaseTokenType get type;
}

/// Represents string tokens that are of interest to the parser.
///
/// Clients should not extend, implement, or mix-in this class.
class NgSimpleToken implements NgBaseToken {
  factory NgSimpleToken.bang(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.bang, offset, '!');
  }

  //Probably don't need
  factory NgSimpleToken.closeBrace(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.closeBrace, offset, '}');
  }

  factory NgSimpleToken.closeBracket(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.closeBracket, offset, ']');
  }

  factory NgSimpleToken.closeParen(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.closeParen, offset, ')');
  }

  factory NgSimpleToken.commentBegin(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.commentBegin, offset, '<!--');
  }

  factory NgSimpleToken.commentEnd(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.commentEnd, offset, '-->');
  }

  factory NgSimpleToken.dash(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.dash, offset, '-');
  }

  factory NgSimpleToken.dashedIdentifier(int offset, String lexeme) {
    return new NgSimpleToken(
        NgSimpleTokenType.dashedIdentifier, offset, lexeme);
  }

  factory NgSimpleToken.tagStart(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.tagStart, offset, '<');
  }

  factory NgSimpleToken.tagEnd(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.tagEnd, offset, '>');
  }

  factory NgSimpleToken.EOF(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.EOF, offset, '');
  }

  factory NgSimpleToken.equalSign(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.equalSign, offset, '=');
  }

  factory NgSimpleToken.forwardSlash(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.forwardSlash, offset, '/');
  }

  factory NgSimpleToken.hash(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.hash, offset, '#');
  }

  factory NgSimpleToken.identifier(int offset, String lexeme) {
    return new NgSimpleToken(NgSimpleTokenType.identifier, offset, lexeme);
  }

  //Probably don't need
  factory NgSimpleToken.openBrace(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.openBrace, offset, '{');
  }

  factory NgSimpleToken.openBracket(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.openBracket, offset, '[');
  }

  factory NgSimpleToken.openParen(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.openParen, offset, '(');
  }

  factory NgSimpleToken.period(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.period, offset, '.');
  }

  factory NgSimpleToken.star(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.star, offset, '*');
  }

  factory NgSimpleToken.text(int offset, String lexeme) {
    return new NgSimpleToken(NgSimpleTokenType.text, offset, lexeme);
  }

  factory NgSimpleToken.unexpectedChar(int offset, String lexeme) {
    return new NgSimpleToken(NgSimpleTokenType.unexpectedChar, offset, lexeme);
  }

  factory NgSimpleToken.whitespace(int offset, String lexeme) {
    return new NgSimpleToken(NgSimpleTokenType.whitespace, offset, lexeme);
  }

  const NgSimpleToken._(this.type, this.offset, this.lexeme);

  NgSimpleToken(this.type, this.offset, this.lexeme);

  @override
  bool operator ==(Object o) {
    if (o is NgSimpleToken) {
      return o.offset == offset && o.type == type;
    }
    return false;
  }

  @override
  int get hashCode => hash2(offset, type);
  @override
  int get end => offset + length;
  @override
  int get length => lexeme.length;

  @override
  final int offset;
  @override
  final NgSimpleTokenType type;
  @override
  final String lexeme;

  @override
  String toString() => '#$NgSimpleToken(${type.name}) {$offset:$lexeme}';
}

class NgSimpleQuoteToken extends NgSimpleToken {
  factory NgSimpleQuoteToken.doubleQuotedText(
      int offset, String lexeme, bool isClosed) {
    return new NgSimpleQuoteToken(
        NgSimpleTokenType.doubleQuote, offset, lexeme, isClosed);
  }

  factory NgSimpleQuoteToken.singleQuotedText(
      int offset, String lexeme, bool isClosed) {
    return new NgSimpleQuoteToken(
        NgSimpleTokenType.singleQuote, offset, lexeme, isClosed);
  }

  final int
      quoteOffset; //super.offset will be for text only; this is for Quote begin
  final int quoteEndOffset; //If null, indicated unclosed
  String _quotedLexeme;

  NgSimpleQuoteToken(
      NgSimpleTokenType type, this.quoteOffset, String lexeme, bool isClosed)
      : quoteEndOffset = (isClosed ? quoteOffset + lexeme.length : null),
        super(
            type,
            quoteOffset + 1,
            lexeme.substring(
                1, (isClosed ? lexeme.length - 1 : lexeme.length))) {
    _quotedLexeme = lexeme;
  }

  @override
  bool operator ==(Object o) {
    if (o is NgSimpleQuoteToken) {
      return o.offset == offset &&
          o.type == type &&
          o.quoteOffset == quoteOffset &&
          o.quoteEndOffset == quoteEndOffset;
    }
    return false;
  }

  String get quotedLexeme => _quotedLexeme;
  String get quote => (type == NgSimpleTokenType.doubleQuote) ? '"' : "'";
  bool get isClosed => quoteEndOffset != null;
  int get quotedLength => _quotedLexeme.length;

  @override
  int get hashCode => hash4(super.hashCode, lexeme, quoteOffset, end);

  @override
  String toString() =>
      '#$NgSimpleQuoteToken(${type.name}) {$quoteOffset:$quotedLexeme}';
}

/// Represents a Angular text/token entities.
///
/// Clients should not extend, implement, or mix-in this class.
class NgToken implements NgBaseToken {
  factory NgToken.afterElementDecoratorValue(int offset) {
    return new NgToken._(NgTokenType.afterElementDecoratorValue, offset);
  }

  factory NgToken.beforeElementDecorator(int offset, String string) {
    return new _LexemeNgToken(
      offset,
      string,
      NgTokenType.beforeElementDecorator,
    );
  }

  factory NgToken.beforeElementDecoratorValue(int offset) {
    return new NgToken._(NgTokenType.beforeElementDecoratorValue, offset);
  }

  factory NgToken.closeElementEnd(int offset) {
    return new NgToken._(NgTokenType.closeElementEnd, offset);
  }

  factory NgToken.closeElementStart(int offset) {
    return new NgToken._(NgTokenType.closeElementStart, offset);
  }

  factory NgToken.commentEnd(int offset) {
    return new NgToken._(NgTokenType.commentEnd, offset);
  }

  factory NgToken.commentStart(int offset) {
    return new NgToken._(NgTokenType.commentStart, offset);
  }

  factory NgToken.commentValue(int offset, String string) {
    return new _LexemeNgToken(offset, string, NgTokenType.commentValue);
  }

  factory NgToken.elementDecorator(int offset, String string) {
    return new _LexemeNgToken(offset, string, NgTokenType.elementDecorator);
  }

  factory NgToken.elementDecoratorValue(int offset, String string) {
    return new _LexemeNgToken(
      offset,
      string,
      NgTokenType.elementDecoratorValue,
    );
  }

  factory NgToken.elementIdentifier(int offset, String string) {
    return new _LexemeNgToken(offset, string, NgTokenType.elementIdentifier);
  }

  factory NgToken.interpolationEnd(int offset) {
    return new NgToken._(NgTokenType.interpolationEnd, offset);
  }

  factory NgToken.interpolationStart(int offset) {
    return new NgToken._(NgTokenType.interpolationStart, offset);
  }

  factory NgToken.interpolationValue(int offset, String string) {
    return new _LexemeNgToken(offset, string, NgTokenType.interpolationValue);
  }

  factory NgToken.openElementEnd(int offset) {
    return new NgToken._(NgTokenType.openElementEnd, offset);
  }

  factory NgToken.openElementEndVoid(int offset) {
    return new NgToken._(NgTokenType.openElementEndVoid, offset);
  }

  factory NgToken.openElementStart(int offset) {
    return new NgToken._(NgTokenType.openElementStart, offset);
  }

  factory NgToken.text(int offset, String string) {
    return new _LexemeNgToken(offset, string, NgTokenType.text);
  }

  const NgToken._(this.type, this.offset);

  @override
  bool operator ==(Object o) {
    if (o is NgToken) {
      return o.offset == offset && o.type == type;
    }
    return false;
  }

  @override
  int get hashCode => hash2(offset, type);

  /// Indexed location where the token ends in the original source text.
  @override
  int get end => offset + length;

  /// Number of characters in this token.
  @override
  int get length => lexeme.length;

  /// What characters were scanned and represent this token.
  @override
  String get lexeme => type.lexeme;

  /// Indexed location where the token begins in the original source text.
  @override
  final int offset;

  /// Type of token scanned.
  @override
  final NgTokenType type;

  @override
  String toString() => '#$NgToken(${type.name}) {$offset:$lexeme}';
}
