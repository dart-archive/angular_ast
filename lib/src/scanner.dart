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

  static const _findBeforeElementDecoratorValue = '="';
  static final _findElementDecorator = new RegExp(r'[^(\s|=>)]+');
  static final _findElementDecoratorValue = new RegExp(r'[^(")]*');
  static final _findElementIdentifier = new RegExp(r'[^(\s|>)]*');
  static final _findTextRegex = new RegExp(r'[^<]+', multiLine: true);
  static final _findWhitespace = new RegExp(r'\s');

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
      case _NgScannerState.scanAfterElementDecorator:
        return scanAfterElementDecorator();
      case _NgScannerState.scanAfterElementDecoratorValue:
        return scanAfterElementDecoratorValue();
      case _NgScannerState.scanBeforeElementDecorator:
        return scanBeforeElementDecorator();
      case _NgScannerState.scanCloseElementEnd:
        return scanElementEnd(wasOpenTag: false);
      case _NgScannerState.scanElementDecorator:
        return scanElementDecorator();
      case _NgScannerState.scanElementDecoratorValue:
        return scanElementDecoratorValue();
      case _NgScannerState.scanElementIdentifierClose:
        return scanElementIdentifier(wasOpenTag: false);
      case _NgScannerState.scanElementIdentifierOpen:
        return scanElementIdentifier(wasOpenTag: true);
      case _NgScannerState.scanOpenElementEnd:
        return scanElementEnd(wasOpenTag: true);
      case _NgScannerState.scanElementStart:
        return scanElementStart();
      case _NgScannerState.scanStart:
        if (_scanner.peekChar() == _charElementStart) {
          return scanElementStart();
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
  NgToken scanText() {
    final offset = _scanner.position;
    if (_scanner.scan(_findTextRegex)) {
      if (_scanner.isDone) {
        _state = _NgScannerState.isEndOfFile;
      } else if (_scanner.peekChar() != _charElementStart) {
        throw _unexpected();
      } else {
        _state = _NgScannerState.scanElementStart;
      }
      return new NgToken.text(offset, _scanner.substring(offset));
    }
    throw _unexpected();
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
  scanAfterElementDecorator,
  scanAfterElementDecoratorValue,
  scanBeforeElementDecorator,
  scanCloseElementEnd,
  scanElementDecorator,
  scanElementDecoratorValue,
  scanElementIdentifierClose,
  scanElementIdentifierOpen,
  scanOpenElementEnd,
  scanElementStart,
  scanStart,
  scanText,
}
