// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/simple_tokenizer.dart';
import 'package:angular_ast/src/parser/reader.dart';
import 'package:angular_ast/src/recovery_protocol/angular_analyzer_protocol.dart';
import 'package:angular_ast/src/recovery_protocol/recovery_protocol.dart';
import 'package:meta/meta.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:source_span/source_span.dart';

/// A wrapper around [StringScanner] that scans tokens from an HTML string.
class NgScanner {
  static const _findAfterInterpolation = '}}';
  static const _findBeforeInterpolation = '{{';

  final NgTokenReversibleReader _reader;
  NgScannerState _state = NgScannerState.scanStart;

  final bool _recoverErrors;
  RecoveryProtocol _rp = new NgAnalyzerRecoveryProtocol();

  NgSimpleToken _current;
  NgSimpleToken _moveNext() => _current = _reader.next();
  NgSimpleToken _moveNextExpect(NgBaseTokenType type) =>
      _current = _reader.expect(type);

  factory NgScanner(String html, {sourceUrl, bool recoverError: false}) {
    NgTokenReader reader = new NgTokenReversibleReader(
        new SourceFile(html, url: sourceUrl),
        new NgSimpleTokenizer().tokenize(html));

    return new NgScanner._(reader, recoverError);
  }

  NgScanner._(this._reader, this._recoverErrors);

