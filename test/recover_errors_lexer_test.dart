// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/angular_ast.dart';
import 'package:angular_ast/src/scanner.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/parser/reader.dart';
import 'package:test/test.dart';

ThrowingExceptionHandler throwingException = new ThrowingExceptionHandler();
RecoveringExceptionHandler recoveringException =
    new RecoveringExceptionHandler();
RecoveryProtocol recoveryProtocol = new NgAnalyzerRecoveryProtocol();

Iterable<NgToken> tokenize(String html) {
  recoveringException.exceptions.clear();
  return const NgLexer().tokenize(html, recoveringException);
}

Iterator<NgToken> tokenizeThrow(String html) {
  return const NgLexer().tokenize(html, throwingException).iterator;
}

void unwrapAll(Iterator<NgToken> it) {
  while (it.moveNext() != null) {}
}

String untokenize(Iterable<NgToken> tokens) => tokens
    .fold(new StringBuffer(), (buffer, token) => buffer..write(token.lexeme))
    .toString();

void testRecoverySolution(
  String baseHtml,
  NgScannerState startState,
  List<NgSimpleTokenType> encounteredTokens,
  NgTokenType expectedSyntheticType,
  NgScannerState expectedNextState, {
  String syntheticLexeme: "",
}) {
  int recoveryOffset = baseHtml.length;

  for (NgSimpleTokenType type in encounteredTokens) {
    NgTokenReversibleReader reader = new NgTokenReversibleReader(null, []);
    NgSimpleToken token = new NgSimpleToken(type, recoveryOffset, '');

    String errorString;
    if (type == NgSimpleTokenType.doubleQuote) {
      errorString = '""';
    } else if (type == NgSimpleTokenType.identifier) {
      errorString = "some-identifier";
    } else {
      errorString = NgSimpleToken.lexemeMap[type];
    }
    String errorHtml = baseHtml + errorString;

    test("should resolve: unexpected $type in $startState", () async {
      Iterator<NgToken> it = tokenizeThrow(errorHtml);
      expect(() {
        while (it.moveNext() != null) {}
      }, throwsFormatException);

      RecoverySolution solution =
          recoveryProtocol.recover(startState, token, reader);

      NgToken expectedSynthetic;
      if (expectedSyntheticType == null) {
        expectedSynthetic = null;
      } else if (expectedSyntheticType == NgTokenType.doubleQuote) {
        NgToken left = new NgToken.generateErrorSynthetic(
            recoveryOffset, NgTokenType.doubleQuote);
        NgToken value = new NgToken.generateErrorSynthetic(
            recoveryOffset, NgTokenType.elementDecoratorValue);
        NgToken right = new NgToken.generateErrorSynthetic(
            recoveryOffset, NgTokenType.doubleQuote);
        expectedSynthetic =
            new NgAttributeValueToken.generate(left, value, right);
      } else {
        expectedSynthetic = new NgToken.generateErrorSynthetic(
          recoveryOffset,
          expectedSyntheticType,
          lexeme: syntheticLexeme,
        );
      }
      expect(solution.tokenToReturn, expectedSynthetic);
      expect(solution.nextState, expectedNextState);
    });
  }
}

void main() {
  afterComment();
  afterElementDecorator();
  afterElementDecoratorValue();
  afterInterpolation();
  comment();
  elementDecorator();
  elementDecoratorValue();
  elementIdentifierOpen();
  elementIdentifierClose();
  afterElementIdentifierClose();
  afterElementIdentifierOpen();
  elementEndClose();
  simpleElementDecorator();
  specialBananaDecorator();
  specialEventDecorator();
  specialPropertyDecorator();
  suffixBanana();
  suffixEvent();
  suffixProperty();
}

void afterComment() {
  test('should resolve: unexpected EOF in afterComment', () {
    Iterable<NgToken> results = tokenize('<!-- some comment ');
    expect(
      results,
      [
        new NgToken.commentStart(0),
        new NgToken.commentValue(4, ' some comment '),
        new NgToken.commentEnd(18)
      ],
    );
    expect(recoveringException.exceptions.length, 1);
    FormatException e = recoveringException.exceptions[0];
    expect(e.source, '');
    expect(e.offset, 18);
  });
}

void afterInterpolation() {
  test('should resolve: unexpected EOF in elementEndClose', () {
    Iterable<NgToken> results = tokenize('{{1 + 2 + 3');
    expect(
      results,
      [
        new NgToken.interpolationStart(0),
        new NgToken.interpolationValue(2, '1 + 2 + 3'),
        new NgToken.interpolationEnd(11), // Synthetic
      ],
    );
    expect(recoveringException.exceptions.length, 1);
    FormatException e = recoveringException.exceptions[0];
    expect(e.source, '');
    expect(e.offset, 11);

    expect(untokenize(results), '{{1 + 2 + 3}}');
  });
}

void comment() {
  test('should resolve: unexpected EOF in scanComment', () {
    Iterable<NgToken> results = tokenize('<!-- some comment ');
    expect(
      results,
      [
        new NgToken.commentStart(0),
        new NgToken.commentValue(4, ' some comment '),
        new NgToken.commentEnd(18)
      ],
    );
    expect(recoveringException.exceptions.length, 1);
    FormatException e = recoveringException.exceptions[0];
    expect(e.source, '');
    expect(e.offset, 18);
  });
}

