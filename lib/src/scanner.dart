// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/simple_tokenizer.dart';
import 'package:angular_ast/src/parser/reader.dart';
import 'package:meta/meta.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:source_span/source_span.dart';

/// A thin wrapper around [StringScanner] that scans tokens from an HTML string.
class NgScanner {
  static const _findAfterInterpolation = '}}';
  static const _findBeforeInterpolation = '{{';

  final NgTokenReversibleReader _reader;
  _NgScannerState _state = _NgScannerState.scanStart;

  NgSimpleToken _current;
  NgSimpleToken _moveNext() => _current = _reader.next();
  NgSimpleToken _moveNextExpect(NgBaseTokenType type) =>
      _current = _reader.expect(type);

  factory NgScanner(String html, {sourceUrl}) {
    NgTokenReader reader = new NgTokenReversibleReader(
        new SourceFile(html, url: sourceUrl),
        new NgSimpleTokenizer().tokenize(html));

    return new NgScanner._(reader);
  }

  NgScanner._(this._reader);

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
  NgToken evaluateSpecialElementDecorator() {
    NgToken prefix;
    NgToken identifier;
    NgToken suffix;

    //Prefix
    if (_current.type == NgSimpleTokenType.openParen) {
      //Event
      prefix = new NgToken.eventPrefix(_current.offset);
    } else if (_current.type == NgSimpleTokenType.openBracket) {
      //Banana/Two-way
      if (_reader.peekType() == NgSimpleTokenType.openParen) {
        int offset = _current.offset;
        _moveNext();
        prefix = new NgToken.bananaPrefix(offset);
      }
      //Property
      else {
        prefix = new NgToken.propertyPrefix(_current.offset);
      }
    } else if (_current.type == NgSimpleTokenType.hash) {
      //Reference
      prefix = new NgToken.referencePrefix(_current.offset);
    } else if (_current.type == NgSimpleTokenType.star) {
      //Template
      prefix = new NgToken.templatePrefix(_current.offset);
    }

    //Identifier
    _moveNextExpect(NgSimpleTokenType.identifier);
    if (prefix.type == NgTokenType.propertyPrefix &&
        _reader.peekType() == NgSimpleTokenType.period) {
      NgToken baseIdentifier =
          new NgToken.elementDecoratorValue(_current.offset, _current.lexeme);
      StringBuffer mergedLexeme = new StringBuffer();
      mergedLexeme.write(baseIdentifier.lexeme);
      _moveNext();
      while (_current.type == NgSimpleTokenType.period) {
        _current = _reader.expect(NgSimpleTokenType.identifier);
        mergedLexeme.write('.');
        mergedLexeme.write(_current.lexeme);
        _moveNext();
      }
      _reader.putBack(_current);
      identifier = new NgToken.elementDecoratorValue(
          baseIdentifier.offset, mergedLexeme.toString());
    } else {
      identifier =
          new NgToken.elementDecoratorValue(_current.offset, _current.lexeme);
    }

    //Suffix
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
      if (_reader.peekType() == NgSimpleTokenType.equalSign) {
        _moveNext();
        _state = _NgScannerState.scanElementDecoratorValue;
        return new NgToken.beforeElementDecoratorValue(_current.offset);
      }
      return scanBeforeElementDecorator();
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
    NgSimpleTokenType type = _current.type;
    if (type == NgSimpleTokenType.identifier) {
      StringBuffer sb = new StringBuffer();
      sb.write(_current.lexeme);
      while (_reader.peekType() == NgSimpleTokenType.period) {
        _moveNext();
        _moveNextExpect(NgSimpleTokenType.identifier);
        sb.write(_current.lexeme);
      }
      _state = _NgScannerState.scanAfterElementDecorator;
      return new NgToken.elementDecorator(_current.offset, sb.toString());
    }
    if (type == NgSimpleTokenType.openParen ||
        type == NgSimpleTokenType.openBracket ||
        type == NgSimpleTokenType.hash ||
        type == NgSimpleTokenType.star) {
      _state = _NgScannerState.scanAfterElementDecorator;
      return evaluateSpecialElementDecorator();
    }
    throw _unexpected();
  }

  @protected
  NgToken scanElementDecoratorValue() {
    if (_current is NgSimpleQuoteToken) {
      NgSimpleQuoteToken current = _current as NgSimpleQuoteToken;
      bool isDouble = current.type == NgSimpleTokenType.doubleQuote;

      String innerValue = current.lexeme;
      int leftQuoteOffset = current.quoteOffset;
      if (current.quoteEndOffset == null) {
        throw _unexpectedSpecific(current.end);
      }
      int rightQuoteOffset = current.quoteEndOffset - 1;

      NgToken leftQuoteToken;
      NgToken innerValueToken;
      NgToken rightQuoteToken;

      if (isDouble) {
        leftQuoteToken = new NgToken.doubleQuote(leftQuoteOffset);
        rightQuoteToken = new NgToken.doubleQuote(rightQuoteOffset);
      } else {
        leftQuoteToken = new NgToken.singleQuote(leftQuoteOffset);
        rightQuoteToken = new NgToken.singleQuote(rightQuoteOffset);
      }
      innerValueToken =
          new NgToken.elementDecoratorValue(current.offset, innerValue);

      _state = _NgScannerState.scanAfterElementDecorator;
      return new NgAttributeValueToken.generate(
          leftQuoteToken, innerValueToken, rightQuoteToken);
    }
    if (_current.type == NgSimpleTokenType.whitespace) {
      _moveNext();
      return scanElementDecoratorValue();
    }
    throw _unexpected();
  }

  @protected
  NgToken scanElementIdentifier({@required bool wasOpenTag}) {
    if (_current.type == NgSimpleTokenType.identifier) {
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
      'Unexpected character: $token',
      token.lexeme,
      token.offset,
    );
  }

  FormatException _unexpectedSpecific(int errorOffset,
      [NgSimpleToken override]) {
    NgSimpleToken token = override ?? _current;
    _state = _NgScannerState.hasError;
    String errorString = token.lexeme.substring(errorOffset - token.offset);
    return new FormatException(
        'Unexpected character in token at offset: $errorString : $errorOffset',
        token.lexeme,
        errorOffset);
  }
}

enum _NgScannerState {
  hasError,
  isEndOfFile,
  scanAfterComment,
  scanAfterElementDecorator,
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
