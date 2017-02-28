// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:core';
import 'dart:math';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:angular_ast/angular_ast.dart';
import 'package:angular_ast/src/token/tokens.dart';

final int generationCount = 10000;
final int iterationCount = 50;

final dir = p.join('test', 'random_generator_test');
String incorrectFilename = "incorrect.html";
String lexerFixedFilename = "lexer_fixed.html";
String fullyFixedFilename = "ast_fixed.html";

String untokenize(Iterable<NgToken> tokens) => tokens
    .fold(new StringBuffer(), (buffer, token) => buffer..write(token.lexeme))
    .toString();

enum State {
  comment,
  element,
  interpolation,
  text,
}

String genericExpression = " + 1 + 2";

final elementMap = <NgSimpleTokenType>[
  NgSimpleTokenType.bang,
  NgSimpleTokenType.closeBanana,
  NgSimpleTokenType.closeBracket,
  NgSimpleTokenType.closeParen,
  NgSimpleTokenType.commentBegin, //Shift state
  NgSimpleTokenType.dash,
  NgSimpleTokenType.doubleQuote, // special
  NgSimpleTokenType.openTagStart,
  NgSimpleTokenType.tagEnd,
  NgSimpleTokenType.equalSign,
  NgSimpleTokenType.forwardSlash,
  NgSimpleTokenType.hash,
  NgSimpleTokenType.identifier,
  NgSimpleTokenType.openBanana,
  NgSimpleTokenType.openBracket,
  NgSimpleTokenType.openParen,
  NgSimpleTokenType.period,
  NgSimpleTokenType.singleQuote, //Special
  NgSimpleTokenType.star,
  NgSimpleTokenType.unexpectedChar,
  NgSimpleTokenType.voidCloseTag,
];

final textMap = <NgSimpleTokenType>[
  NgSimpleTokenType.commentBegin,
  NgSimpleTokenType.openTagStart,
  NgSimpleTokenType.closeTagStart,
  NgSimpleTokenType.mustacheBegin,
  NgSimpleTokenType.text,
];

NgSimpleTokenType generateRandomSimple(State state) {
  Random rng = new Random();
  switch (state) {
    case State.comment:
      if (rng.nextInt(100) <= 20) {
        return NgSimpleTokenType.text;
      }
      return NgSimpleTokenType.commentEnd;
    case State.element:
      int i = rng.nextInt(elementMap.length);
      return elementMap[i];
    case State.interpolation:
      if (rng.nextInt(100) <= 20) {
        return NgSimpleTokenType.text;
      }
      return NgSimpleTokenType.mustacheEnd;
    case State.text:
      int i = rng.nextInt(textMap.length);
      return textMap[i];
    default:
      return NgSimpleTokenType.unexpectedChar;
  }
}

String generateHtmlString() {
  State state = State.text;
  StringBuffer sb = new StringBuffer();
  int identifierCount = 0;
  for (int i = 0; i < generationCount; i++) {
    NgSimpleTokenType type = generateRandomSimple(state);
    switch (state) {
      case State.comment:
        if (type == NgSimpleTokenType.commentEnd) {
          state = State.text;
          sb.write(NgSimpleToken.lexemeMap[type]);
        } else {
          sb.write(" some comment");
        }
        break;
      case State.element:
        if (type == NgSimpleTokenType.commentBegin) {
          state = State.comment;
          sb.write(NgSimpleToken.lexemeMap[type]);
        } else if (type == NgSimpleTokenType.doubleQuote) {
          sb.write('"someDoubleQuoteValue"');
        } else if (type == NgSimpleTokenType.singleQuote) {
          sb.write("'someSingleQuoteValue'");
        } else if (type == NgSimpleTokenType.identifier) {
          sb.write("ident" + identifierCount.toString());
          identifierCount++;
        } else if (type == NgSimpleTokenType.whitespace) {
          sb.write(' ');
        } else if (type == NgSimpleTokenType.voidCloseTag ||
            type == NgSimpleTokenType.tagEnd) {
          state = State.text;
          sb.write(NgSimpleToken.lexemeMap[type]);
        } else {
          sb.write(NgSimpleToken.lexemeMap[type]);
        }
        break;
      case State.interpolation:
        if (type == NgSimpleTokenType.mustacheEnd) {
          state = State.text;
          sb.write(NgSimpleToken.lexemeMap[type]);
        } else {
          sb.write(genericExpression);
        }
        break;
      case State.text:
        if (type == NgSimpleTokenType.commentBegin) {
          state = State.comment;
          sb.write(NgSimpleToken.lexemeMap[type]);
        } else if (type == NgSimpleTokenType.openTagStart ||
            type == NgSimpleTokenType.closeTagStart) {
          state = State.element;
          sb.write(NgSimpleToken.lexemeMap[type]);
        } else if (type == NgSimpleTokenType.mustacheBegin) {
          state = State.interpolation;
          sb.write(NgSimpleToken.lexemeMap[type] + '0');
        } else {
          sb.write("lorem ipsum");
        }
        break;
      default:
        sb.write('');
    }
  }
  return sb.toString();
}

main() async {
  RecoveringExceptionHandler exceptionHandler =
      new RecoveringExceptionHandler();

  int totalIncorrectLength = 0;
  int totalLexerTime = 0;
  int totalParserTime = 0;

  for (int i = 0; i < iterationCount; i++) {
    print("Iteration $i of $iterationCount ...");
    Stopwatch stopwatch = new Stopwatch();

    String incorrectHtml = generateHtmlString();
    totalIncorrectLength += incorrectHtml.length;
    await new File(p.join(dir, incorrectFilename)).writeAsString(incorrectHtml);

    stopwatch.reset();
    stopwatch.start();
    Iterable<NgToken> lexerTokens =
        const NgLexer().tokenize(incorrectHtml, exceptionHandler);
    stopwatch.stop();
    totalLexerTime += stopwatch.elapsedMicroseconds;
    String lexerFixedString = untokenize(lexerTokens);
    await new File(p.join(dir, lexerFixedFilename))
        .writeAsString(lexerFixedString);
    exceptionHandler.exceptions.clear();

    stopwatch.reset();
    stopwatch.start();
    List<StandaloneTemplateAst> ast = const NgParser().parsePreserve(
      incorrectHtml,
      sourceUrl: '/test/parser_test.dart#inline',
      exceptionHandler: exceptionHandler,
    );
    stopwatch.stop();
    totalParserTime += stopwatch.elapsedMilliseconds;
    HumanizingTemplateAstVisitor visitor = const HumanizingTemplateAstVisitor();
    String fixedString = ast.map((t) => t.accept(visitor)).join('');
    await new File(p.join(dir, fullyFixedFilename)).writeAsString(fixedString);
    exceptionHandler.exceptions.clear();
  }

  print("Total lines scanned/parsed: $totalIncorrectLength");
  print("Total time for lexer: $totalLexerTime microseconds");
  print("Total time for parser: $totalParserTime ms");
}
