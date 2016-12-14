// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library angular_ast.src.scanner;

import 'package:angular_ast/src/token.dart';
import 'package:charcode/charcode.dart';
import 'package:meta/meta.dart';
import 'package:string_scanner/string_scanner.dart';

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
  static final _findElementIdentifier = new RegExp(r'[^\s|>]*');
  static final _findInterpolationValue = new RegExp(r'[^}}]*');
  static final _findWhitespace = new RegExp(r'\s+', multiLine: true);

  final StringScanner _scanner;

  _NgScannerState _state = _NgScannerState.scanStart;

  factory NgScanner(String html, {sourceUrl}) {
    return new NgScanner._(new StringScanner(html, sourceUrl: sourceUrl));
  }

  NgScanner._(this._scanner);

  /// Scans and returns the next token, or `null` if there is none more.
  NgToken scan() {
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
        if (_scanner.peekChar() == _charElementStart) {
          return scanElementStart();
        } else if (_scanner.matches(_findBeforeInterpolation)) {
          return scanBeforeInterpolation();
        } else if (_scanner.isDone) {
          _state = _NgScannerState.isEndOfFile;
          return null;
        }
        return scanText();
      case _NgScannerState.scanText:
        return scanText();
    }
    return null;
  }

  @protected
  NgToken scanAfterComment() {
    final offset = _scanner.position;
    if (_scanner.scan(_findAfterComment)) {
      _state = _NgScannerState.scanStart;
      return new NgToken.commentEnd(offset);
    } else {
      throw _unexpected();
    }
  }

  @protected
  NgToken scanAfterElementDecorator() {
    final offset = _scanner.position;
    if (_scanner.scan(_findBeforeElementDecoratorValue)) {
      _state = _NgScannerState.scanElementDecoratorValue;
      return new NgToken.beforeElementDecoratorValue(offset);
    } else if (_scanner.peekChar() == _charElementEnd) {
      return scanElementEnd(wasOpenTag: true);
    } else if (_scanner.matches(_findWhitespace)) {
      return scanBeforeElementDecorator();
    } else {
      throw _unexpected();
    }
  }

  @protected
  NgToken scanAfterElementDecoratorValue() {
    final offset = _scanner.position;
    if (_scanner.scanChar(_charElementDecoratorWrapper)) {
      _state = _NgScannerState.scanAfterElementDecorator;
      return new NgToken.afterElementDecoratorValue(offset);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanAfterInterpolation() {
    final offset = _scanner.position;
    if (_scanner.scan(_findAfterInterpolation)) {
      _state = _NgScannerState.scanStart;
      return new NgToken.interpolationEnd(offset);
    } else {
      throw _unexpected();
    }
  }

  @protected
  NgToken scanBeforeComment() {
    final offset = _scanner.position;
    if (_scanner.scan(_findBeforeComment)) {
      _state = _NgScannerState.scanComment;
      return new NgToken.commentStart(offset);
    } else {
      throw _unexpected();
    }
  }

  @protected
  NgToken scanBeforeElementDecorator() {
    final offset = _scanner.position;
    if (_scanner.scan(_findWhitespace)) {
      _state = _NgScannerState.scanElementDecorator;
      return new NgToken.beforeElementDecorator(
        offset,
        _scanner.substring(offset),
      );
    }
    throw _unexpected();
  }

  @protected
  NgToken scanBeforeInterpolation() {
    final offset = _scanner.position;
    if (_scanner.scan(_findBeforeInterpolation)) {
      _state = _NgScannerState.scanInterpolation;
      return new NgToken.interpolationStart(offset);
    } else {
      throw _unexpected();
    }
  }

  @protected
  NgToken scanComment() {
    final offset = _scanner.position;
    while (true) {
      if (_scanner.peekChar() == $dash &&
          _scanner.peekChar(1) == $dash &&
          _scanner.peekChar(2) == $gt) {
        break;
      }
      _scanner.position++;
      if (_scanner.isDone) {
        throw _unexpected();
      }
    }
    _state = _NgScannerState.scanAfterComment;
    return new NgToken.commentValue(offset, _scanner.substring(offset));
  }

  @protected
  NgToken scanElementDecorator() {
    final offset = _scanner.position;
    if (_scanner.scan(_findElementDecorator)) {
      _state = _NgScannerState.scanAfterElementDecorator;
      return new NgToken.elementDecorator(offset, _scanner.substring(offset));
    }
    throw _unexpected();
  }

  @protected
  NgToken scanElementDecoratorValue() {
    final offset = _scanner.position;
    if (_scanner.scan(_findElementDecoratorValue)) {
      _state = _NgScannerState.scanAfterElementDecoratorValue;
      return new NgToken.elementDecoratorValue(
        offset,
        _scanner.substring(offset),
      );
    }
    throw _unexpected();
  }

  @protected
  NgToken scanElementIdentifier({@required bool wasOpenTag}) {
    final offset = _scanner.position;
    if (_scanner.scan(_findElementIdentifier)) {
      if (_scanner.matches(_findWhitespace)) {
        _state = _NgScannerState.scanBeforeElementDecorator;
      } else {
        _state = wasOpenTag
            ? _NgScannerState.scanOpenElementEnd
            : _NgScannerState.scanCloseElementEnd;
      }
      return new NgToken.elementIdentifier(offset, _scanner.substring(offset));
    }
    throw _unexpected();
  }

  @protected
  NgToken scanElementEnd({@required bool wasOpenTag}) {
    final offset = _scanner.position;
    if (_scanner.scanChar(_charElementEnd)) {
      _state = _NgScannerState.scanStart;
      return wasOpenTag
          ? new NgToken.openElementEnd(offset)
          : new NgToken.closeElementEnd(offset);
    } else {
      throw _unexpected();
    }
  }

  @protected
  NgToken scanElementStart() {
    final offset = _scanner.position;
    if (_scanner.matches(_findBeforeComment)) {
      return scanBeforeComment();
    }
    if (_scanner.scanChar(_charElementStart)) {
      if (_scanner.scanChar(_charElementStartClose)) {
        _state = _NgScannerState.scanElementIdentifierClose;
        return new NgToken.closeElementStart(offset);
      }
      _state = _NgScannerState.scanElementIdentifierOpen;
      return new NgToken.openElementStart(offset);
    }
    throw _unexpected();
  }

  @protected
  NgToken scanInterpolation() {
    final offset = _scanner.position;
    if (_scanner.scan(_findInterpolationValue)) {
      _state = _NgScannerState.scanAfterInterpolation;
      return new NgToken.interpolationValue(offset, _scanner.substring(offset));
    } else {
      throw _unexpected();
    }
  }

  @protected
  NgToken scanText() {
    final offset = _scanner.position;
    while (!_scanner.isDone) {
      if (_scanner.peekChar() == _charElementStart) {
        _state = _NgScannerState.scanElementStart;
        return new NgToken.text(offset, _scanner.substring(offset));
      } else if (_scanner.matches('{{')) {
        _state = _NgScannerState.scanBeforeInterpolation;
        return new NgToken.text(offset, _scanner.substring(offset));
      }
      _scanner.position++;
    }
    _state = _NgScannerState.isEndOfFile;
    return new NgToken.text(offset, _scanner.substring(offset));
  }

  FormatException _unexpected() {
    final char = new String.fromCharCode(_scanner.peekChar());
    _state = _NgScannerState.hasError;
    return new FormatException(
      'Unexpected character: $char',
      _scanner.string,
      _scanner.position,
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