  /// Scans and returns the next token, or `null` if there is none more.
  NgToken scan() {
    _moveNext();
    //print("$_current :: $_state");
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
        case NgScannerState.scanAfterInterpolation:
          returnToken = scanAfterInterpolation();
          break;
        case NgScannerState.scanBeforeElementDecorator:
          returnToken = scanBeforeElementDecorator();
          break;
        case NgScannerState.scanBeforeInterpolation:
          returnToken = scanBeforeInterpolation();
          break;
        case NgScannerState.scanCloseElementEnd:
          returnToken = scanElementEnd(wasOpenTag: false);
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
        case NgScannerState.scanOpenElementEnd:
          returnToken = scanElementEnd(wasOpenTag: true);
          break;
        case NgScannerState.scanStart:
          if (_current.type == NgSimpleTokenType.EOF && _reader.isDone) {
            _state = NgScannerState.isEndOfFile;
            return null;
          } else if (_current.type == NgSimpleTokenType.tagStart) {
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
    //print("RETURNING: " + returnToken.toString());
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
      // Banana/Two-way
      if (_reader.peekType() == NgSimpleTokenType.openParen) {
        int offset = _current.offset;
        _moveNext();
        prefix = new NgToken.bananaPrefix(offset);
      }
      // Property
      else {
        identifierPartsLimit = 2;
        prefix = new NgToken.propertyPrefix(_current.offset);
      }
    } else if (_current.type == NgSimpleTokenType.hash) {
      // Reference
      prefix = new NgToken.referencePrefix(_current.offset);
    } else if (_current.type == NgSimpleTokenType.star) {
      // Template
      prefix = new NgToken.templatePrefix(_current.offset);
    }

    // Identifier
    // TODO: Catch unexpected types here after opening prefix
    // TODO: Example: [=blah]="hello"
    _moveNextExpect(NgSimpleTokenType.identifier);
    if ((prefix.type == NgTokenType.propertyPrefix ||
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
      suffix = new NgToken.eventSuffix(_current.offset);
    } else if (prefix.type == NgTokenType.bananaPrefix) {
      _moveNextExpect(NgSimpleTokenType.closeParen);
      int offset = _current.offset;
      _moveNextExpect(NgSimpleTokenType.closeBracket);
      suffix = new NgToken.bananaSuffix(offset);
    } else if (prefix.type == NgTokenType.propertyPrefix) {
      _moveNextExpect(NgSimpleTokenType.closeBracket);
      suffix = new NgToken.propertySuffix(_current.offset);
    }

    return new NgSpecialAttributeToken.generate(prefix, identifier, suffix);
  }

  @protected
  NgToken scanAfterComment() {
    if (_current.type == NgSimpleTokenType.commentEnd) {
      _state = NgScannerState.scanStart;
      return new NgToken.commentEnd(_current.offset);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanAfterElementDecorator() {
    if (_current == null) {
      return handleError();
    }
    if (_current.type == NgSimpleTokenType.equalSign) {
      _state = NgScannerState.scanElementDecoratorValue;
      return new NgToken.beforeElementDecoratorValue(_current.offset);
    } else if (_current.type == NgSimpleTokenType.tagEnd ||
        _current.type == NgSimpleTokenType.forwardSlash) {
      return scanElementEnd(wasOpenTag: true);
    } else if (_current.type == NgSimpleTokenType.whitespace) {
      NgSimpleTokenType nextType = _reader.peekType();
      // Trailing whitespace check.
      if (nextType == NgSimpleTokenType.equalSign ||
          nextType == NgSimpleTokenType.forwardSlash ||
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
        _current.type == NgSimpleTokenType.forwardSlash) {
      return scanElementEnd(wasOpenTag: true);
    } else if (_current.type == NgSimpleTokenType.whitespace) {
      NgSimpleTokenType nextType = _reader.peekType();
      if (nextType == NgSimpleTokenType.forwardSlash ||
          nextType == NgSimpleTokenType.tagEnd) {
        return new NgToken.whitespace(_current.offset, _current.lexeme);
      }
      return scanBeforeElementDecorator();
    }
    throw _unexpected();
  }

  @protected
  NgToken scanAfterInterpolation() {
    if (_current.type == NgSimpleTokenType.mustacheEnd) {
      _state = NgScannerState.scanStart;
      return new NgToken.interpolationEnd(_current.offset);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanBeforeComment() {
    if (_current.type == NgSimpleTokenType.commentBegin) {
      _state = NgScannerState.scanComment;
      return new NgToken.commentStart(_current.offset);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanBeforeElementDecorator() {
    if (_current.type == NgSimpleTokenType.whitespace) {
      if (_reader.peekType() == NgSimpleTokenType.forwardSlash ||
          _reader.peekType() == NgSimpleTokenType.tagEnd) {
        _state = NgScannerState.scanAfterElementDecorator;
        return new NgToken.whitespace(_current.offset, _current.lexeme);
      }
      _state = NgScannerState.scanElementDecorator;
      return new NgToken.beforeElementDecorator(
          _current.offset, _current.lexeme);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanBeforeInterpolation() {
    if (_current.type == NgSimpleTokenType.mustacheBegin) {
      _state = NgScannerState.scanInterpolation;
      return new NgToken.interpolationStart(_current.offset);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanComment() {
    if (_current.type == NgSimpleTokenType.text) {
      _state = NgScannerState.scanAfterComment;
      return new NgToken.commentValue(_current.offset, _current.lexeme);
    }
    throw _unexpected();
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
        type == NgSimpleTokenType.hash ||
        type == NgSimpleTokenType.star) {
      _state = NgScannerState.scanAfterElementDecorator;
      return evaluateSpecialElementDecorator();
    }
    throw _unexpected();
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
          rightQuoteOffset = current.end;
        } else {
          throw _unexpectedSpecific(current.end);
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
    throw _unexpected();
  }

  @protected
  NgToken scanElementIdentifier({@required bool wasOpenTag}) {
    if (_current.type == NgSimpleTokenType.identifier) {
      if (_reader.peekType() == NgSimpleTokenType.whitespace) {
        _state = (wasOpenTag)
            ? NgScannerState.scanBeforeElementDecorator
            : NgScannerState.scanCloseElementEnd;
      } else {
        _state = wasOpenTag
            ? NgScannerState.scanOpenElementEnd
            : NgScannerState.scanCloseElementEnd;
      }

      return new NgToken.elementIdentifier(_current.offset, _current.lexeme);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanElementEnd({@required bool wasOpenTag}) {
    if (_current.type == NgSimpleTokenType.forwardSlash) {
      int slashOffset = _current.offset;
      if (_reader.peekType() == NgSimpleTokenType.tagEnd) {
        _moveNext();
        _state = NgScannerState.scanStart;
        if (!wasOpenTag) {
          throw _unexpected(new NgSimpleToken.voidCloseTag(slashOffset));
        }
        return new NgToken.openElementEndVoid(slashOffset);
      }
    } else if (_current.type == NgSimpleTokenType.tagEnd) {
      _state = NgScannerState.scanStart;
      return wasOpenTag
          ? new NgToken.openElementEnd(_current.offset)
          : new NgToken.closeElementEnd(_current.offset);
    } else if (_current.type == NgSimpleTokenType.whitespace) {
      return new NgToken.whitespace(_current.offset, _current.lexeme);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanElementStart() {
    if (_current.type == NgSimpleTokenType.tagStart) {
      int offset = _current.offset;
      if (_reader.peekType() == NgSimpleTokenType.forwardSlash) {
        _moveNext();
        _state = NgScannerState.scanElementIdentifierClose;
        return new NgToken.closeElementStart(offset);
      }
      _state = NgScannerState.scanElementIdentifierOpen;
      return new NgToken.openElementStart(offset);
    }
    throw _unexpected();
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
    throw _unexpected();
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
    throw _unexpected();
  }

  NgToken handleError([NgSimpleToken override]) {
    if (_recoverErrors) {
      RecoverySolution solution;
      switch (_state) {
        case NgScannerState.hasError:
          break;
        case NgScannerState.isEndOfFile:
          break;
        case NgScannerState.scanAfterComment:
          break;
        case NgScannerState.scanAfterElementDecorator:
          solution = _rp.scanAfterElementDecorator(_current, _reader);
          break;
        case NgScannerState.scanAfterElementDecoratorValue:
          break;
        case NgScannerState.scanAfterInterpolation:
          break;
        case NgScannerState.scanBeforeElementDecorator:
          break;
        case NgScannerState.scanBeforeInterpolation:
          break;
        case NgScannerState.scanCloseElementEnd:
          break;
        case NgScannerState.scanComment:
          break;
        case NgScannerState.scanInterpolation:
          break;
        case NgScannerState.scanElementDecorator:
          break;
        case NgScannerState.scanElementDecoratorValue:
          break;
        case NgScannerState.scanElementIdentifierClose:
          break;
        case NgScannerState.scanElementIdentifierOpen:
          break;
        case NgScannerState.scanOpenElementEnd:
          break;
        case NgScannerState.scanElementStart:
          break;
        case NgScannerState.scanStart:
          break;
        case NgScannerState.scanText:
          break;
      }

      _state = solution.nextState ?? _state;
      if (solution.tokenToReturn == null) {
        _moveNext();
        return null;
      }
      return solution.tokenToReturn;
    } else {
      throw _unexpected(override);
    }
  }

  FormatException _unexpected([NgSimpleToken override]) {
    NgSimpleToken token = override ?? _current;
    _state = NgScannerState.hasError;
    return new FormatException(
      'Unexpected character: $token',
      token.lexeme,
      token.offset,
    );
  }

  FormatException _unexpectedSpecific(int errorOffset,
      [NgSimpleToken override]) {
    NgSimpleToken token = override ?? _current;
    _state = NgScannerState.hasError;
    String errorString = token.lexeme.substring(errorOffset - token.offset);
    return new FormatException(
        'Unexpected character in token at offset: $errorString : $errorOffset',
        token.lexeme,
        errorOffset);
  }
}

enum NgScannerState {
  hasError,
  isEndOfFile,
  scanAfterComment,
  scanAfterElementDecorator,
  scanAfterElementDecoratorValue,
  scanAfterInterpolation,
  scanBeforeElementDecorator,
  scanBeforeInterpolation,
  scanCloseElementEnd,
  scanComment,
  scanInterpolation,
  scanElementDecorator,
  scanElementDecoratorValue,
  scanElementIdentifierClose,
  scanElementIdentifierOpen,
  scanOpenElementEnd,
  scanElementStart,
  scanStart,
  scanText,
}
