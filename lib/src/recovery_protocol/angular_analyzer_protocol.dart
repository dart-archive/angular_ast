// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/parser/reader.dart';
import 'package:angular_ast/src/scanner.dart';
import 'package:angular_ast/src/recovery_protocol/recovery_protocol.dart';

class NgAnalyzerRecoveryProtocol implements RecoveryProtocol {
  @override
  RecoverySolution hasError(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution isEndOfFile(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution scanAfterComment(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    NgScannerState returnState;
    NgToken returnToken;

    if (current.type == NgSimpleTokenType.EOF) {
      reader.putBack(current);
      returnState = NgScannerState.scanStart;
      returnToken = new NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.commentEnd);
      return new RecoverySolution(returnState, returnToken);
    }

    return new RecoverySolution(null, null);
  }

  @override
  RecoverySolution scanAfterElementDecorator(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    NgScannerState returnState;
    NgToken returnToken;

    if (current.type == NgSimpleTokenType.openBracket ||
        current.type == NgSimpleTokenType.openParen ||
        current.type == NgSimpleTokenType.hash ||
        current.type == NgSimpleTokenType.star) {
      reader.putBack(current);
      returnState = NgScannerState.scanElementDecorator;
      returnToken = new NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.beforeElementDecorator,
          lexeme: " ");
      return new RecoverySolution(returnState, returnToken);
    }
    if (current.type == NgSimpleTokenType.closeBracket) {
      reader.putBack(current);
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          current.offset, NgSimpleTokenType.identifier));
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          current.offset, NgSimpleTokenType.openBracket));
      returnState = NgScannerState.scanElementDecorator;
      returnToken = new NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.beforeElementDecorator,
          lexeme: " ");
      return new RecoverySolution(returnState, returnToken);
    }
    if (current.type == NgSimpleTokenType.closeParen) {
      reader.putBack(current);
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          current.offset, NgSimpleTokenType.identifier));
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          current.offset, NgSimpleTokenType.openParen));
      returnState = NgScannerState.scanElementDecorator;
      returnToken = new NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.beforeElementDecorator,
          lexeme: " ");
      return new RecoverySolution(returnState, returnToken);
    }
    if (current.type == NgSimpleTokenType.EOF ||
        current.type == NgSimpleTokenType.commentBegin ||
        current.type == NgSimpleTokenType.tagStart) {
      reader.putBack(current);
      returnState = NgScannerState.scanStart;
      returnToken = new NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.openElementEnd);
      return new RecoverySolution(returnState, returnToken);
    }
    if (current is NgSimpleQuoteToken) {
      reader.putBack(current);
      returnState = NgScannerState.scanElementDecoratorValue;
      returnToken = new NgToken.generateErrorSynthetic(
          current.quoteOffset, NgTokenType.beforeElementDecoratorValue);
      return new RecoverySolution(returnState, returnToken);
    }
    return new RecoverySolution(null, null);
  }

  @override
  RecoverySolution scanAfterElementDecoratorValue(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    NgScannerState returnState;
    NgToken returnToken;

    if (current.type == NgSimpleTokenType.openBracket ||
        current.type == NgSimpleTokenType.openParen ||
        current.type == NgSimpleTokenType.hash ||
        current.type == NgSimpleTokenType.star) {
      reader.putBack(current);
      returnState = NgScannerState.scanElementDecorator;
      returnToken = new NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.beforeElementDecorator,
          lexeme: ' ');
      return new RecoverySolution(returnState, returnToken);
    }
    if (current.type == NgSimpleTokenType.closeBracket) {
      reader.putBack(current);
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          current.offset, NgSimpleTokenType.identifier));
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          current.offset, NgSimpleTokenType.openBracket));

      returnToken = new NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.beforeElementDecorator,
          lexeme: ' ');
      returnState = NgScannerState.scanElementDecorator;
      return new RecoverySolution(returnState, returnToken);
    }
    if (current.type == NgSimpleTokenType.closeParen) {
      reader.putBack(current);
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          current.offset, NgSimpleTokenType.identifier));
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          current.offset, NgSimpleTokenType.openParen));

      returnToken = new NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.beforeElementDecorator,
          lexeme: ' ');
      returnState = NgScannerState.scanElementDecorator;
      return new RecoverySolution(returnState, returnToken);
    }
    if (current.type == NgSimpleTokenType.EOF ||
        current.type == NgSimpleTokenType.commentBegin ||
        current.type == NgSimpleTokenType.tagStart) {
      reader.putBack(current);

      returnToken = new NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.openElementEnd);
      returnState = NgScannerState.scanStart;
      return new RecoverySolution(returnState, returnToken);
    }
    if (current is NgSimpleQuoteToken) {
      reader.putBack(current);
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          current.quoteOffset, NgSimpleTokenType.equalSign));
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          current.quoteOffset, NgSimpleTokenType.identifier));

      returnToken = new NgToken.generateErrorSynthetic(
          current.quoteOffset, NgTokenType.beforeElementDecorator,
          lexeme: ' ');
      returnState = NgScannerState.scanElementDecorator;
      return new RecoverySolution(returnState, returnToken);
    }

    return new RecoverySolution(null, null);
  }

  @override
  RecoverySolution scanAfterInterpolation(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution scanBeforeElementDecorator(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution scanBeforeInterpolation(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution scanCloseElementEnd(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution scanComment(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution scanInterpolation(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution scanElementDecorator(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution scanElementDecoratorValue(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution scanElementIdentifierClose(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution scanElementIdentifierOpen(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution scanOpenElementEnd(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution scanElementStart(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution scanStart(
      NgSimpleToken current, NgTokenReversibleReader reader) {}

  @override
  RecoverySolution scanText(
      NgSimpleToken current, NgTokenReversibleReader reader) {}
}
