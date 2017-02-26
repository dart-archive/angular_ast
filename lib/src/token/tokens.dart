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
  bool get errorSynthetic;
}

/// Represents string tokens that are of interest to the parser.
///
/// Clients should not extend, implement, or mix-in this class.
class NgSimpleToken implements NgBaseToken {
  static final Map<NgSimpleTokenType, String> lexemeMap = {
    NgSimpleTokenType.bang: "!",
    NgSimpleTokenType.closeBanana: ")]",
    NgSimpleTokenType.closeBracket: "]",
    NgSimpleTokenType.closeParen: ")",
    NgSimpleTokenType.closeTagStart: "</",
    NgSimpleTokenType.commentBegin: "<!--",
    NgSimpleTokenType.commentEnd: "-->",
    NgSimpleTokenType.dash: "-",
    NgSimpleTokenType.openTagStart: "<",
    NgSimpleTokenType.tagEnd: ">",
    NgSimpleTokenType.EOF: "",
    NgSimpleTokenType.equalSign: "=",
    NgSimpleTokenType.forwardSlash: "/",
    NgSimpleTokenType.hash: "#",
    NgSimpleTokenType.identifier: "",
    NgSimpleTokenType.mustacheBegin: "{{",
    NgSimpleTokenType.mustacheEnd: "}}",
    NgSimpleTokenType.openBanana: "[(",
    NgSimpleTokenType.openBracket: "[",
    NgSimpleTokenType.openParen: "(",
    NgSimpleTokenType.period: ".",
    NgSimpleTokenType.star: "*",
    NgSimpleTokenType.text: "",
    NgSimpleTokenType.unexpectedChar: "@",
    NgSimpleTokenType.voidCloseTag: "/>",
    NgSimpleTokenType.whitespace: " ",
  };

  factory NgSimpleToken.generateErrorSynthetic(
      int offset, NgSimpleTokenType type) {
    return new NgSimpleToken._(type, offset, lexemeMap[type] ?? "",
        errorSynthetic: true);
  }

  factory NgSimpleToken.bang(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.bang, offset, '!');
  }

  factory NgSimpleToken.closeBanana(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.closeBanana, offset, ')]');
  }

  factory NgSimpleToken.closeBracket(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.closeBracket, offset, ']');
  }

  factory NgSimpleToken.closeParen(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.closeParen, offset, ')');
  }

  factory NgSimpleToken.closeTagStart(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.closeTagStart, offset, '</');
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

  factory NgSimpleToken.openTagStart(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.openTagStart, offset, '<');
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

  factory NgSimpleToken.mustacheBegin(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.mustacheBegin, offset, "{{");
  }

  factory NgSimpleToken.mustacheEnd(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.mustacheEnd, offset, "}}");
  }

  factory NgSimpleToken.openBanana(int offset) {
    return new NgSimpleToken._(NgSimpleTokenType.openBanana, offset, '[(');
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

  factory NgSimpleToken.voidCloseTag(int offset) {
    return new NgSimpleToken(NgSimpleTokenType.voidCloseTag, offset, "/>");
  }

  factory NgSimpleToken.whitespace(int offset, String lexeme) {
    return new NgSimpleToken(NgSimpleTokenType.whitespace, offset, lexeme);
  }

  const NgSimpleToken._(
    this.type,
    this.offset,
    this.lexeme, {
    bool errorSynthetic: false,
  })
      : errorSynthetic = errorSynthetic;

  NgSimpleToken(
    this.type,
    this.offset,
    this.lexeme, {
    bool errorSynthetic: false,
  })
      : errorSynthetic = errorSynthetic;

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
  int get length => errorSynthetic ? 0 : lexeme.length;

  @override
  final int offset;
  @override
  final NgSimpleTokenType type;
  @override
  final String lexeme;
  @override
  final bool errorSynthetic;

  @override
  String toString() => '#$NgSimpleToken(${type.name}) {$offset:$lexeme}';
}

class NgSimpleQuoteToken extends NgSimpleToken {
  factory NgSimpleQuoteToken.generateErrorSynthetic(
    int offset,
  ) {
    return new NgSimpleQuoteToken(
        NgSimpleTokenType.doubleQuote, offset, "", true,
        isErrorSynthetic: true);
  }

  factory NgSimpleQuoteToken.doubleQuotedText(
    int offset,
    String lexeme,
    bool isClosed,
  ) {
    return new NgSimpleQuoteToken(
        NgSimpleTokenType.doubleQuote, offset, lexeme, isClosed);
  }

  factory NgSimpleQuoteToken.singleQuotedText(
    int offset,
    String lexeme,
    bool isClosed, {
    bool errorSynthetic: false,
  }) {
    return new NgSimpleQuoteToken(
        NgSimpleTokenType.singleQuote, offset, lexeme, isClosed);
  }

  /// Offset of quote contents.
  final int contentOffset;

  /// String of just the contents
  final String contentLexeme;

  /// End of content
  int get contentEnd => contentOffset + contentLength;

  /// Offset of right quote; may be `null` to indicate unclosed.
  final int quoteEndOffset;

  NgSimpleQuoteToken(
      NgSimpleTokenType type, int offset, String lexeme, bool isClosed,
      {bool isErrorSynthetic: false})
      : contentOffset = offset + 1,
        contentLexeme = lexeme.isEmpty
            ? lexeme
            : lexeme.substring(
                1, (isClosed ? lexeme.length - 1 : lexeme.length)),
        quoteEndOffset = isClosed ? offset + lexeme.length - 1 : null,
        super(
          type,
          offset,
          lexeme,
          errorSynthetic: isErrorSynthetic,
        );

