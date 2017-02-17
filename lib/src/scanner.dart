// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/simple_tokenizer.dart';
import 'package:angular_ast/src/parser/reader.dart';
import 'package:angular_ast/src/recovery_protocol/angular_analyzer_protocol.dart';
import 'package:angular_ast/src/recovery_protocol/recovery_protocol.dart';
import 'package:angular_ast/src/exception_handler/exception_handler.dart';
import 'package:meta/meta.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:source_span/source_span.dart';

/// A wrapper around [StringScanner] that scans tokens from an HTML string.
class NgScanner {
  static const _findAfterInterpolation = '}}';
  static const _findBeforeInterpolation = '{{';

  final NgTokenReversibleReader _reader;
  NgScannerState _state = NgScannerState.scanStart;
  final ExceptionHandler exceptionHandler;

  final bool _recoverErrors;
  RecoveryProtocol _rp = new NgAnalyzerRecoveryProtocol();

  NgSimpleToken _current;
  NgSimpleToken _lastToken;
  NgSimpleToken _lastErrorToken;

  NgSimpleToken _moveNext() {
    _lastToken = _current;
    _current = _reader.next();
    return _current;
  }

  NgSimpleToken _moveNextExpect(NgBaseTokenType type) {
    _lastToken = _current;
    _current = _reader.expect(type);
    return _current;
  }

  factory NgScanner(String html, ExceptionHandler exceptionHandler,
      {sourceUrl}) {
    NgTokenReader reader = new NgTokenReversibleReader(
        new SourceFile(html, url: sourceUrl),
        new NgSimpleTokenizer().tokenize(html));
    bool recoverError = exceptionHandler is RecoveringExceptionHandler;

    return new NgScanner._(reader, recoverError, exceptionHandler);
  }

  NgScanner._(this._reader, this._recoverErrors, this.exceptionHandler);

  /// Scans and returns the next token, or `null` if there is none more.
  NgToken scan() {
    _moveNext();
    NgToken returnToken;

    while (returnToken == null) {
      switch (_state) {
        case NgScannerState.hasError:
          throw new StateError('An error occurred');
        case NgScannerState.isEndOfFile:
          return null;
        case NgScannerState.scanAfterComment:
          returnToken = scanAfterComment();
          break;
        case NgScannerState.scanAfterElementDecorator:
          returnToken = scanAfterElementDecorator();
          break;
        case NgScannerState.scanAfterElementDecoratorValue:
          returnToken = scanAfterElementDecoratorValue();
          break;
        case NgScannerState.scanAfterElementIdentifierClose:
          returnToken = scanAfterElementIdentifierClose();
          break;
        case NgScannerState.scanAfterElementIdentifierOpen:
          returnToken = scanAfterElementIdentifierOpen();
          break;
        case NgScannerState.scanAfterInterpolation:
          returnToken = scanAfterInterpolation();
          break;
        case NgScannerState.scanBeforeElementDecorator:
          returnToken = scanBeforeElementDecorator();
          break;
        case NgScannerState.scanBeforeInterpolation:
          returnToken = scanBeforeInterpolation();
          break;
        case NgScannerState.scanElementEndClose:
          returnToken = scanElementEndClose();
          break;
        case NgScannerState.scanElementEndOpen:
          returnToken = scanElementEndOpen();
          break;
        case NgScannerState.scanComment:
          returnToken = scanComment();
          break;
        case NgScannerState.scanElementDecorator:
          returnToken = scanElementDecorator();
          break;
        case NgScannerState.scanElementDecoratorValue:
          returnToken = scanElementDecoratorValue();
          break;
        case NgScannerState.scanElementIdentifierClose:
          returnToken = scanElementIdentifier(wasOpenTag: false);
          break;
        case NgScannerState.scanElementIdentifierOpen:
          returnToken = scanElementIdentifier(wasOpenTag: true);
          break;
        case NgScannerState.scanElementStart:
          returnToken = scanElementStart();
          break;
        case NgScannerState.scanInterpolation:
          returnToken = scanInterpolation();
          break;
        case NgScannerState.scanStart:
          if (_current.type == NgSimpleTokenType.EOF && _reader.isDone) {
            _state = NgScannerState.isEndOfFile;
            return null;
          } else if (_current.type == NgSimpleTokenType.openTagStart ||
              _current.type == NgSimpleTokenType.closeTagStart) {
            // TODO: scan for <!-- in cases of it introduced in mid element
            returnToken = scanElementStart();
          } else if (_current.type == NgSimpleTokenType.commentBegin) {
            returnToken = scanBeforeComment();
          } else {
            returnToken = scanText();
          }
          break;
        case NgScannerState.scanText:
          returnToken = scanText();
          break;
      }
    }
    return returnToken;
  }