void elementIdentifierClose() {
  String baseHtml = "</";
  NgScannerState startState = NgScannerState.scanElementIdentifierClose;

  List<NgSimpleTokenType> resolveTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.closeTagStart,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.tagEnd,
    NgSimpleTokenType.commentBegin,
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.whitespace,
  ];
  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.openParen,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.closeParen,
    NgSimpleTokenType.closeBanana,
    NgSimpleTokenType.dash,
    NgSimpleTokenType.equalSign,
    NgSimpleTokenType.doubleQuote,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.star,
    NgSimpleTokenType.period,
    NgSimpleTokenType.unexpectedChar,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens,
    NgTokenType.elementIdentifier,
    NgScannerState.scanAfterElementIdentifierClose,
  );

  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  test("Testing resolved strings of $startState", () {
    expect(untokenize(tokenize('</<div>')), '</><div>');
    expect(untokenize(tokenize('</<!--comment-->')), '</><!--comment-->');
    expect(untokenize(tokenize('</</div>')), '</></div>');
    expect(untokenize(tokenize('</>')), '</>');
    expect(untokenize(tokenize('</')), '</>');
    expect(untokenize(tokenize('</ <div>')), '</ ><div>');
    expect(untokenize(tokenize('</!')), '</>');
    expect(untokenize(tokenize('</[')), '</>');
    expect(untokenize(tokenize('</]')), '</>');
    expect(untokenize(tokenize('</(')), '</>');
    expect(untokenize(tokenize('</)')), '</>');
    expect(untokenize(tokenize('</[(')), '</>');
    expect(untokenize(tokenize('</)]')), '</>');
    expect(untokenize(tokenize('</-')), '</>');
    expect(untokenize(tokenize('</=')), '</>');
    expect(untokenize(tokenize('<//')), '</>');
    expect(untokenize(tokenize('</#')), '</>');
    expect(untokenize(tokenize('</*')), '</>');
    expect(untokenize(tokenize('</.')), '</>');
    expect(untokenize(tokenize('</"blah"')), '</>');
    expect(untokenize(tokenize('</@')), '</>');
  });
}

void elementIdentifierOpen() {
  String baseHtml = "<";
  NgScannerState startState = NgScannerState.scanElementIdentifierOpen;

  List<NgSimpleTokenType> resolveTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.openParen,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.closeParen,
    NgSimpleTokenType.closeBanana,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.star,
    NgSimpleTokenType.commentBegin,
    NgSimpleTokenType.commentEnd,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
    NgSimpleTokenType.tagEnd,
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.equalSign,
    NgSimpleTokenType.doubleQuote,
    NgSimpleTokenType.whitespace,
    NgSimpleTokenType.bang,
    NgSimpleTokenType.dash,
    NgSimpleTokenType.period,
    NgSimpleTokenType.unexpectedChar,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens,
    NgTokenType.elementIdentifier,
    NgScannerState.scanAfterElementIdentifierOpen,
  );

  test("Testing resolved strings of $startState", () {
    expect(untokenize(tokenize('<!>')), '<>');
    expect(untokenize(tokenize('<->')), '<>');
    expect(untokenize(tokenize('<.>')), '<>');
    expect(untokenize(tokenize('<[someProp]>')), '< [someProp]>');
    expect(untokenize(tokenize('<]>')), '< []>');
    expect(untokenize(tokenize('<(someEvnt)>')), '< (someEvnt)>');
    expect(untokenize(tokenize('<)>')), '< ()>');
    expect(untokenize(tokenize('<[(someBnna)]>')), '< [(someBnna)]>');
    expect(untokenize(tokenize('<)]>')), '< [()]>');
    expect(untokenize(tokenize('<#someRef>')), '< #someRef>');
    expect(untokenize(tokenize('<*someTemp>')), '< *someTemp>');
    expect(untokenize(tokenize('<<!-- comment -->')), '<><!-- comment -->');
    expect(untokenize(tokenize('<<div>')), '<><div>');
    expect(untokenize(tokenize('<</div>')), '<></div>');
    expect(untokenize(tokenize('<>')), '<>');
    expect(untokenize(tokenize('<')), '<>');
    expect(untokenize(tokenize('<"blah">')), '< ="blah">');
    expect(untokenize(tokenize('<="blah">')), '< ="blah">');
    expect(untokenize(tokenize('< >')), '< >');
    expect(untokenize(tokenize('<@>')), '<>');
  });
}

void afterElementIdentifierClose() {
  String baseHtml = "</div";
  NgScannerState startState = NgScannerState.scanAfterElementIdentifierClose;

  List<NgSimpleTokenType> resolveTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.commentBegin,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.voidCloseTag,
  ];

  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.openParen,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.closeParen,
    NgSimpleTokenType.closeBanana,
    NgSimpleTokenType.equalSign,
    NgSimpleTokenType.forwardSlash,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.star,
    NgSimpleTokenType.period,
    NgSimpleTokenType.unexpectedChar,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens,
    NgTokenType.closeElementEnd,
    NgScannerState.scanStart,
  );

  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  test("Testing resolved strings of $startState", () {
    expect(untokenize(tokenize('</div<div>')), '</div><div>');
    expect(untokenize(tokenize('</div<!--comment-->')), '</div><!--comment-->');
    expect(untokenize(tokenize('</div</div>')), '</div></div>');
    expect(untokenize(tokenize('</div')), '</div>');
    expect(untokenize(tokenize('</div/>')), '</div>');
    expect(untokenize(tokenize('</div!>')), '</div>');
    expect(untokenize(tokenize('</div[>')), '</div>');
    expect(untokenize(tokenize('</div]>')), '</div>');
    expect(untokenize(tokenize('</div(>')), '</div>');
    expect(untokenize(tokenize('</div)>')), '</div>');
    expect(untokenize(tokenize('</div[(>')), '</div>');
    expect(untokenize(tokenize('</div)]>')), '</div>');
    expect(untokenize(tokenize('</div=>')), '</div>');
    expect(untokenize(tokenize('</div/ >')), '</div >');
    expect(untokenize(tokenize('</div#>')), '</div>');
    expect(untokenize(tokenize('</div*>')), '</div>');
    expect(untokenize(tokenize('</div@>')), '</div>');
    expect(untokenize(tokenize('</div"blah">')), '</div>');
  });
}

