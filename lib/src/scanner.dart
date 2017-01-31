// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/simple_tokenizer.dart';
import 'package:angular_ast/src/parser/reader.dart';
import 'package:charcode/charcode.dart';
import 'package:meta/meta.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:source_span/source_span.dart';

/// A thin wrapper around [StringScanner] that scans tokens from an HTML string.
class NgScanner {
  static const _charElementDecoratorWrapper = $double_quote;
  static const _charElementEnd = $gt;
  static const _charElementStart = $lt;
  static const _charElementStartClose = $slash;

  static const _findAfterComment = '-->';
  static const _findAfterInterpolation = '}}';
  static const _findBeforeComment = '<!--';
  static const _findBeforeInterpolation = '{{';
  static final _findBeforeElementDecoratorValue = new RegExp(r'\s*=\s*"');
  static final _findElementDecorator = new RegExp(r'[^\s=>]+', multiLine: true);
  static final _findElementDecoratorValue = new RegExp(r'[^"]*');
  static const _findElementEndVoid = '/>';
  static final _findElementIdentifier = new RegExp(r'[^\s/>]*');
  static final _findInterpolationValue = new RegExp(r'[^}}]*');
  static final _findWhitespace = new RegExp(r'\s+', multiLine: true);

  final StringScanner _scanner;
  final NgTokenReversibleReader _reader;
  _NgScannerState _state = _NgScannerState.scanStart;

  NgSimpleToken _current;
  NgSimpleToken _moveNext() => _current = _reader.next();

  factory NgScanner(String html, {sourceUrl}) {
    StringScanner scanner = new StringScanner(html, sourceUrl: sourceUrl);
    NgTokenReader reader = new NgTokenReversibleReader(
        new SourceFile(html, url: sourceUrl),
        new NgSimpleTokenizer().tokenize(html));

    return new NgScanner._(scanner, reader);
  }

  NgScanner._(this._scanner, this._reader);

  /// Scans and returns the next token, or `null` if there is none more.
  NgToken scan() {
    _moveNext();
    switch (_state) {
      case _NgScannerState.hasError:
        throw new StateError('An error occurred');
      case _NgScannerState.isEndOfFile:
        return null;
      case _NgScannerState.scanAfterComment:
        return scanAfterComment();
      case _NgScannerState.scanAfterElementDecorator:
        return scanAfterElementDecorator();
      case _NgScannerState.scanAfterElementDecoratorValue:
        return scanAfterElementDecoratorValue();
      case _NgScannerState.scanAfterInterpolation:
        return scanAfterInterpolation();
      case _NgScannerState.scanBeforeElementDecorator:
        return scanBeforeElementDecorator();
      case _NgScannerState.scanBeforeInterpolation:
        return scanBeforeInterpolation();
      case _NgScannerState.scanCloseElementEnd:
        return scanElementEnd(wasOpenTag: false);
      case _NgScannerState.scanComment:
        return scanComment();
      case _NgScannerState.scanElementDecorator:
        return scanElementDecorator();
      case _NgScannerState.scanElementDecoratorValue:
        return scanElementDecoratorValue();
      case _NgScannerState.scanElementIdentifierClose:
        return scanElementIdentifier(wasOpenTag: false);
      case _NgScannerState.scanElementIdentifierOpen:
        return scanElementIdentifier(wasOpenTag: true);
      case _NgScannerState.scanElementStart:
        return scanElementStart();
      case _NgScannerState.scanInterpolation:
        return scanInterpolation();
      case _NgScannerState.scanOpenElementEnd:
        return scanElementEnd(wasOpenTag: true);
      case _NgScannerState.scanStart:
        if (_current == null && _reader.isDone) {
          _state = _NgScannerState.isEndOfFile;
          return null;
        }
        if (_current.type == NgSimpleTokenType.tagStart) {
          return scanElementStart();
        }
        if (_current.type == NgSimpleTokenType.commentBegin) {
          return scanBeforeComment();
        }
        return scanText();
      case _NgScannerState.scanText:
        return scanText();
    }
    return null;
  }