  @protected
  NgToken evaluateSpecialElementDecorator() {
    //TODO: Potentially make .identifier limit count unlimited?
    NgToken prefix;
    NgToken identifier;
    NgToken suffix;
    int identifierPartsLimit = 1; // Number of identifiers split by '.'

    // Prefix
    if (_current.type == NgSimpleTokenType.openParen) {
      // Event
      identifierPartsLimit = 1;
      prefix = new NgToken.eventPrefix(_current.offset);
    } else if (_current.type == NgSimpleTokenType.openBracket) {
      identifierPartsLimit = 2;
      prefix = new NgToken.propertyPrefix(_current.offset);
    } else if (_current.type == NgSimpleTokenType.openBanana) {
      identifierPartsLimit = 2;
      prefix = new NgToken.bananaPrefix(_current.offset);
    } else if (_current.type == NgSimpleTokenType.hash) {
      // Reference
      prefix = new NgToken.referencePrefix(_current.offset);
    } else if (_current.type == NgSimpleTokenType.star) {
      // Template
      prefix = new NgToken.templatePrefix(_current.offset);
    }

    // Identifier
    _moveNextExpect(NgSimpleTokenType.identifier);
    if (_current.errorSynthetic) {
      identifier = new NgToken.generateErrorSynthetic(
          _current.offset, NgTokenType.elementDecorator);
    } else if ((prefix.type == NgTokenType.propertyPrefix ||
            prefix.type == NgTokenType.eventPrefix) &&
        _reader.peekType() == NgSimpleTokenType.period) {
      int propertyBeginOffset = _current.offset;
      StringBuffer mergedLexeme = new StringBuffer();
      mergedLexeme.write(_current.lexeme);

      while (_reader.peekType() == NgSimpleTokenType.period &&
          identifierPartsLimit > 0) {
        _moveNext();
        _moveNextExpect(NgSimpleTokenType.identifier);
        mergedLexeme.write('.');
        mergedLexeme.write(_current.lexeme);
        identifierPartsLimit--;
      }
      identifier = new NgToken.elementDecorator(
          propertyBeginOffset, mergedLexeme.toString());
    } else {
      identifier =
          new NgToken.elementDecorator(_current.offset, _current.lexeme);
    }

    // Suffix
    if (prefix.type == NgTokenType.eventPrefix) {
      _moveNextExpect(NgSimpleTokenType.closeParen);
      if (_current.errorSynthetic) {
        suffix = new NgToken.generateErrorSynthetic(
            _current.offset, NgTokenType.eventSuffix);
      } else {
        suffix = new NgToken.eventSuffix(_current.offset);
      }
    } else if (prefix.type == NgTokenType.bananaPrefix) {
      _moveNextExpect(NgSimpleTokenType.closeBanana);
      if (_current.errorSynthetic) {
        suffix = new NgToken.generateErrorSynthetic(
            _current.offset, NgTokenType.bananaSuffix);
      } else {
        suffix = new NgToken.bananaSuffix(_current.offset);
      }
    } else if (prefix.type == NgTokenType.propertyPrefix) {
      _moveNextExpect(NgSimpleTokenType.closeBracket);
      if (_current.errorSynthetic) {
        suffix = new NgToken.generateErrorSynthetic(
            _current.offset, NgTokenType.propertySuffix);
      } else {
        suffix = new NgToken.propertySuffix(_current.offset);
      }
    }

    return new NgSpecialAttributeToken.generate(prefix, identifier, suffix);
  }

