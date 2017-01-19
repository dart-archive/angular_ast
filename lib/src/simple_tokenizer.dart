// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/simple_token.dart';
import 'package:charcode/charcode.dart';
import 'package:string_scanner/string_scanner.dart';

class NgSimpleTokenizer {}

class NgSimpleScanner {
  static final _quoteMatches = new RegExp(r'("([^"\\]|\\.)*")|'
      r"('([^'\\]|\\.)*')|"
      r'(^")|'
      r"(^')");
  static final _allTextMatches = new RegExp(r'(^[^\<]+)|(^<)');
  static final _allElementMatches = new RegExp(r'(^\])|'
      r'(^\!\-\-)|'
      r'(^\-\-)|'
      r'(^\))|'
      r'(^")|'
      r'(^>)|'
      r'(^\/>)|'
      r'(^")|'
      r'(^\/)|'
      r'(^\[)|'
      r'(^\()|'
      r'(^[\s]+)|'
      r'(^[a-zA-Z0-9\-\_]+)');

  final StringScanner _scanner;
  _NgSimpleScannerState _state = _NgSimpleScannerState.text;

  factory NgSimpleScanner(String html, {sourceUrl}) {
    return new NgSimpleScanner._(new StringScanner(html, sourceUrl: sourceUrl));
  }

  NgSimpleScanner._(this._scanner);

  NgSimpleToken scan() {
    switch (_state) {
      case _NgSimpleScannerState.element:
        return scanElement();
      case _NgSimpleScannerState.text:
        return scanText();
    }
    return null;
  }

  NgSimpleToken scanElement() {}

  NgSimpleToken scanText() {
    int initialOffset = _scanner.position;
    if (_scanner.peekChar() == null) {
      return new NgSimpleToken.EOF(initialOffset);
    }
    if (_scanner.scan(_allTextMatches)) {
      if (_scanner.lastMatch.group(1) != null) {
        return new NgSimpleToken.text(
            initialOffset, _scanner.substring(initialOffset));
      }
      if (_scanner.lastMatch.group(2) != null) {
        _state = _NgSimpleScannerState.element;
        return new NgSimpleToken.elementStart(initialOffset);
      }
    }
    return new NgSimpleToken.unexpectedChar(
        initialOffset, _scanner.readChar().toString());
  }
}

enum _NgSimpleScannerState { text, element }