void afterElementIdentifierOpen() {
  String baseHtml = "<div";
  NgScannerState startState = NgScannerState.scanAfterElementIdentifierOpen;

  List<NgSimpleTokenType> resolveTokens1 = <NgSimpleTokenType>[
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.openParen,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.closeParen,
    NgSimpleTokenType.closeBanana,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.star,
    NgSimpleTokenType.equalSign,
    NgSimpleTokenType.doubleQuote,
  ];

  List<NgSimpleTokenType> resolveTokens2 = <NgSimpleTokenType>[
    NgSimpleTokenType.commentBegin,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
    NgSimpleTokenType.EOF,
  ];

  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.forwardSlash,
    NgSimpleTokenType.period,
    NgSimpleTokenType.unexpectedChar,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens1,
    NgTokenType.beforeElementDecorator,
    NgScannerState.scanElementDecorator,
    syntheticLexeme: ' ',
  );

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens2,
    NgTokenType.openElementEnd,
    NgScannerState.scanStart,
  );

  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  test("Testing resolved strings of $startState", () {
    expect(untokenize(tokenize('<div!>')), '<div>');
    expect(untokenize(tokenize('<div.>')), '<div>');
    expect(untokenize(tokenize('<div[someProp]>')), '<div [someProp]>');
    expect(untokenize(tokenize('<div]>')), '<div []>');
    expect(untokenize(tokenize('<div(someEvnt)>')), '<div (someEvnt)>');
    expect(untokenize(tokenize('<div)>')), '<div ()>');
    expect(untokenize(tokenize('<div[(someBnna)]>')), '<div [(someBnna)]>');
    expect(untokenize(tokenize('<div)]>')), '<div [()]>');
    expect(untokenize(tokenize('<div#someRef>')), '<div #someRef>');
    expect(untokenize(tokenize('<div*someTemp>')), '<div *someTemp>');
    expect(
        untokenize(tokenize('<div<!-- comment -->')), '<div><!-- comment -->');
    expect(untokenize(tokenize('<div<div>')), '<div><div>');
    expect(untokenize(tokenize('<div</div>')), '<div></div>');
    expect(untokenize(tokenize('<div')), '<div>');
    expect(untokenize(tokenize('<div"blah">')), '<div ="blah">');
    expect(untokenize(tokenize('<div="blah">')), '<div ="blah">');
    expect(untokenize(tokenize('<div@>')), '<div>');
  });
}

void afterElementDecorator() {
  String baseHtml = "<div attr";
  NgScannerState startState = NgScannerState.scanAfterElementDecorator;

  List<NgSimpleTokenType> resolveTokens1 = <NgSimpleTokenType>[
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.openParen,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.closeParen,
    NgSimpleTokenType.closeBanana,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.star,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens1,
    NgTokenType.beforeElementDecorator,
    NgScannerState.scanElementDecorator,
    syntheticLexeme: ' ',
  );

  List<NgSimpleTokenType> resolveTokens2 = <NgSimpleTokenType>[
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.commentBegin,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens2,
    NgTokenType.openElementEnd,
    NgScannerState.scanStart,
  );

  List<NgSimpleTokenType> resolveTokens3 = <NgSimpleTokenType>[
    NgSimpleTokenType.doubleQuote,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens3,
    NgTokenType.beforeElementDecoratorValue,
    NgScannerState.scanElementDecoratorValue,
  );

  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.forwardSlash,
    NgSimpleTokenType.unexpectedChar,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  test("Testing resolved strings of $startState", () {
    expect(untokenize(tokenize('<div blah!></div>')), '<div blah></div>');
    expect(untokenize(tokenize('<div blah[someProp]="x"></div>')),
        '<div blah [someProp]="x"></div>');
    expect(untokenize(tokenize('<div blah]="x"></div>')),
        '<div blah []="x"></div>');
    expect(untokenize(tokenize('<div blah(someProp)="x"></div>')),
        '<div blah (someProp)="x"></div>');
    expect(untokenize(tokenize('<div blah)="x"></div>')),
        '<div blah ()="x"></div>');
    expect(untokenize(tokenize('<div blah[(someBnna)]="x"></div>')),
        '<div blah [(someBnna)]="x"></div>');
    expect(untokenize(tokenize('<div bnna)]="x"></div>')),
        '<div bnna [()]="x"></div>');
    expect(untokenize(tokenize('<div blah<!-- comment -->')),
        '<div blah><!-- comment -->');
    expect(untokenize(tokenize('<div blah<span>')), '<div blah><span>');
    expect(untokenize(tokenize('<div blah</div>')), '<div blah></div>');
    expect(untokenize(tokenize('<div blah')), '<div blah>');
    expect(untokenize(tokenize('<div blah#someRef>')), '<div blah #someRef>');
    expect(untokenize(tokenize('<div blah*myTemp>')), '<div blah *myTemp>');
    expect(untokenize(tokenize('<div blah"quotedText">')),
        '<div blah="quotedText">');
    expect(untokenize(tokenize('<div blah@>')), '<div blah>');
  });
}