  @protected
  NgToken scanAfterComment() {
    if (_current.type == NgSimpleTokenType.commentEnd) {
      _state = NgScannerState.scanStart;
      return new NgToken.commentEnd(_current.offset);
    }
    return handleError();
  }

  @protected
  NgToken scanAfterElementDecorator() {
    if (_current.type == NgSimpleTokenType.equalSign) {
      _state = NgScannerState.scanElementDecoratorValue;
      return new NgToken.beforeElementDecoratorValue(_current.offset);
    } else if (_current.type == NgSimpleTokenType.tagEnd ||
        _current.type == NgSimpleTokenType.voidCloseTag) {
      return scanElementEndOpen();
    } else if (_current.type == NgSimpleTokenType.whitespace) {
      NgSimpleTokenType nextType = _reader.peekType();
      // Trailing whitespace check.
      if (nextType == NgSimpleTokenType.equalSign ||
          nextType == NgSimpleTokenType.voidCloseTag ||
          nextType == NgSimpleTokenType.tagEnd) {
        return new NgToken.whitespace(_current.offset, _current.lexeme);
      }
      return scanBeforeElementDecorator();
    }
    return handleError();
  }

  @protected
  NgToken scanAfterElementDecoratorValue() {
    if (_current.type == NgSimpleTokenType.tagEnd ||
        _current.type == NgSimpleTokenType.voidCloseTag) {
      return scanElementEndOpen();
    } else if (_current.type == NgSimpleTokenType.whitespace) {
      NgSimpleTokenType nextType = _reader.peekType();
      if (nextType == NgSimpleTokenType.voidCloseTag ||
          nextType == NgSimpleTokenType.tagEnd) {
        return new NgToken.whitespace(_current.offset, _current.lexeme);
      }
      return scanBeforeElementDecorator();
    }
    return handleError();
  }

  @protected
  NgToken scanAfterElementIdentifierClose() {
    if (_current.type == NgSimpleTokenType.whitespace) {
      _state = NgScannerState.scanElementEndClose;
      return new NgToken.whitespace(_current.offset, _current.lexeme);
    }
    if (_current.type == NgSimpleTokenType.tagEnd) {
      _state = NgScannerState.scanStart;
      return scanElementEndClose();
    }
    return handleError();
  }

  @protected
  NgToken scanAfterElementIdentifierOpen() {
    if (_current.type == NgSimpleTokenType.whitespace) {
      if (_reader.peek().type == NgSimpleTokenType.voidCloseTag ||
          _reader.peek().type == NgSimpleTokenType.tagEnd) {
        _state = NgScannerState.scanElementEndOpen;
        return new NgToken.whitespace(_current.offset, _current.lexeme);
      }
      _state = NgScannerState.scanElementDecorator;
      return scanBeforeElementDecorator();
    }
    if (_current.type == NgSimpleTokenType.voidCloseTag ||
        _current.type == NgSimpleTokenType.tagEnd) {
      return scanElementEndOpen();
    }
    return handleError();
  }

  @protected
  NgToken scanAfterInterpolation() {
    if (_current.type == NgSimpleTokenType.mustacheEnd) {
      _state = NgScannerState.scanStart;
      return new NgToken.interpolationEnd(_current.offset);
    }
    return handleError();
  }

  @protected
  NgToken scanBeforeComment() {
    if (_current.type == NgSimpleTokenType.commentBegin) {
      _state = NgScannerState.scanComment;
      return new NgToken.commentStart(_current.offset);
    }
    return handleError();
  }

