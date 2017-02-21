// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/parser/reader.dart';
import 'package:angular_ast/src/scanner.dart';

abstract class RecoveryProtocol {
  RecoverySolution hasError(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution isEndOfFile(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanAfterComment(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanAfterElementDecorator(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanAfterElementDecoratorValue(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanAfterElementIdentifierClose(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanAfterElementIdentifierOpen(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanAfterInterpolation(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanBeforeElementDecorator(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanBeforeInterpolation(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanCloseElementEnd(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanComment(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanInterpolation(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanElementDecorator(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanElementDecoratorValue(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanElementEndClose(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanElementEndOpen(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanElementIdentifierClose(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanElementIdentifierOpen(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanOpenElementEnd(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanElementStart(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanSimpleElementDecorator(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanSpecialBananaDecorator(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanSpecialEventDecorator(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanSpecialPropertyDecorator(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanStart(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanSuffixBanana(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanSuffixEvent(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanSuffixProperty(
      NgSimpleToken current, NgTokenReversibleReader reader);

  RecoverySolution scanText(
      NgSimpleToken current, NgTokenReversibleReader reader);
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