void afterElementDecoratorValue() {
  String baseHtml = '<div someName="someValue"';
  NgScannerState startState = NgScannerState.scanAfterElementDecoratorValue;

  List<NgSimpleTokenType> resolveTokens1 = <NgSimpleTokenType>[
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.openParen,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.star,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.closeParen,
    NgSimpleTokenType.closeBanana,
    NgSimpleTokenType.identifier,
    NgSimpleTokenType.equalSign,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens1,
    NgTokenType.beforeElementDecorator,
    NgScannerState.scanElementDecorator,
    syntheticLexeme: ' ',
  );

  List<NgSimpleTokenType> resolveTokens2 = <NgSimpleTokenType>[
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.commentBegin,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens2,
    NgTokenType.openElementEnd,
    NgScannerState.scanStart,
  );

  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.dash,
    NgSimpleTokenType.forwardSlash,
    NgSimpleTokenType.period,
    NgSimpleTokenType.unexpectedChar,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  test("Testing resolved strings of $startState", () {
    expect(untokenize(tokenize('<div someName="someValue"!>')),
        '<div someName="someValue">');
    expect(untokenize(tokenize('<div someName="someValue"[someProp]>')),
        '<div someName="someValue" [someProp]>');
    expect(untokenize(tokenize('<div someName="someValue"]>')),
        '<div someName="someValue" []>');
    expect(untokenize(tokenize('<div someName="someValue"(someEvent)>')),
        '<div someName="someValue" (someEvent)>');
    expect(untokenize(tokenize('<div someName="someValue")>')),
        '<div someName="someValue" ()>');
    expect(untokenize(tokenize('<div someName="someValue"[(someEvent)]>')),
        '<div someName="someValue" [(someEvent)]>');
    expect(untokenize(tokenize('<div someName="someValue")]>')),
        '<div someName="someValue" [()]>');
    expect(untokenize(tokenize('<div someName="someValue"<!-- comment -->')),
        '<div someName="someValue"><!-- comment -->');
    expect(untokenize(tokenize('<div someName="someValue"->')),
        '<div someName="someValue">');
    expect(untokenize(tokenize('<div someName="someValue"<span>')),
        '<div someName="someValue"><span>');
    expect(untokenize(tokenize('<div someName="someValue"</div>')),
        '<div someName="someValue"></div>');
    expect(untokenize(tokenize('<div someName="someValue"')),
        '<div someName="someValue">');
    expect(untokenize(tokenize('<div someName="someValue"="otherValue">')),
        '<div someName="someValue" ="otherValue">');
    expect(untokenize(tokenize('<div someName="someValue"*someTemp>')),
        '<div someName="someValue" *someTemp>');
    expect(untokenize(tokenize('<div someName="someValue"#someRef>')),
        '<div someName="someValue" #someRef>');
    expect(untokenize(tokenize('<div someName="someValue"someOther>')),
        '<div someName="someValue" someOther>');
    expect(untokenize(tokenize('<div someName="someValue".>')),
        '<div someName="someValue">');
    expect(untokenize(tokenize('<div someName="someValue""quotedText">')),
        '<div someName="someValue" ="quotedText">');
    expect(untokenize(tokenize('<div someName="someValue"@>')),
        '<div someName="someValue">');
  });
}

void elementDecorator() {
  String baseHtml = "<div ";
  NgScannerState startState = NgScannerState.scanElementDecorator;

  List<NgSimpleTokenType> resolveTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.equalSign,
    NgSimpleTokenType.commentBegin,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.doubleQuote,
    NgSimpleTokenType.dash,
    NgSimpleTokenType.unexpectedChar,
    NgSimpleTokenType.period,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens,
    NgTokenType.elementDecorator,
    NgScannerState.scanAfterElementDecorator,
    syntheticLexeme: '',
  );

  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.forwardSlash,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  List<NgSimpleTokenType> beginPropertyTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.closeBracket,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    beginPropertyTokens,
    NgTokenType.propertyPrefix,
    NgScannerState.scanSpecialPropertyDecorator,
  );

  List<NgSimpleTokenType> beginEventTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.closeParen,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    beginEventTokens,
    NgTokenType.eventPrefix,
    NgScannerState.scanSpecialEventDecorator,
  );

  List<NgSimpleTokenType> beginBananaTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.closeBanana,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    beginBananaTokens,
    NgTokenType.bananaPrefix,
    NgScannerState.scanSpecialBananaDecorator,
  );

  test("Testing resolved strings of $startState", () {
    expect(untokenize(tokenize('<div ]>')), '<div []>');
    expect(untokenize(tokenize('<div )>')), '<div ()>');
    expect(untokenize(tokenize('<div )]>')), '<div [()]>');
    expect(untokenize(tokenize('<div <!-- comment -->')),
        '<div ><!-- comment -->');
    expect(untokenize(tokenize('<div <span>')), '<div ><span>');
    expect(untokenize(tokenize('<div </div>')), '<div ></div>');
    expect(untokenize(tokenize('<div ')), '<div >');
    expect(untokenize(tokenize('<div ->')), '<div >');
    expect(untokenize(tokenize('<div @>')), '<div >');
    expect(untokenize(tokenize('<div !attr>')), '<div attr>');
    expect(untokenize(tokenize('<div "blah">')), '<div ="blah">');
    expect(untokenize(tokenize('<div ="blah">')), '<div ="blah">');
  });
}

