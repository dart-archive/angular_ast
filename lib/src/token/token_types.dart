// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of angular_ast.src.token.tokens;

abstract class NgBaseTokenType {
  String get name;
}

/// The types of tokens that can be returned by the NgStringTokenizer
///
/// Clients may not extend, implement, or mix-in this class.
class NgSimpleTokenType implements NgBaseTokenType {
  static const bang = const NgSimpleTokenType._('bang');

  static const closeBanana = const NgSimpleTokenType._('closeBanana');

  static const closeBrace = const NgSimpleTokenType._('closeBrace');

  static const closeBracket = const NgSimpleTokenType._('closeBracket');

  static const closeParen = const NgSimpleTokenType._('closeParen');

  static const closeTagStart = const NgSimpleTokenType._('closeTagStart');

  static const commentBegin = const NgSimpleTokenType._('commentBegin');

  static const commentEnd = const NgSimpleTokenType._('commentEnd');

  static const dash = const NgSimpleTokenType._('dash');

  static const doubleQuote = const NgSimpleTokenType._('doubleQuote');

  static const openTagStart = const NgSimpleTokenType._('openTagStart');

  static const tagEnd = const NgSimpleTokenType._('tagEnd');

  static const equalSign = const NgSimpleTokenType._('equalSign');

  static const EOF = const NgSimpleTokenType._('EOF');

  static const forwardSlash = const NgSimpleTokenType._('forwardSlash');

  static const hash = const NgSimpleTokenType._('hash');

  static const identifier = const NgSimpleTokenType._('identifier');

  static const mustacheBegin = const NgSimpleTokenType._('mustacheBegin');

  static const mustacheEnd = const NgSimpleTokenType._('mustacheEnd');

  static const openBanana = const NgSimpleTokenType._('openBanana');

  static const openBrace = const NgSimpleTokenType._('openBrace');

  static const openBracket = const NgSimpleTokenType._('openBracket');

  static const openParen = const NgSimpleTokenType._('openParen');

  static const period = const NgSimpleTokenType._('period');

  static const singleQuote = const NgSimpleTokenType._('singleQuote');

  static const star = const NgSimpleTokenType._('star');

  static const text = const NgSimpleTokenType._('text');

  static const unexpectedChar = const NgSimpleTokenType._('unexpectedChar');

  static const voidCloseTag = const NgSimpleTokenType._('voidCloseTag');

  static const whitespace = const NgSimpleTokenType._('whitespace');

  const NgSimpleTokenType._(this.name);

  NgSimpleTokenType(this.name);

  @override
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

/// The types of tokens that can be returned by the NgScanner.
///
/// Clients may not extend, implement, or mix-in this class.
class NgTokenType implements NgBaseTokenType {
  /// Represents `"`.
  static const afterElementDecoratorValue = const NgTokenType._(
    'afterElementDecoratorValue',
    lexeme: '"',
  );

  /// Represents '[('
  static const bananaPrefix = const NgTokenType._('bananaPrefix', lexeme: '[(');

  /// Represents ')]'
  static const bananaSuffix = const NgTokenType._('bananaSuffix', lexeme: ')]');

  /// Represents whitespace before an attribute, event, or property binding.
  static const beforeElementDecorator = const NgTokenType._(
    'beforeElementDecorator',
  );

  /// Represents `=`.
  static const beforeElementDecoratorValue = const NgTokenType._(
    'beforeElementDecoratorValue',
    lexeme: '=',
  );

  /// Represents ending closing an element declaration.
  static const closeElementEnd = const NgTokenType._(
    'closeElementEnd',
    lexeme: '>',
  );

  /// Represents starting closing an element declaration.
  static const closeElementStart = const NgTokenType._(
    'closeElementStart',
    lexeme: '</',
  );

  /// Represents ending a comment.
  static const commentEnd = const NgTokenType._(
    'commentEnd',
    lexeme: '-->',
  );

  /// Represents starting a comment.
  static const commentStart = const NgTokenType._(
    'commentStart',
    lexeme: '<!--',
  );

  /// Represents a comment value.
  static const commentValue = const NgTokenType._('commentValue');

  /// Represents "
  static const doubleQuote = const NgTokenType._('doubleQuote', lexeme: '"');

  /// Represents the name of an attribute element decorator.
  static const elementDecorator = const NgTokenType._('elementDecorator');

  /// Represents the value of an element decorator.
  static const elementDecoratorValue = const NgTokenType._(
    'elementDecoratorValue',
  );

  /// Represents the name of an element.
  static const elementIdentifier = const NgTokenType._('elementIdentifier');

  /// Represents '('
  static const eventPrefix = const NgTokenType._('eventPrefix', lexeme: '(');

  /// Represents ')'
  static const eventSuffix = const NgTokenType._('eventSuffix', lexeme: ')');

  /// Represents ending an interpolated text block.
  static const interpolationEnd = const NgTokenType._(
    'interpolationEnd',
    lexeme: '}}',
  );

  /// Represents starting an interpolated text block.
  static const interpolationStart = const NgTokenType._(
    'interpolationStart',
    lexeme: '{{',
  );

  /// Represnts an interpolated text block.
  static const interpolationValue = const NgTokenType._(
    'interpolationValue',
  );

  /// Represents ending opening an element declaration.
  static const openElementEnd = const NgTokenType._(
    'openElementEnd',
    lexeme: '>',
  );

  /// Represents ending opening an element declaration, with no inner content.
  static const openElementEndVoid = const NgTokenType._(
    'openElementEndVoid',
    lexeme: '/>',
  );

  /// Represents starting opening an element declaration.
  static const openElementStart = const NgTokenType._(
    'openElementStart',
    lexeme: '<',
  );

  /// Represents '['
  static const propertyPrefix =
      const NgTokenType._('propertyPrefix', lexeme: '[');

  /// Represents ']'
  static const propertySuffix =
      const NgTokenType._('propertySuffix', lexeme: ']');

  /// Represents '#'
  static const referencePrefix =
      const NgTokenType._('referencePrefix', lexeme: '#');

  /// Represents '
  static const singleQuote = const NgTokenType._('singleQuote', lexeme: "'");

  /// Represents '*'
  static const templatePrefix =
      const NgTokenType._('templatePrefix', lexeme: '*');

  /// Represents a text token.
  static const text = const NgTokenType._('text');

  /// Represents a whitespace token.
  static const whitespace = const NgTokenType._('whitespace');

  @override
  final String name;

  @literal
  const NgTokenType._(this.name, {this.lexeme});

  /// The lexeme that defines this type of token, or `null` if there is none.
  final String lexeme;

  @override
  String toString() => '#$NgTokenType {$name}';
}
