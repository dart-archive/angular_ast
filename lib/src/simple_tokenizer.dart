// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/token/tokens.dart';
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
    yield token; // Explicitly yield the EOF token.
  }
}

class NgSimpleScanner {
  static bool matchesGroup(Match match, int group) =>
      match.group(group) != null;

  static final _allTextMatches = new RegExp(r'([^\<]+)|(<!--)|(<)');
  static final _allElementMatches = new RegExp(r'(\])|' //1  ]
      r'(\!)|' //2  !
      r'(\-)|' //3  -
      r'(\))|' //4  )
      r'(>)|' //5  >
      r'(\/)|' //6  /
      r'(\[)|' //7  [
      r'(\()|' //8  (
      r'([\s]+)|' //9 whitespace
      r'([a-zA-Z]([\w\_\-])*[a-zA-Z0-9]?)|' //10 any alphanumeric + '-' + '_'
      r'("([^"\\]|\\.)*"?)|' //12 closed double quote (includes group 13)
      r"('([^'\\]|\\.)*'?)|" //14 closed single quote (includes group 15)
      r"(<)|" //16 <
      r"(=)|" //17 =
      r"(\*)|" //18 *
      r"(\#)|" //19 #
      r"(\.)"); //20 .
  static final _commentEnd = new RegExp('-->');

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
      case _NgSimpleScannerState.comment:
        return scanComment();
      case _NgSimpleScannerState.commentEnd:
        return scanCommentEnd();
      case _NgSimpleScannerState.element:
        return scanElement();
      case _NgSimpleScannerState.text:
        return scanText();
    }
    return null;
  }

  NgSimpleToken scanComment() {
    int offset = _scanner.position;
    while (true) {
      if (_scanner.peekChar() == $dash &&
          _scanner.peekChar(1) == $dash &&
          _scanner.peekChar(2) == $gt) {
        break;
      }
      _scanner.position++;
      if (_scanner.isDone) {
        _state = _NgSimpleScannerState.text;
        String substring = _scanner.string.substring(offset);
        return new NgSimpleToken.text(offset, substring);
      }
    }
    _state = _NgSimpleScannerState.commentEnd;
    return new NgSimpleToken.text(offset, _scanner.substring(offset));
  }

  NgSimpleToken scanCommentEnd() {
    int offset = _scanner.position;
    _scanner.scan(_commentEnd);
    _state = _NgSimpleScannerState.text;
    return new NgSimpleToken.commentEnd(offset);
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
        if (_scanner.peekChar() == $close_bracket) {
          _scanner.position++;
          return new NgSimpleToken.closeBanana(offset);
        }
        return new NgSimpleToken.closeParen(offset);
      }
      if (matchesGroup(match, 5)) {
        _state = _NgSimpleScannerState.text;
        return new NgSimpleToken.tagEnd(offset);
      }
      if (matchesGroup(match, 6)) {
        if (_scanner.peekChar() == $gt) {
          _scanner.position++;
          _state = _NgSimpleScannerState.text;
          return new NgSimpleToken.voidCloseTag(offset);
        }
        return new NgSimpleToken.forwardSlash(offset);
      }
      if (matchesGroup(match, 7)) {
        if (_scanner.peekChar() == $open_paren) {
          _scanner.position++;
          return new NgSimpleToken.openBanana(offset);
        }
        return new NgSimpleToken.openBracket(offset);
      }
      if (matchesGroup(match, 8)) {
        return new NgSimpleToken.openParen(offset);
      }
      if (matchesGroup(match, 9)) {
        return new NgSimpleToken.whitespace(offset, _scanner.substring(offset));
      }
      if (matchesGroup(match, 10)) {
        String s = _scanner.substring(offset);
        return new NgSimpleToken.identifier(offset, s);
      }
      if (matchesGroup(match, 12)) {
        String lexeme = _scanner.substring(offset).replaceAll(r'\"', '"');
        bool isClosed = lexeme[lexeme.length - 1] == '"';
        return new NgSimpleQuoteToken.doubleQuotedText(
            offset, lexeme, isClosed);
      }
      if (matchesGroup(match, 14)) {
        String lexeme = _scanner.substring(offset).replaceAll(r"\'", "'");
        bool isClosed = lexeme[lexeme.length - 1] == "'";
        return new NgSimpleQuoteToken.singleQuotedText(
            offset, lexeme, isClosed);
      }
      if (matchesGroup(match, 16)) {
        if (_scanner.peekChar() == $exclamation &&
            _scanner.peekChar(1) == $dash &&
            _scanner.peekChar(2) == $dash) {
          _state = _NgSimpleScannerState.comment;
          _scanner.position = offset + 4;
          return new NgSimpleToken.commentBegin(offset);
        }
        if (_scanner.peekChar() == $slash) {
          _scanner.position++;
          return new NgSimpleToken.closeTagStart(offset);
        }
        return new NgSimpleToken.openTagStart(offset);
      }
      if (matchesGroup(match, 17)) {
        return new NgSimpleToken.equalSign(offset);
      }
      if (matchesGroup(match, 18)) {
        return new NgSimpleToken.star(offset);
      }
      if (matchesGroup(match, 19)) {
        return new NgSimpleToken.hash(offset);
      }
      if (matchesGroup(match, 20)) {
        return new NgSimpleToken.period(offset);
      }
    }
    return new NgSimpleToken.unexpectedChar(
        offset, new String.fromCharCode(_scanner.readChar()));
  }

  NgSimpleToken scanText() {
    int offset = _scanner.position;
    if (_scanner.peekChar() == null || _scanner.rest.length == 0) {
      return new NgSimpleToken.EOF(offset);
    }
    if (_scanner.scan(_allTextMatches)) {
      Match match = _scanner.lastMatch;
      if (matchesGroup(match, 1)) {
        return new NgSimpleToken.text(offset, _scanner.substring(offset));
      }
      if (matchesGroup(match, 2)) {
        _state = _NgSimpleScannerState.comment;
        return new NgSimpleToken.commentBegin(offset);
      }
      if (matchesGroup(match, 3)) {
        if (_scanner.peekChar() == $slash) {
          _scanner.position++;
          _state = _NgSimpleScannerState.element;
          return new NgSimpleToken.closeTagStart(offset);
        }
        _state = _NgSimpleScannerState.element;
        return new NgSimpleToken.openTagStart(offset);
      }
    }
    return new NgSimpleToken.unexpectedChar(
        offset, new String.fromCharCode(_scanner.readChar()));
  }
}

enum _NgSimpleScannerState { text, element, comment, commentEnd }