void elementDecoratorValue() {
  String baseHtml = "<div attr=";
  NgScannerState startState = NgScannerState.scanElementDecoratorValue;

  List<NgSimpleTokenType> resolveTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.openParen,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.closeParen,
    NgSimpleTokenType.closeBanana,
    NgSimpleTokenType.commentBegin,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
    NgSimpleTokenType.tagEnd,
    NgSimpleTokenType.voidCloseTag,
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.equalSign,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.identifier,
    NgSimpleTokenType.star,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens,
    NgTokenType.doubleQuote,
    NgScannerState.scanAfterElementDecoratorValue,
  );

  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.dash,
    NgSimpleTokenType.forwardSlash,
    NgSimpleTokenType.period,
    NgSimpleTokenType.unexpectedChar,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  test("Testing resolved strings of $startState", () {
    expect(untokenize(tokenize('<div attr=!>')), '<div attr="">');
    expect(untokenize(tokenize('<div attr=->')), '<div attr="">');
    expect(untokenize(tokenize('<div attr=@>')), '<div attr="">');
    expect(untokenize(tokenize('<div attr=.>')), '<div attr="">');
    expect(untokenize(tokenize('<div attr=/ >')), '<div attr= "">');
    expect(
        untokenize(tokenize('<div attr=#someRef>')), '<div attr="" #someRef>');
    expect(untokenize(tokenize('<div attr=*someTemp>')),
        '<div attr="" *someTemp>');
    expect(untokenize(tokenize('<div attr=blah>')), '<div attr="" blah>');
    expect(untokenize(tokenize('<div attr=[someProp]>')),
        '<div attr="" [someProp]>');
    expect(untokenize(tokenize('<div attr=]>')), '<div attr="" []>');
    expect(untokenize(tokenize('<div attr=(someEvnt)>')),
        '<div attr="" (someEvnt)>');
    expect(untokenize(tokenize('<div attr=)>')), '<div attr="" ()>');
    expect(untokenize(tokenize('<div attr=[(someBnna)]>')),
        '<div attr="" [(someBnna)]>');
    expect(untokenize(tokenize('<div attr=)]>')), '<div attr="" [()]>');
    expect(untokenize(tokenize('<div attr=<!-- comment -->')),
        '<div attr=""><!-- comment -->');
    expect(untokenize(tokenize('<div attr=<span>')), '<div attr=""><span>');
    expect(untokenize(tokenize('<div attr=</div>')), '<div attr=""></div>');
    expect(untokenize(tokenize('<div attr=>')), '<div attr="">');
    expect(untokenize(tokenize('<div attr=/>')), '<div attr=""/>');
    expect(untokenize(tokenize('<div attr=="blah">')), '<div attr="" ="blah">');
  });
}

void elementEndClose() {
  String baseHtml = "</div";
  NgScannerState startState = NgScannerState.scanElementEndClose;

  List<NgSimpleTokenType> resolveTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.commentBegin,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.whitespace,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens,
    NgTokenType.closeElementEnd,
    NgScannerState.scanStart,
  );

  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.openParen,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.closeParen,
    NgSimpleTokenType.closeBanana,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.star,
    NgSimpleTokenType.dash,
    NgSimpleTokenType.equalSign,
    NgSimpleTokenType.identifier,
    NgSimpleTokenType.period,
    NgSimpleTokenType.doubleQuote,
    NgSimpleTokenType.unexpectedChar,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  test("Testing resolved strings of $startState", () {
    expect(untokenize(tokenize('</div <div>')), '</div ><div>');
    expect(
        untokenize(tokenize('</div <!--comment-->')), '</div ><!--comment-->');
    expect(untokenize(tokenize('</div </div>')), '</div ></div>');
    expect(untokenize(tokenize('</div ')), '</div >');
    expect(untokenize(tokenize('</div /><div>')), '</div ><div>');
    expect(untokenize(tokenize('</div !>')), '</div >');
    expect(untokenize(tokenize('</div [>')), '</div >');
    expect(untokenize(tokenize('</div ]>')), '</div >');
    expect(untokenize(tokenize('</div (>')), '</div >');
    expect(untokenize(tokenize('</div )>')), '</div >');
    expect(untokenize(tokenize('</div [(>')), '</div >');
    expect(untokenize(tokenize('</div )]>')), '</div >');
    expect(untokenize(tokenize('</div ->')), '</div >');
    expect(untokenize(tokenize('</div =>')), '</div >');
    expect(untokenize(tokenize('</div .>')), '</div >');
    expect(untokenize(tokenize('</div #>')), '</div >');
    expect(untokenize(tokenize('</div *>')), '</div >');
    expect(untokenize(tokenize('</div @>')), '</div >');
    expect(untokenize(tokenize('</div blah>')), '</div >');
    expect(untokenize(tokenize('</div "blah">')), '</div >');
  });
}

void simpleElementDecorator() {
  String baseHtml = "<div #";
  NgScannerState startState = NgScannerState.scanSimpleElementDecorator;

  List<NgSimpleTokenType> resolveTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.openParen,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.closeParen,
    NgSimpleTokenType.closeBanana,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.star,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
    NgSimpleTokenType.tagEnd,
    NgSimpleTokenType.voidCloseTag,
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.equalSign,
    NgSimpleTokenType.doubleQuote,
    NgSimpleTokenType.whitespace,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens,
    NgTokenType.elementDecorator,
    NgScannerState.scanAfterElementDecorator,
  );

  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.dash,
    NgSimpleTokenType.forwardSlash,
    NgSimpleTokenType.period,
    NgSimpleTokenType.unexpectedChar,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  test("Testing resolved strings of $startState", () {
    expect(untokenize(tokenize('<div #[prop]>')), '<div # [prop]>');
    expect(untokenize(tokenize('<div #(evnt)>')), '<div # (evnt)>');
    expect(untokenize(tokenize('<div #[(bnna)]>')), '<div # [(bnna)]>');
    expect(untokenize(tokenize('<div #]>')), '<div # []>');
    expect(untokenize(tokenize('<div #)>')), '<div # ()>');
    expect(untokenize(tokenize('<div #)]>')), '<div # [()]>');
    expect(untokenize(tokenize('<div #*myTemp>')), '<div # *myTemp>');
    expect(untokenize(tokenize('<div ##myRefr>')), '<div # #myRefr>');
    expect(untokenize(tokenize('<div #')), '<div #>');
    expect(untokenize(tokenize('<div #<span>')), '<div #><span>');
    expect(
        untokenize(tokenize('<div #<!--comment-->')), '<div #><!--comment-->');
    expect(untokenize(tokenize('<div #</div>')), '<div #></div>');
    expect(untokenize(tokenize('<div #>')), '<div #>');
    expect(untokenize(tokenize('<div #/>')), '<div #/>');
    expect(untokenize(tokenize('<div #="blah">')), '<div #="blah">');
    expect(untokenize(tokenize('<div #"blah">')), '<div #="blah">');
    expect(untokenize(tokenize('<div # blah>')), '<div # blah>');
    expect(untokenize(tokenize('<div #!refr>')), '<div #refr>');
    expect(untokenize(tokenize('<div #-refr>')), '<div #refr>');
    expect(untokenize(tokenize('<div #/refr>')), '<div #refr>');
    expect(untokenize(tokenize('<div #@refr>')), '<div #refr>');
  });
}