  @protected
  NgToken scanBeforeElementDecorator() {
    if (_current.type == NgSimpleTokenType.whitespace) {
      if (_reader.peekType() == NgSimpleTokenType.voidCloseTag ||
          _reader.peekType() == NgSimpleTokenType.tagEnd) {
        _state = NgScannerState.scanAfterElementDecorator;
        return new NgToken.whitespace(_current.offset, _current.lexeme);
      }
      _state = NgScannerState.scanElementDecorator;
      return new NgToken.beforeElementDecorator(
          _current.offset, _current.lexeme);
    }
    return handleError();
  }

  @protected
  NgToken scanBeforeInterpolation() {
    if (_current.type == NgSimpleTokenType.mustacheBegin) {
      _state = NgScannerState.scanInterpolation;
      return new NgToken.interpolationStart(_current.offset);
    }
    return handleError();
  }

  @protected
  NgToken scanComment() {
    if (_current.type == NgSimpleTokenType.text) {
      _state = NgScannerState.scanAfterComment;
      return new NgToken.commentValue(_current.offset, _current.lexeme);
    }
    return handleError();
  }

  @protected
  NgToken scanElementDecorator() {
    NgSimpleTokenType type = _current.type;
    if (type == NgSimpleTokenType.identifier) {
      int offset = _current.offset;
      StringBuffer sb = new StringBuffer();
      sb.write(_current.lexeme);
      while (_reader.peekType() == NgSimpleTokenType.period ||
          _reader.peekType() == NgSimpleTokenType.identifier) {
        _moveNext();
        sb.write(_current.lexeme);
      }
      _state = NgScannerState.scanAfterElementDecorator;
      return new NgToken.elementDecorator(offset, sb.toString());
    }
    if (type == NgSimpleTokenType.openParen ||
        type == NgSimpleTokenType.openBracket ||
        type == NgSimpleTokenType.openBanana ||
        type == NgSimpleTokenType.hash ||
        type == NgSimpleTokenType.star) {
      _state = NgScannerState.scanAfterElementDecorator;
      return evaluateSpecialElementDecorator();
    }
    return handleError();
  }

  @protected
  NgToken scanElementDecoratorValue() {
    if (_current is NgSimpleQuoteToken) {
      NgSimpleQuoteToken current = _current as NgSimpleQuoteToken;
      bool isDouble = current.type == NgSimpleTokenType.doubleQuote;

      NgToken leftQuoteToken;
      NgToken innerValueToken;
      NgToken rightQuoteToken;
      int leftQuoteOffset;
      int rightQuoteOffset;

      String innerValue = current.lexeme;
      leftQuoteOffset = current.quoteOffset;

      if (current.quoteEndOffset == null) {
        if (_recoverErrors) {
          // TODO: Synthetic?
          rightQuoteOffset = current.end;
        } else {
          return handleError(current);
        }
      } else {
        rightQuoteOffset = current.quoteEndOffset - 1;
      }

      if (isDouble) {
        leftQuoteToken = new NgToken.doubleQuote(leftQuoteOffset);
        rightQuoteToken = new NgToken.doubleQuote(rightQuoteOffset);
      } else {
        leftQuoteToken = new NgToken.singleQuote(leftQuoteOffset);
        rightQuoteToken = new NgToken.singleQuote(rightQuoteOffset);
      }
      innerValueToken =
          new NgToken.elementDecoratorValue(current.offset, innerValue);

      _state = NgScannerState.scanAfterElementDecoratorValue;
      return new NgAttributeValueToken.generate(
          leftQuoteToken, innerValueToken, rightQuoteToken);
    }
    if (_current.type == NgSimpleTokenType.whitespace) {
      return new NgToken.whitespace(_current.offset, _current.lexeme);
    }
    return handleError();
  }

  @protected
  NgToken scanElementIdentifier({@required bool wasOpenTag}) {
    if (_current.type == NgSimpleTokenType.identifier) {
      _state = wasOpenTag
          ? NgScannerState.scanAfterElementIdentifierOpen
          : NgScannerState.scanAfterElementIdentifierClose;
      return new NgToken.elementIdentifier(_current.offset, _current.lexeme);
    }
    return handleError();
  }