  @protected
  NgToken scanAfterComment() {
    if (_current.type == NgSimpleTokenType.commentEnd) {
      _state = _NgScannerState.scanStart;
      return new NgToken.commentEnd(_current.offset);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanAfterElementDecorator() {
    if (_current.type == NgSimpleTokenType.equalSign) {
      _state = _NgScannerState.scanElementDecoratorValue;
      return new NgToken.beforeElementDecoratorValue(_current.offset);
    } else if (_current.type == NgSimpleTokenType.tagEnd ||
        _current.type == NgSimpleTokenType.forwardSlash) {
      return scanElementEnd(wasOpenTag: true);
    } else if (_current.type == NgSimpleTokenType.whitespace) {
      return scanBeforeElementDecorator();
    } else if (_current.type == NgSimpleTokenType.closeParen) {
      return new NgToken.eventElementDecoratorEnd(_current.offset);
    } else if (_current.type == NgSimpleTokenType.closeBracket) {
      return new NgToken.inputElementDecoratorEnd(_current.offset);
    }

    throw _unexpected();
  }

  //TODO to also return single quote
  @protected
  NgToken scanAfterElementDecoratorValue() {
    if (_current.type == NgSimpleTokenType.doubleQuote) {
      _state = _NgScannerState.scanAfterElementDecorator;
      return new NgToken.afterElementDecoratorValue(_current.offset);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanAfterInterpolation() {
    if (_current.type == NgSimpleTokenType.mustacheEnd) {
      _state = _NgScannerState.scanStart;
      return new NgToken.interpolationEnd(_current.offset);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanBeforeComment() {
    if (_current.type == NgSimpleTokenType.commentBegin) {
      _state = _NgScannerState.scanComment;
      return new NgToken.commentStart(_current.offset);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanBeforeElementDecorator() {
    if (_current.type == NgSimpleTokenType.whitespace) {
      _state = _NgScannerState.scanElementDecorator;
      return new NgToken.beforeElementDecorator(
          _current.offset, _current.lexeme);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanBeforeInterpolation() {
    if (_current.type == NgSimpleTokenType.mustacheBegin) {
      _state = _NgScannerState.scanInterpolation;
      return new NgToken.interpolationStart(_current.offset);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanComment() {
    if (_current.type == NgSimpleTokenType.text) {
      _state = _NgScannerState.scanAfterComment;
      return new NgToken.commentValue(_current.offset, _current.lexeme);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanElementDecorator() {
    if (_current.type == NgSimpleTokenType.identifier) {
      _state = _NgScannerState.scanAfterElementDecorator;
      return new NgToken.elementDecorator(_current.offset, _current.lexeme);
    }
    if (_current.type == NgSimpleTokenType.openParen) {
      return new NgToken.eventElementDecoratorBegin(_current.offset);
    }
    if (_current.type == NgSimpleTokenType.openBracket) {
      return new NgToken.inputElementDecoratorBegin(_current.offset);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanElementDecoratorValue() {
    //TODO add single quote tokens and adjust
    if (_current is NgSimpleQuoteToken) {
      bool isDouble = _current.type == NgSimpleTokenType.doubleQuote;
      bool isClosed = (_current as NgSimpleQuoteToken).isClosed;
      String substring = (_current as NgSimpleQuoteToken).quotedLexeme;
      if (!isDouble) {
        substring.replaceFirst("'", '"');
      }
      if (isClosed) {
        int closeQuoteEnd = (_current as NgSimpleQuoteToken).quoteEndOffset;
        substring = substring.substring(0, substring.length - 1);
        _reader.putBack(new NgSimpleToken.doubleQuote(closeQuoteEnd - 1));
      }
      _state = _NgScannerState.scanAfterElementDecoratorValue;
      return new NgToken.elementDecoratorValue(
          (_current as NgSimpleQuoteToken).quoteOffset, substring);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanElementIdentifier({@required bool wasOpenTag}) {
    if (_current.type == NgSimpleTokenType.identifier ||
        _current.type == NgSimpleTokenType.dashedIdentifier) {
      if (_reader.peekType() == NgSimpleTokenType.whitespace) {
        _state = _NgScannerState.scanBeforeElementDecorator;
      } else {
        _state = wasOpenTag
            ? _NgScannerState.scanOpenElementEnd
            : _NgScannerState.scanCloseElementEnd;
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
        _state = _NgScannerState.scanStart;
        if (!wasOpenTag) {
          throw _unexpected(new NgSimpleToken.voidCloseTag(slashOffset));
        }
        return new NgToken.openElementEndVoid(slashOffset);
      }
    } else if (_current.type == NgSimpleTokenType.tagEnd) {
      _state = _NgScannerState.scanStart;
      return wasOpenTag
          ? new NgToken.openElementEnd(_current.offset)
          : new NgToken.closeElementEnd(_current.offset);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanElementStart() {
    if (_current.type == NgSimpleTokenType.tagStart) {
      int offset = _current.offset;
      if (_reader.peekType() == NgSimpleTokenType.forwardSlash) {
        _moveNext();
        _state = _NgScannerState.scanElementIdentifierClose;
        return new NgToken.closeElementStart(offset);
      }
      _state = _NgScannerState.scanElementIdentifierOpen;
      return new NgToken.openElementStart(offset);
    }
    throw _unexpected();
  }

  //TODO: Check for errorcase: another interpolation within interpolation
  @protected
  NgToken scanInterpolation() {
    if (_current.type == NgSimpleTokenType.text) {
      _state = _NgScannerState.scanAfterInterpolation;
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
          _state = _NgScannerState.scanInterpolation;
          return new NgToken.interpolationStart(_current.offset);
        } else {
          _reader.putBack(new NgSimpleToken.mustacheBegin(
              _current.offset + beforeInterpolation));
          _state = _NgScannerState.scanBeforeInterpolation;
          return new NgToken.text(
              _current.offset, text.substring(0, beforeInterpolation));
        }
      }
      _state = _NgScannerState.scanStart;
      return new NgToken.text(_current.offset, _current.lexeme);
    }
    throw _unexpected();
  }

  FormatException _unexpected([NgSimpleToken override]) {
    NgSimpleToken token = override ?? _current;
    _state = _NgScannerState.hasError;
    return new FormatException(
      'Unexpected character: $token.lexeme',
      token.lexeme,
      token.offset,
    );
  }
}

enum _NgScannerState {
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