void specialBananaDecorator() {
  String baseHtml = "<div [(";
  NgScannerState startState = NgScannerState.scanSpecialBananaDecorator;

  List<NgSimpleTokenType> resolveTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.openParen,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.closeParen,
    NgSimpleTokenType.closeBanana,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.star,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
    NgSimpleTokenType.tagEnd,
    NgSimpleTokenType.voidCloseTag,
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.equalSign,
    NgSimpleTokenType.doubleQuote,
    NgSimpleTokenType.whitespace,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens,
    NgTokenType.elementDecorator,
    NgScannerState.scanSuffixBanana,
  );

  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.dash,
    NgSimpleTokenType.forwardSlash,
    NgSimpleTokenType.unexpectedChar,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  test("Testing resolved strings of $startState", () {
    expect(untokenize(tokenize('<div [([myProp]>')), '<div [()] [myProp]>');
    expect(untokenize(tokenize('<div [((myEvnt)>')), '<div [()] (myEvnt)>');
    expect(untokenize(tokenize('<div [([(myBnna)]>')), '<div [()] [(myBnna)]>');
    expect(untokenize(tokenize('<div [(]>')), '<div [()] []>');
    expect(untokenize(tokenize('<div [()>')), '<div [()] ()>');
    expect(untokenize(tokenize('<div [()]>')), '<div [()]>');
    expect(untokenize(tokenize('<div [(*myTemp>')), '<div [()] *myTemp>');
    expect(untokenize(tokenize('<div [(#myRefr>')), '<div [()] #myRefr>');
    expect(untokenize(tokenize('<div [(<!--comment-->')),
        '<div [()]><!--comment-->');
    expect(untokenize(tokenize('<div [(<span>')), '<div [()]><span>');
    expect(untokenize(tokenize('<div [(</div>')), '<div [()]></div>');
    expect(untokenize(tokenize('<div [(>')), '<div [()]>');
    expect(untokenize(tokenize('<div [(/>')), '<div [()]/>');
    expect(untokenize(tokenize('<div [(')), '<div [()]>');
    expect(untokenize(tokenize('<div [(=>')), '<div [()]="">');
    expect(untokenize(tokenize('<div [("blah">')), '<div [()]="blah">');
    expect(untokenize(tokenize('<div [( blah>')), '<div [()] blah>');
    expect(untokenize(tokenize('<div [(!bnna)]>')), '<div [(bnna)]>');
    expect(untokenize(tokenize('<div [(-bnna)]>')), '<div [(bnna)]>');
    expect(untokenize(tokenize('<div [(/bnna)]>')), '<div [(bnna)]>');
    expect(untokenize(tokenize('<div [(@bnna)]>')), '<div [(bnna)]>');
  });
}

void specialEventDecorator() {
  String baseHtml = "<div (";
  NgScannerState startState = NgScannerState.scanSpecialEventDecorator;

  List<NgSimpleTokenType> resolveTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.openParen,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.closeParen,
    NgSimpleTokenType.closeBanana,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.star,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
    NgSimpleTokenType.tagEnd,
    NgSimpleTokenType.voidCloseTag,
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.equalSign,
    NgSimpleTokenType.doubleQuote,
    NgSimpleTokenType.whitespace,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens,
    NgTokenType.elementDecorator,
    NgScannerState.scanSuffixEvent,
  );

  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.dash,
    NgSimpleTokenType.forwardSlash,
    NgSimpleTokenType.unexpectedChar,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  test("Testing resolved strings of $startState", () {
    expect(untokenize(tokenize('<div ([myProp]>')), '<div () [myProp]>');
    expect(untokenize(tokenize('<div ((myEvnt)>')), '<div () (myEvnt)>');
    expect(untokenize(tokenize('<div ([(myBnna)]>')), '<div () [(myBnna)]>');
    expect(untokenize(tokenize('<div (]>')), '<div () []>');
    expect(untokenize(tokenize('<div ()>')), '<div ()>');
    expect(untokenize(tokenize('<div ()]>')), '<div () [()]>');
    expect(untokenize(tokenize('<div (*myTemp>')), '<div () *myTemp>');
    expect(untokenize(tokenize('<div (#myRefr>')), '<div () #myRefr>');
    expect(
        untokenize(tokenize('<div (<!--comment-->')), '<div ()><!--comment-->');
    expect(untokenize(tokenize('<div (<span>')), '<div ()><span>');
    expect(untokenize(tokenize('<div (</div>')), '<div ()></div>');
    expect(untokenize(tokenize('<div (>')), '<div ()>');
    expect(untokenize(tokenize('<div (/>')), '<div ()/>');
    expect(untokenize(tokenize('<div (')), '<div ()>');
    expect(untokenize(tokenize('<div (=>')), '<div ()="">');
    expect(untokenize(tokenize('<div ("blah">')), '<div ()="blah">');
    expect(untokenize(tokenize('<div ( attr>')), '<div () attr>');
    expect(untokenize(tokenize('<div (!evnt)>')), '<div (evnt)>');
    expect(untokenize(tokenize('<div (-evnt)>')), '<div (evnt)>');
    expect(untokenize(tokenize('<div (@evnt)>')), '<div (evnt)>');
    expect(untokenize(tokenize('<div (/evnt)>')), '<div (evnt)>');
  });
}

