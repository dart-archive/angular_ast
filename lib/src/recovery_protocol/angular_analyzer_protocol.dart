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
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution isEndOfFile(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }

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
    return new RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanAfterElementDecorator(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    // TODO Merge with both scanAfterIdentifier
    NgScannerState returnState;
    NgToken returnToken;
    NgSimpleTokenType type = current.type;
    int offset = current.offset;

    if (type == NgSimpleTokenType.openBracket ||
        type == NgSimpleTokenType.openParen ||
        type == NgSimpleTokenType.openBanana ||
        type == NgSimpleTokenType.hash ||
        type == NgSimpleTokenType.star) {
      reader.putBack(current);
      returnState = NgScannerState.scanElementDecorator;
      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.beforeElementDecorator,
          lexeme: " ");
    } else if (type == NgSimpleTokenType.closeBracket) {
      reader.putBack(current);
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          offset, NgSimpleTokenType.identifier));
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          offset, NgSimpleTokenType.openBracket));
      returnState = NgScannerState.scanElementDecorator;
      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.beforeElementDecorator,
          lexeme: " ");
    } else if (type == NgSimpleTokenType.closeParen) {
      reader.putBack(current);
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          offset, NgSimpleTokenType.identifier));
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          offset, NgSimpleTokenType.openParen));
      returnState = NgScannerState.scanElementDecorator;
      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.beforeElementDecorator,
          lexeme: " ");
    } else if (type == NgSimpleTokenType.closeBanana) {
      reader.putBack(current);
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          offset, NgSimpleTokenType.identifier));
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          offset, NgSimpleTokenType.openBanana));
      returnState = NgScannerState.scanElementDecorator;
      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.beforeElementDecorator,
          lexeme: " ");
    } else if (type == NgSimpleTokenType.EOF ||
        type == NgSimpleTokenType.commentBegin ||
        type == NgSimpleTokenType.openTagStart ||
        type == NgSimpleTokenType.closeTagStart) {
      reader.putBack(current);
      returnState = NgScannerState.scanStart;
      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.openElementEnd);
    } else if (current is NgSimpleQuoteToken) {
      reader.putBack(current);
      returnState = NgScannerState.scanElementDecoratorValue;
      returnToken = new NgToken.generateErrorSynthetic(
          current.quoteOffset, NgTokenType.beforeElementDecoratorValue);
    }
    return new RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanAfterElementDecoratorValue(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    // TODO Merge with both scanAfterIdentifier
    NgScannerState returnState;
    NgToken returnToken;
    NgSimpleTokenType type = current.type;
    int offset = current.offset;

    if (type == NgSimpleTokenType.openBracket ||
        type == NgSimpleTokenType.openParen ||
        type == NgSimpleTokenType.openBanana ||
        type == NgSimpleTokenType.hash ||
        type == NgSimpleTokenType.star ||
        type == NgSimpleTokenType.identifier) {
      reader.putBack(current);
      returnState = NgScannerState.scanElementDecorator;
      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.beforeElementDecorator,
          lexeme: ' ');
    } else if (type == NgSimpleTokenType.closeBracket) {
      reader.putBack(current);
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          offset, NgSimpleTokenType.identifier));
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          offset, NgSimpleTokenType.openBracket));

      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.beforeElementDecorator,
          lexeme: ' ');
      returnState = NgScannerState.scanElementDecorator;
    } else if (type == NgSimpleTokenType.closeParen) {
      reader.putBack(current);
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          offset, NgSimpleTokenType.identifier));
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          offset, NgSimpleTokenType.openParen));
      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.beforeElementDecorator,
          lexeme: ' ');
      returnState = NgScannerState.scanElementDecorator;
    } else if (type == NgSimpleTokenType.closeBanana) {
      reader.putBack(current);
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          offset, NgSimpleTokenType.identifier));
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          offset, NgSimpleTokenType.openBanana));
      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.beforeElementDecorator,
          lexeme: ' ');
      returnState = NgScannerState.scanElementDecorator;
    } else if (type == NgSimpleTokenType.EOF ||
        type == NgSimpleTokenType.commentBegin ||
        type == NgSimpleTokenType.openTagStart ||
        type == NgSimpleTokenType.closeTagStart) {
      reader.putBack(current);
      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.openElementEnd);
      returnState = NgScannerState.scanStart;
    } else if (type == NgSimpleTokenType.equalSign) {
      reader.putBack(current);
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          offset, NgSimpleTokenType.identifier));
      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.beforeElementDecorator,
          lexeme: ' ');
      returnState = NgScannerState.scanElementDecorator;
    } else if (current is NgSimpleQuoteToken) {
      reader.putBack(current);
      reader.putBack(new NgSimpleToken.generateErrorSynthetic(
          current.quoteOffset, NgSimpleTokenType.identifier));

      returnToken = new NgToken.generateErrorSynthetic(
          current.quoteOffset, NgTokenType.beforeElementDecorator,
          lexeme: ' ');
      returnState = NgScannerState.scanElementDecorator;
    }

    return new RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanAfterElementIdentifierClose(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution scanAfterElementIdentifierOpen(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    NgScannerState returnState;
    NgToken returnToken;
    NgSimpleTokenType type = current.type;
    int offset = current.offset;

    if (type == NgSimpleTokenType.openBracket ||
        type == NgSimpleTokenType.openParen ||
        type == NgSimpleTokenType.openBanana ||
        type == NgSimpleTokenType.hash ||
        type == NgSimpleTokenType.star ||
        type == NgSimpleTokenType.equalSign ||
        type == NgSimpleTokenType.closeBracket ||
        type == NgSimpleTokenType.closeParen ||
        type == NgSimpleTokenType.closeBanana) {
      reader.putBack(current);
      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.beforeElementDecorator,
          lexeme: " ");
      returnState = NgScannerState.scanElementDecorator;
    } else if (type == NgSimpleTokenType.commentBegin ||
        type == NgSimpleTokenType.openTagStart ||
        type == NgSimpleTokenType.closeTagStart ||
        type == NgSimpleTokenType.tagEnd ||
        type == NgSimpleTokenType.EOF) {
      reader.putBack(current);
      returnToken = new NgToken.generateErrorSynthetic(
          current.offset, NgTokenType.openElementEnd);
      returnState = NgScannerState.scanStart;
    } else if (current is NgSimpleQuoteToken) {
      reader.putBack(current);
      returnToken = new NgToken.generateErrorSynthetic(
          current.quoteOffset, NgTokenType.beforeElementDecorator,
          lexeme: " ");
      returnState = NgScannerState.scanElementDecorator;
    }

    return new RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanAfterInterpolation(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution scanBeforeElementDecorator(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    // Transient
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution scanBeforeInterpolation(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution scanCloseElementEnd(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution scanComment(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution scanInterpolation(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution scanElementDecorator(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    NgScannerState returnState;
    NgToken returnToken;
    NgSimpleTokenType type = current.type;
    int offset = current.offset;

    if (type == NgSimpleTokenType.equalSign) {
      reader.putBack(current);
      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.elementDecorator);
      returnState = NgScannerState.scanAfterElementDecorator;
    } else if (current is NgSimpleQuoteToken) {
      reader.putBack(current);
      returnToken = new NgToken.generateErrorSynthetic(
          current.quoteOffset, NgTokenType.elementDecorator);
      returnState = NgScannerState.scanAfterElementDecorator;
    } else if (type == NgSimpleTokenType.closeBracket ||
        type == NgSimpleTokenType.closeParen ||
        type == NgSimpleTokenType.closeBanana) {
      NgTokenType leftsideTokenType;
      NgToken suffix;
      if (type == NgSimpleTokenType.closeBracket) {
        leftsideTokenType = NgTokenType.propertyPrefix;
        suffix = new NgToken.propertySuffix(offset);
      } else if (type == NgSimpleTokenType.closeParen) {
        leftsideTokenType = NgTokenType.eventPrefix;
        suffix = new NgToken.eventSuffix(offset);
      } else {
        leftsideTokenType = NgTokenType.bananaPrefix;
        suffix = new NgToken.bananaSuffix(offset);
      }

      NgToken identifier = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.elementDecorator);
      NgToken prefix =
          new NgToken.generateErrorSynthetic(offset, leftsideTokenType);
      returnToken =
          new NgSpecialAttributeToken.generate(prefix, identifier, suffix);
      returnState = NgScannerState.scanAfterElementDecorator;
    }

    return new RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanElementDecoratorValue(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution scanElementEndClose(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution scanElementEndOpen(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution scanElementIdentifierClose(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution scanElementIdentifierOpen(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    NgScannerState returnState;
    NgToken returnToken;
    NgSimpleTokenType type = current.type;
    int offset = current.offset;

    if (type == NgSimpleTokenType.bang ||
        type == NgSimpleTokenType.dash ||
        type == NgSimpleTokenType.period) {
      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.elementIdentifier);
      returnState = NgScannerState.scanAfterElementIdentifierOpen;
    } else if (type == NgSimpleTokenType.openBracket ||
        type == NgSimpleTokenType.openParen ||
        type == NgSimpleTokenType.openBanana ||
        type == NgSimpleTokenType.hash ||
        type == NgSimpleTokenType.star ||
        type == NgSimpleTokenType.closeBracket ||
        type == NgSimpleTokenType.closeParen ||
        type == NgSimpleTokenType.closeBanana ||
        type == NgSimpleTokenType.commentBegin ||
        type == NgSimpleTokenType.commentEnd ||
        type == NgSimpleTokenType.openTagStart ||
        type == NgSimpleTokenType.closeTagStart ||
        type == NgSimpleTokenType.tagEnd ||
        type == NgSimpleTokenType.EOF ||
        type == NgSimpleTokenType.equalSign) {
      reader.putBack(current);
      returnToken = new NgToken.generateErrorSynthetic(
          offset, NgTokenType.elementIdentifier);
      returnState = NgScannerState.scanAfterElementIdentifierOpen;
    } else if (current is NgSimpleQuoteToken) {
      reader.putBack(current);
      returnToken = new NgToken.generateErrorSynthetic(
          current.quoteOffset, NgTokenType.elementIdentifier);
      returnState = NgScannerState.scanAfterElementIdentifierOpen;
    }
    return new RecoverySolution(returnState, returnToken);
  }

  @override
  RecoverySolution scanOpenElementEnd(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution scanElementStart(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution scanStart(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    // Transient
    return new RecoverySolution.skip();
  }

  @override
  RecoverySolution scanText(
      NgSimpleToken current, NgTokenReversibleReader reader) {
    return new RecoverySolution.skip();
  }
}