  @protected
  NgToken scanElementEndClose() {
    if (_current.type == NgSimpleTokenType.tagEnd) {
      _state = NgScannerState.scanStart;
      return new NgToken.closeElementEnd(_current.offset);
    }
    return handleError();
  }

  @protected
  NgToken scanElementEndOpen() {
    if (_current.type == NgSimpleTokenType.voidCloseTag) {
      _state = NgScannerState.scanStart;
      return new NgToken.openElementEndVoid(_current.offset);
    }
    if (_current.type == NgSimpleTokenType.tagEnd) {
      _state = NgScannerState.scanStart;
      return new NgToken.openElementEnd(_current.offset);
    }
    return handleError();
  }

  @protected
  NgToken scanElementStart() {
    if (_current.type == NgSimpleTokenType.openTagStart) {
      _state = NgScannerState.scanElementIdentifierOpen;
      return new NgToken.openElementStart(_current.offset);
    }
    if (_current.type == NgSimpleTokenType.closeTagStart) {
      _state = NgScannerState.scanElementIdentifierClose;
      return new NgToken.closeElementStart(_current.offset);
    }
    return handleError();
  }

  //TODO: Check for errorcase: another interpolation within interpolation
  @protected
  NgToken scanInterpolation() {
    if (_current.type == NgSimpleTokenType.text) {
      _state = NgScannerState.scanAfterInterpolation;
      String text = _current.lexeme;
      int afterInterpolation = text.indexOf(_findAfterInterpolation);

      if (afterInterpolation != -1) {
        int textOffsetAfterMustacheEnd =
            afterInterpolation + _findAfterInterpolation.length;
        if ((_current.offset + textOffsetAfterMustacheEnd) != _current.end) {
          _reader.putBack(new NgSimpleToken.text(
              _current.offset + textOffsetAfterMustacheEnd,
              text.substring(textOffsetAfterMustacheEnd)));
        }
        _reader.putBack(new NgSimpleToken.mustacheEnd(
            _current.offset + afterInterpolation));
        return new NgToken.interpolationValue(
            _current.offset, text.substring(0, afterInterpolation));
      }

      return new NgToken.interpolationValue(_current.offset, _current.lexeme);
    }
    return handleError();
  }

  @protected
  NgToken scanText() {
    // TODO: move interpolation token finding logic elsewhere(?)
    // TODO: be able to pinpoint incorrectly overlapping mustaches too.
    if (_current.type == NgSimpleTokenType.text) {
      String text = _current.lexeme;
      int beforeInterpolation = text.indexOf(_findBeforeInterpolation);

      if (beforeInterpolation != -1) {
        int afterMustacheTextOffset =
            beforeInterpolation + _findBeforeInterpolation.length;

        _reader.putBack(new NgSimpleToken.text(
            _current.offset + afterMustacheTextOffset,
            text.substring(afterMustacheTextOffset)));

        if (beforeInterpolation == 0) {
          _state = NgScannerState.scanInterpolation;
          return new NgToken.interpolationStart(_current.offset);
        } else {
          _reader.putBack(new NgSimpleToken.mustacheBegin(
              _current.offset + beforeInterpolation));
          _state = NgScannerState.scanBeforeInterpolation;
          return new NgToken.text(
              _current.offset, text.substring(0, beforeInterpolation));
        }
      }
      _state = NgScannerState.scanStart;
      return new NgToken.text(_current.offset, _current.lexeme);
    }
    return handleError();
  }