void specialPropertyDecorator() {
  String baseHtml = "<div [";
  NgScannerState startState = NgScannerState.scanSpecialPropertyDecorator;

  List<NgSimpleTokenType> resolveTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.closeParen,
    NgSimpleTokenType.closeBanana,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.star,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
    NgSimpleTokenType.tagEnd,
    NgSimpleTokenType.voidCloseTag,
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.equalSign,
    NgSimpleTokenType.doubleQuote,
    NgSimpleTokenType.whitespace,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens,
    NgTokenType.elementDecorator,
    NgScannerState.scanSuffixProperty,
  );

  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.dash,
    NgSimpleTokenType.forwardSlash,
    NgSimpleTokenType.unexpectedChar,
  ];

  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  test("Testing resolved strings of $startState", () {
    expect(untokenize(tokenize('<div [[myProp]>')), '<div [] [myProp]>');
    expect(untokenize(tokenize('<div [[(myBnna)]>')), '<div [] [(myBnna)]>');
    expect(untokenize(tokenize('<div []>')), '<div []>');
    expect(untokenize(tokenize('<div [)>')), '<div [] ()>');
    expect(untokenize(tokenize('<div [)]>')), '<div [] [()]>');
    expect(untokenize(tokenize('<div [*myTemp>')), '<div [] *myTemp>');
    expect(untokenize(tokenize('<div [#myRefr>')), '<div [] #myRefr>');
    expect(untokenize(tokenize('<div [')), '<div []>');
    expect(untokenize(tokenize('<div [<span>')), '<div []><span>');
    expect(
        untokenize(tokenize('<div [<!--comment-->')), '<div []><!--comment-->');
    expect(untokenize(tokenize('<div [</div>')), '<div []></div>');
    expect(untokenize(tokenize('<div [>')), '<div []>');
    expect(untokenize(tokenize('<div [/>')), '<div []/>');
    expect(untokenize(tokenize('<div ["blah">')), '<div []="blah">');
    expect(untokenize(tokenize('<div [="blah">')), '<div []="blah">');
    expect(untokenize(tokenize('<div [ attr>')), '<div [] attr>');
    expect(untokenize(tokenize('<div [!prop]>')), '<div [prop]>');
    expect(untokenize(tokenize('<div [-prop]>')), '<div [prop]>');
    expect(untokenize(tokenize('<div [/prop]>')), '<div [prop]>');
    expect(untokenize(tokenize('<div [@prop]>')), '<div [prop]>');
  });
}

void suffixBanana() {
  String baseHtml = "<div [(bnna";
  NgScannerState startState = NgScannerState.scanSuffixBanana;

  List<NgSimpleTokenType> resolveTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.openParen,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.closeParen,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.star,
    NgSimpleTokenType.commentBegin,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
    NgSimpleTokenType.tagEnd,
    NgSimpleTokenType.voidCloseTag,
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.equalSign,
    NgSimpleTokenType.doubleQuote,
    NgSimpleTokenType.whitespace,
  ];
  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.forwardSlash,
    NgSimpleTokenType.unexpectedChar,
  ];
  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens,
    NgTokenType.bananaSuffix,
    NgScannerState.scanAfterElementDecorator,
  );
  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  // Resolvables
  test('Testing resolved strings of $startState', () {
    expect(untokenize(tokenize('<div [(bnna[prop]>')), '<div [(bnna)] [prop]>');
    expect(untokenize(tokenize('<div [(bnna(evnt)>')), '<div [(bnna)] (evnt)>');
    expect(untokenize(tokenize('<div [(bnna[(bnna2)]>')),
        '<div [(bnna)] [(bnna2)]>');
    expect(untokenize(tokenize('<div [(bnna]>')), '<div [(bnna)] []>');
    expect(untokenize(tokenize('<div [(bnna)>')), '<div [(bnna)] ()>');
    expect(untokenize(tokenize('<div [(bnna#refr>')), '<div [(bnna)] #refr>');
    expect(untokenize(tokenize('<div [(bnna*templ')), '<div [(bnna)] *templ>');
    expect(untokenize(tokenize('<div [(bnna<!--comment-->')),
        '<div [(bnna)]><!--comment-->');
    expect(untokenize(tokenize('<div [(bnna<span>')), '<div [(bnna)]><span>');
    expect(untokenize(tokenize('<div [(bnna</div>')), '<div [(bnna)]></div>');
    expect(untokenize(tokenize('<div [(bnna>')), '<div [(bnna)]>');
    expect(untokenize(tokenize('<div [(bnna/>')), '<div [(bnna)]/>');
    expect(untokenize(tokenize('<div [(bnna')), '<div [(bnna)]>');
    expect(
        untokenize(tokenize('<div [(bnna="quote">')), '<div [(bnna)]="quote">');
    expect(
        untokenize(tokenize('<div [(bnna"quote">')), '<div [(bnna)]="quote">');
    expect(untokenize(tokenize('<div [(bnna attr>')), '<div [(bnna)] attr>');
    expect(untokenize(tokenize('<div [(bnna!)]>')), '<div [(bnna)]>');
    expect(untokenize(tokenize('<div [(bnna/)]>')), '<div [(bnna)]>');
    expect(untokenize(tokenize('<div [(bnna@)]>')), '<div [(bnna)]>');
  });
}

