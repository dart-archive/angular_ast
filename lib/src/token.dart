// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library angular_ast.src.token;

import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

part 'token/lexeme.dart';
part 'token/type.dart';

/// Represents a section of parsed text from an Angular template.
///
/// Clients should not extend, implement, or mix-in this class.
class NgToken {
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

  factory NgToken.openElementEnd(int offset) {
    return new NgToken._(NgTokenType.openElementEnd, offset);
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
  int get end => offset + length;

  /// Number of characters in this token.
  int get length => lexeme.length;

  /// What characters were scanned and represent this token.
  String get lexeme => type.lexeme;

  /// Indexed location where the token begins in the original source text.
  final int offset;

  /// Type of token scanned.
  final NgTokenType type;

  @override
  String toString() => '#$NgToken(${type._name}) {$offset:$lexeme}';
}