  NgToken handleError([NgSimpleToken override]) {
    NgScannerState currentState = _state;
    _state = NgScannerState.hasError;
    Exception e = _generateException(override);
    if (e != null) {
      exceptionHandler.handle(e);
    }

    if (_recoverErrors) {
      RecoverySolution solution;
      switch (currentState) {
        case NgScannerState.hasError:
          return null;
        case NgScannerState.isEndOfFile:
          return null;
        case NgScannerState.scanAfterComment:
          solution = _rp.scanAfterComment(_current, _reader);
          break;
        case NgScannerState.scanAfterElementDecorator:
          solution = _rp.scanAfterElementDecorator(_current, _reader);
          break;
        case NgScannerState.scanAfterElementDecoratorValue:
          solution = _rp.scanAfterElementDecoratorValue(_current, _reader);
          break;
        case NgScannerState.scanAfterElementIdentifierClose:
          solution = _rp.scanAfterElementIdentifierClose(_current, _reader);
          break;
        case NgScannerState.scanAfterElementIdentifierOpen:
          solution = _rp.scanAfterElementIdentifierOpen(_current, _reader);
          break;
        case NgScannerState.scanAfterInterpolation:
          solution = _rp.scanAfterInterpolation(_current, _reader);
          break;
        case NgScannerState.scanBeforeElementDecorator:
          solution = _rp.scanBeforeElementDecorator(_current, _reader);
          break;
        case NgScannerState.scanBeforeInterpolation:
          solution = _rp.scanBeforeInterpolation(_current, _reader);
          break;
        case NgScannerState.scanComment:
          solution = _rp.scanComment(_current, _reader);
          break;
        case NgScannerState.scanInterpolation:
          solution = _rp.scanInterpolation(_current, _reader);
          break;
        case NgScannerState.scanElementDecorator:
          solution = _rp.scanElementDecorator(_current, _reader);
          break;
        case NgScannerState.scanElementDecoratorValue:
          solution = _rp.scanElementDecoratorValue(_current, _reader);
          break;
        case NgScannerState.scanElementEndClose:
          solution = _rp.scanElementEndClose(_current, _reader);
          break;
        case NgScannerState.scanElementEndOpen:
          solution = _rp.scanElementEndOpen(_current, _reader);
          break;
        case NgScannerState.scanElementIdentifierClose:
          solution = _rp.scanElementIdentifierClose(_current, _reader);
          break;
        case NgScannerState.scanElementIdentifierOpen:
          solution = _rp.scanElementIdentifierOpen(_current, _reader);
          break;
        case NgScannerState.scanElementStart:
          solution = _rp.scanElementStart(_current, _reader);
          break;
        case NgScannerState.scanStart:
          solution = _rp.scanStart(_current, _reader);
          break;
        case NgScannerState.scanText:
          solution = _rp.scanText(_current, _reader);
          break;
      }
      _state = solution.nextState ?? currentState;
      if (solution.tokenToReturn == null) {
        _moveNext();
        return null;
      }
      return solution.tokenToReturn;
    } else {
      return null;
    }
  }

  FormatException _generateException([NgSimpleToken override]) {
    NgSimpleToken token = override ?? _current;
    if (_recoverErrors && _lastToken != null && _lastToken.errorSynthetic) {
      return null;
    }
    // Avoid throwing same error
    if (_lastErrorToken == token) {
      return null;
    }
    _lastErrorToken = token;
    String lexeme =
        (token is NgSimpleQuoteToken) ? token.quotedLexeme : token.lexeme;
    int offset =
        (token is NgSimpleQuoteToken) ? token.quoteOffset : token.offset;

    return new FormatException(
      'Unexpected character: $token',
      lexeme,
      offset,
    );
  }
}

/// For consistency purposes:
///   Element `Open` indicates <blah>
///   Element `Close` indicates </blah>
///
/// Start indicates the left bracket (< or </)
/// End indicates the right bracket (> or />)
enum NgScannerState {
  hasError,
  isEndOfFile,
  scanAfterComment,
  scanAfterElementDecorator,
  scanAfterElementDecoratorValue,
  scanAfterElementIdentifierClose,
  scanAfterElementIdentifierOpen,
  scanAfterInterpolation,
  scanBeforeElementDecorator,
  scanBeforeInterpolation,
  scanComment,
  scanElementDecorator,
  scanElementDecoratorValue,
  scanElementEndClose,
  scanElementEndOpen,
  scanElementIdentifierClose,
  scanElementIdentifierOpen,
  scanElementStart,
  scanInterpolation,
  scanStart,
  scanText,
}