void suffixEvent() {
  String baseHtml = "<div (evnt";
  NgScannerState startState = NgScannerState.scanSuffixEvent;

  List<NgSimpleTokenType> resolveTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.openParen,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.closeBanana,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.star,
    NgSimpleTokenType.commentBegin,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
    NgSimpleTokenType.tagEnd,
    NgSimpleTokenType.voidCloseTag,
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.equalSign,
    NgSimpleTokenType.doubleQuote,
    NgSimpleTokenType.whitespace,
  ];
  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.forwardSlash,
    NgSimpleTokenType.unexpectedChar,
  ];
  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens,
    NgTokenType.eventSuffix,
    NgScannerState.scanAfterElementDecorator,
  );
  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  // Resolvables
  test('Testing resolved strings of $startState', () {
    expect(untokenize(tokenize('<div (evnt[prop]>')), '<div (evnt) [prop]>');
    expect(untokenize(tokenize('<div (evnt(evnt2)>')), '<div (evnt) (evnt2)>');
    expect(
        untokenize(tokenize('<div (evnt[(bnna)]>')), '<div (evnt) [(bnna)]>');
    expect(untokenize(tokenize('<div (evnt]>')), '<div (evnt) []>');
    expect(untokenize(tokenize('<div (evnt)]>')), '<div (evnt) [()]>');
    expect(untokenize(tokenize('<div (evnt#refr>')), '<div (evnt) #refr>');
    expect(untokenize(tokenize('<div (evnt*templ>')), '<div (evnt) *templ>');
    expect(untokenize(tokenize('<div (evnt<!--comment-->')),
        '<div (evnt)><!--comment-->');
    expect(untokenize(tokenize('<div (evnt<span>')), '<div (evnt)><span>');
    expect(untokenize(tokenize('<div (evnt</div>')), '<div (evnt)></div>');
    expect(untokenize(tokenize('<div (evnt>')), '<div (evnt)>');
    expect(untokenize(tokenize('<div (evnt/>')), '<div (evnt)/>');
    expect(untokenize(tokenize('<div (evnt')), '<div (evnt)>');
    expect(untokenize(tokenize('<div (evnt="quote">')), '<div (evnt)="quote">');
    expect(untokenize(tokenize('<div (evnt"quote">')), '<div (evnt)="quote">');
    expect(untokenize(tokenize('<div (evnt attr>')), '<div (evnt) attr>');
    expect(untokenize(tokenize('<div (evnt!)>')), '<div (evnt)>');
    expect(untokenize(tokenize('<div (evnt/)>')), '<div (evnt)>');
    expect(untokenize(tokenize('<div (evnt@)>')), '<div (evnt)>');
  });
}

void suffixProperty() {
  String baseHtml = "<div [prop";
  NgScannerState startState = NgScannerState.scanSuffixProperty;

  List<NgSimpleTokenType> resolveTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.openBracket,
    NgSimpleTokenType.openParen,
    NgSimpleTokenType.openBanana,
    NgSimpleTokenType.closeBracket,
    NgSimpleTokenType.closeBanana,
    NgSimpleTokenType.hash,
    NgSimpleTokenType.star,
    NgSimpleTokenType.commentBegin,
    NgSimpleTokenType.openTagStart,
    NgSimpleTokenType.closeTagStart,
    NgSimpleTokenType.tagEnd,
    NgSimpleTokenType.voidCloseTag,
    NgSimpleTokenType.EOF,
    NgSimpleTokenType.equalSign,
    NgSimpleTokenType.doubleQuote,
    NgSimpleTokenType.whitespace,
  ];
  List<NgSimpleTokenType> dropTokens = <NgSimpleTokenType>[
    NgSimpleTokenType.bang,
    NgSimpleTokenType.forwardSlash,
    NgSimpleTokenType.unexpectedChar,
  ];
  testRecoverySolution(
    baseHtml,
    startState,
    resolveTokens,
    NgTokenType.propertySuffix,
    NgScannerState.scanAfterElementDecorator,
  );
  testRecoverySolution(
    baseHtml,
    startState,
    dropTokens,
    null,
    null,
  );

  // Resolvables
  test('Testing resolved strings of $startState', () {
    expect(untokenize(tokenize('<div [prop[prop2]>')), '<div [prop] [prop2]>');
    expect(untokenize(tokenize('<div [prop(evnt)>')), '<div [prop] (evnt)>');
    expect(
        untokenize(tokenize('<div [prop[(bnna)]>')), '<div [prop] [(bnna)]>');
    expect(untokenize(tokenize('<div [prop)>')), '<div [prop] ()>');
    expect(untokenize(tokenize('<div [prop)]>')), '<div [prop] [()]>');
    expect(untokenize(tokenize('<div [prop#refr>')), '<div [prop] #refr>');
    expect(untokenize(tokenize('<div [prop*templ>')), '<div [prop] *templ>');
    expect(untokenize(tokenize('<div [prop<!--comment-->')),
        '<div [prop]><!--comment-->');
    expect(untokenize(tokenize('<div [prop<span>')), '<div [prop]><span>');
    expect(untokenize(tokenize('<div [prop</div>')), '<div [prop]></div>');
    expect(untokenize(tokenize('<div [prop>')), '<div [prop]>');
    expect(untokenize(tokenize('<div [prop/>')), '<div [prop]/>');
    expect(untokenize(tokenize('<div [prop')), '<div [prop]>');
    expect(untokenize(tokenize('<div [prop="quote">')), '<div [prop]="quote">');
    expect(untokenize(tokenize('<div [prop"quote">')), '<div [prop]="quote">');
    expect(untokenize(tokenize('<div [prop attr>')), '<div [prop] attr>');
    expect(untokenize(tokenize('<div [prop!]>')), '<div [prop]>');
    expect(untokenize(tokenize('<div [prop@]>')), '<div [prop]>');
    expect(untokenize(tokenize('<div [prop/]>')), '<div [prop]>');
  });
}
