// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/simple_token.dart';
import 'package:charcode/charcode.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:meta/meta.dart';

class NgSimpleTokenizer {
  @literal
  const factory NgSimpleTokenizer() = NgSimpleTokenizer._;

  const NgSimpleTokenizer._();

  Iterable<NgSimpleToken> tokenize(String template) sync* {
    final scanner = new NgSimpleScanner(template);
    NgSimpleToken token = scanner.scan();
    while (token.type != NgSimpleTokenType.EOF) {
      yield token;
      token = scanner.scan();
    }
  }
}

class NgSimpleScanner {
  static bool matchesGroup(Match match, int group) =>
      match.group(group) != null;

  static final _allTextMatches = new RegExp(r'(^[^\<]+)|(^<)');
  static final _allElementMatches = new RegExp(r'(^\])|' //1  ]
      r'(^\!)|' //2  !
      r'(^\-)|' //3  -
      r'(^\))|' //4  )
      r'(^>)|' //5  >
      r'(^\/)|' //6  /
      r'(^\[)|' //7  [
      r'(^\()|' //8  (
      r'(^[\s]+)|' //9 whitespace
      r'(^[a-zA-Z][\w\-\_]*[\w])|' //10 any alphanumeric + '-' + '_'
      r'("([^"\\]|\\.)*")|' //11 closed double quote (includes group 12)
      r"('([^'\\]|\\.)*')|" //13 closed single quote (includes group 14)
      r'(^")|' //15 " (floating)
      r"(^')|" //16 ' (floating)
      r"(^<)"); //17 <

  final StringScanner _scanner;
  _NgSimpleScannerState _state = _NgSimpleScannerState.text;

  factory NgSimpleScanner(String html, {sourceUrl, initialTextState: true}) {
    return new NgSimpleScanner._(new StringScanner(html, sourceUrl: sourceUrl),
        initialTextState: initialTextState);
  }

  NgSimpleScanner._(this._scanner, {initialTextState})
      : _state = (initialTextState)
            ? _NgSimpleScannerState.text
            : _NgSimpleScannerState.element;

  NgSimpleToken scan() {
    switch (_state) {
      case _NgSimpleScannerState.element:
        return scanElement();
      case _NgSimpleScannerState.text:
        return scanText();
    }
    return null;
  }

  NgSimpleToken scanElement() {
    int offset = _scanner.position;
    if (_scanner.peekChar() == null) {
      return new NgSimpleToken.EOF(offset);
    }
    if (_scanner.scan(_allElementMatches)) {
      Match match = _scanner.lastMatch;
      if (matchesGroup(match, 1)) {
        return new NgSimpleToken.closeBracket(offset);
      }
      if (matchesGroup(match, 2)) {
        return new NgSimpleToken.bang(offset);
      }
      if (matchesGroup(match, 3)) {
        return new NgSimpleToken.dash(offset);
      }
      if (matchesGroup(match, 4)) {
        return new NgSimpleToken.closeParen(offset);
      }
      if (matchesGroup(match, 5)) {
        _state = _NgSimpleScannerState.text;
        return new NgSimpleToken.elementEnd(offset);
      }
      if (matchesGroup(match, 6)) {
        return new NgSimpleToken.forwardSlash(offset);
      }
      if (matchesGroup(match, 7)) {
        return new NgSimpleToken.openBracket(offset);
      }
      if (matchesGroup(match, 8)) {
        return new NgSimpleToken.openParen(offset);
      }
      if (matchesGroup(match, 9)) {
        return new NgSimpleToken.whitespace(offset, _scanner.substring(offset));
      }
      if (matchesGroup(match, 10)) {
        return new NgSimpleToken.text(offset, _scanner.substring(offset));
      }
      if (matchesGroup(match, 11)) {
        return new NgSimpleToken.doubleQuotedText(
            offset, _scanner.substring(offset));
      }
      if (matchesGroup(match, 13)) {
        return new NgSimpleToken.singleQuotedText(
            offset, _scanner.substring(offset));
      }
      if (matchesGroup(match, 15)) {
        return new NgSimpleToken.doubleQuote(offset);
      }
      if (matchesGroup(match, 16)) {
        return new NgSimpleToken.singleQuote(offset);
      }
      if (matchesGroup(match, 17)) {
        return new NgSimpleToken.elementStart(offset);
      }
    }
    return new NgSimpleToken.unexpectedChar(
        offset, _scanner.readChar().toString());
  }

  NgSimpleToken scanText() {
    int offset = _scanner.position;
    if (_scanner.peekChar() == null) {
      return new NgSimpleToken.EOF(offset);
    }
    if (_scanner.scan(_allTextMatches)) {
      Match match = _scanner.lastMatch;
      if (matchesGroup(match, 1)) {
        return new NgSimpleToken.text(offset, _scanner.substring(offset));
      }
      if (matchesGroup(match, 2)) {
        _state = _NgSimpleScannerState.element;
        return new NgSimpleToken.elementStart(offset);
      }
    }
    return new NgSimpleToken.unexpectedChar(
        offset, _scanner.readChar().toString());
  }
}

enum _NgSimpleScannerState { text, element }