  @override
  bool operator ==(Object o) {
    if (o is NgSimpleQuoteToken) {
      return o.offset == offset &&
          o.type == type &&
          o.contentOffset == contentOffset &&
          o.quoteEndOffset == quoteEndOffset;
    }
    return false;
  }

  /// Lexeme including quotes.
  bool get isClosed => quoteEndOffset != null;
  int get contentLength => errorSynthetic ? 0 : contentLexeme.length;

  @override
  int get hashCode => hash4(super.hashCode, lexeme, contentOffset, end);

  @override
  String toString() => '#$NgSimpleQuoteToken(${type.name}) {$offset:$lexeme}';
}

/// Represents a Angular text/token entities.
///
/// Clients should not extend, implement, or mix-in this class.
class NgToken implements NgBaseToken {
  factory NgToken.generateErrorSynthetic(int offset, NgTokenType type,
      {String lexeme: ""}) {
    if (type == NgTokenType.beforeElementDecorator ||
        type == NgTokenType.elementDecoratorValue ||
        type == NgTokenType.elementDecorator ||
        type == NgTokenType.elementIdentifier ||
        type == NgTokenType.interpolationValue ||
        type == NgTokenType.text ||
        type == NgTokenType.whitespace ||
        type == NgTokenType.commentValue) {
      return new _LexemeNgToken(offset, lexeme, type, errorSynthetic: true);
    }
    return new NgToken._(type, offset, errorSynthetic: true);
  }

  factory NgToken.afterElementDecoratorValue(int offset) {
    return new NgToken._(NgTokenType.afterElementDecoratorValue, offset);
  }

  factory NgToken.bananaPrefix(int offset) {
    return new NgToken._(NgTokenType.bananaPrefix, offset);
  }

  factory NgToken.bananaSuffix(int offset) {
    return new NgToken._(NgTokenType.bananaSuffix, offset);
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

  factory NgToken.doubleQuote(int offset) {
    return new NgToken._(NgTokenType.doubleQuote, offset);
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

  factory NgToken.eventPrefix(int offset) {
    return new NgToken._(NgTokenType.eventPrefix, offset);
  }

  factory NgToken.eventSuffix(int offset) {
    return new NgToken._(NgTokenType.eventSuffix, offset);
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

  factory NgToken.propertyPrefix(int offset) {
    return new NgToken._(NgTokenType.propertyPrefix, offset);
  }

  factory NgToken.propertySuffix(int offset) {
    return new NgToken._(NgTokenType.propertySuffix, offset);
  }

  factory NgToken.referencePrefix(int offset) {
    return new NgToken._(NgTokenType.referencePrefix, offset);
  }

  factory NgToken.singleQuote(int offset) {
    return new NgToken._(NgTokenType.singleQuote, offset);
  }

  factory NgToken.templatePrefix(int offset) {
    return new NgToken._(NgTokenType.templatePrefix, offset);
  }

  factory NgToken.text(int offset, String string) {
    return new _LexemeNgToken(offset, string, NgTokenType.text);
  }

  factory NgToken.whitespace(int offset, String string) {
    return new _LexemeNgToken(offset, string, NgTokenType.whitespace);
  }

  const NgToken._(this.type, this.offset, {bool errorSynthetic: false})
      : errorSynthetic = errorSynthetic;

  @override
  bool operator ==(Object o) {
    if (o is NgToken) {
      if (this.errorSynthetic || o.errorSynthetic) {
        return o.offset == offset && o.type.name == type.name;
      }
      return o.offset == offset &&
          o.type.name == type.name &&
          o.type.lexeme == type.lexeme;
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
  int get length => errorSynthetic ? 0 : lexeme.length;

  /// What characters were scanned and represent this token.
  @override
  String get lexeme => type.lexeme;

  /// Indexed location where the token begins in the original source text.
  @override
  final int offset;

  /// Type of token scanned.
  @override
  final NgTokenType type;

  /// Indicates synthetic token generated from error.
  @override
  final bool errorSynthetic;

  @override
  String toString() => '#$NgToken(${type.name}) {$offset:$lexeme}';
}

class NgAttributeValueToken extends NgToken {
  factory NgAttributeValueToken.generate(
      NgToken leftQuote, NgToken innerValue, NgToken rightQuote) {
    return new NgAttributeValueToken._(
        leftQuote.offset, leftQuote, innerValue, rightQuote);
  }

  final NgToken leftQuote;
  final NgToken innerValue;
  final NgToken rightQuote;

  bool get containsErrorSynthetic =>
      leftQuote.errorSynthetic ||
      innerValue.errorSynthetic ||
      rightQuote.errorSynthetic;

  const NgAttributeValueToken._(
      offset, this.leftQuote, this.innerValue, this.rightQuote)
      : super._(NgTokenType.elementDecoratorValue, offset);

  @override
  bool operator ==(Object o) {
    if (o is NgAttributeValueToken) {
      return leftQuote == o.leftQuote &&
          rightQuote == o.rightQuote &&
          innerValue == o.innerValue;
    }
    return false;
  }

  @override
  int get hashCode => hash3(leftQuote, innerValue, rightQuote);

  @override
  int get end => rightQuote.end;

  @override
  int get length => leftQuote.length + innerValue.length + rightQuote.length;

  @override
  String get lexeme => leftQuote.lexeme + innerValue.lexeme + rightQuote.lexeme;

  @override
  String toString() =>
      '#$NgAttributeValueToken(${type.name}) {$offset:$lexeme} '
      '[\n\t$leftQuote,\n\t$innerValue,\n\t$rightQuote]';

  bool get isDoubleQuote => leftQuote.type == NgTokenType.doubleQuote;
  bool get isSingleQuote => leftQuote.type == NgTokenType.singleQuote;
}
