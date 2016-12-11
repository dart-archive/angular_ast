// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
part of angular_ast.src.token;

/// The types of tokens that can be returned by the scanner.
///
/// Clients may not extend, implement, or mix-in this class.
class NgTokenType {
  /// Represents `"`.
  static const afterElementDecoratorValue = const NgTokenType._(
    'afterElementDecoratorValue',
    lexeme: '"',
  );

  /// Represents whitespace before an attribute, event, or property binding.
  static const beforeElementDecorator = const NgTokenType._(
    'beforeElementDecorator',
  );

  /// Represents `="`.
  static const beforeElementDecoratorValue = const NgTokenType._(
    'beforeElementDecoratorValue',
    lexeme: '="',
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

  /// Represents the name of an element decorator.
  static const elementDecorator = const NgTokenType._('elementDecorator');

  /// Represents the value of an element decorator.
  static const elementDecoratorValue = const NgTokenType._(
    'elementDecoratorValue',
  );

  /// Represents the name of an element.
  static const elementIdentifier = const NgTokenType._('elementIdentifier');

  /// Represents ending opening an element declaration.
  static const openElementEnd = const NgTokenType._(
    'openElementEnd',
    lexeme: '>',
  );

  /// Represents starting opening an element declaration.
  static const openElementStart = const NgTokenType._(
    'openElementStart',
    lexeme: '<',
  );

  /// Represents a text token.
  static const text = const NgTokenType._('text');

  final String _name;

  @literal
  const NgTokenType._(this._name, {this.lexeme});

  /// The lexeme that defines this type of token, or `null` if there is none.
  final String lexeme;

  @override
  String toString() => '#$NgTokenType {$_name}';
}