// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/parser/reader.dart';
import 'package:angular_ast/src/scanner.dart';

abstract class RecoveryProtocol {
  RecoverySolution hasError(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution isEndOfFile(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanAfterComment(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanAfterElementDecorator(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanAfterElementDecoratorValue(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanAfterInterpolation(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanBeforeElementDecorator(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanBeforeInterpolation(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanCloseElementEnd(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanComment(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanInterpolation(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanElementDecorator(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanElementDecoratorValue(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanElementIdentifierClose(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanElementIdentifierOpen(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanOpenElementEnd(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanElementStart(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanStart(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();

  RecoverySolution scanText(
          NgSimpleToken current, NgTokenReversibleReader reader) =>
      new RecoverySolution.skip();
}

/// Setting nextState as `null` causes scanner to retain original state.
/// Setting tokenToReturn as `null` causes scanner to consume _current token
/// and simply move to next token.
class RecoverySolution {
  final NgScannerState nextState;
  final NgToken tokenToReturn;

  RecoverySolution(this.nextState, this.tokenToReturn);

  factory RecoverySolution.skip() => new RecoverySolution(null, null);
}
