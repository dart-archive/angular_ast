// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/dart/error/syntactic_errors.dart';
import 'package:angular_ast/angular_ast.dart';
import 'package:test/test.dart';

RecoveringExceptionHandler recoveringExceptionHandler =
    new RecoveringExceptionHandler();

DesugarVisitor desugarVisitor =
    new DesugarVisitor(exceptionHandler: recoveringExceptionHandler);

List<StandaloneTemplateAst> parse(String template) {
  recoveringExceptionHandler.exceptions.clear();
  return const NgParser().parsePreserve(
    template,
    sourceUrl: '/test/recover_error_Parser.dart#inline',
    exceptionHandler: recoveringExceptionHandler,
  );
}

List<StandaloneTemplateAst> parsePreserve(String template) {
  recoveringExceptionHandler.exceptions.clear();
  return const NgParser().parsePreserve(
    template,
    sourceUrl: '/test/recover_error_Parser.dart#inline',
    exceptionHandler: recoveringExceptionHandler,
  );
}

String astsToString(List<StandaloneTemplateAst> asts) {
  var visitor = const HumanizingTemplateAstVisitor();
  return asts.map((t) => t.accept(visitor)).join('');
}

void checkException(ErrorCode errorCode, int offset, int length) {
  expect(recoveringExceptionHandler.exceptions.length, 1);
  var e = recoveringExceptionHandler.exceptions[0];
  expect(e.errorCode, errorCode);
  expect(e.offset, offset);
  expect(e.length, length);
}

void main() {
  test('Should close unclosed element tag', () {
    var asts = parse('<div>');
    expect(asts.length, 1);

    var element = asts[0] as ElementAst;
    expect(element, new ElementAst('div', new CloseElementAst('div')));
    expect(element.closeComplement, new CloseElementAst('div'));
    expect(element.isSynthetic, false);
    expect(element.closeComplement.isSynthetic, true);
    expect(astsToString(asts), '<div></div>');

    checkException(NgParserWarningCode.CANNOT_FIND_MATCHING_CLOSE, 0, 5);
  });

  test('Should add open element tag to dangling close tag', () {
    var asts = parse('</div>');
    expect(asts.length, 1);

    var element = asts[0] as ElementAst;
    expect(element, new ElementAst('div', new CloseElementAst('div')));
    expect(element.closeComplement, new CloseElementAst('div'));
    expect(element.isSynthetic, true);
    expect(element.closeComplement.isSynthetic, false);
    expect(astsToString(asts), '<div></div>');

    checkException(NgParserWarningCode.DANGLING_CLOSE_ELEMENT, 0, 6);
  });

  test('Should not close a void tag', () {
    var asts = parse('<hr/>');
    expect(asts.length, 1);

    var element = asts[0] as ElementAst;
    expect(element, new ElementAst('hr', null));
    expect(element.closeComplement, null);
  });

  test('Should add close tag to dangling open within nested', () {
    var asts = parse('<div><div><div>text1</div>text2</div>');
    expect(asts.length, 1);

    var element = asts[0] as ElementAst;
    expect(element.childNodes.length, 1);
    expect(element.childNodes[0].childNodes.length, 2);
    expect(element.closeComplement.isSynthetic, true);
    expect(astsToString(asts), '<div><div><div>text1</div>text2</div></div>');

    checkException(NgParserWarningCode.CANNOT_FIND_MATCHING_CLOSE, 0, 5);
  });

  test('Should add synthetic open to dangling close within nested', () {
    var asts = parse('<div><div></div>text1</div>text2</div>');
    expect(asts.length, 3);

    var element = asts[2] as ElementAst;
    expect(element.isSynthetic, true);
    expect(element.closeComplement.isSynthetic, false);

    var exceptions = recoveringExceptionHandler.exceptions;
    expect(exceptions.length, 1);
    var e = exceptions[0];
    expect(e.errorCode, NgParserWarningCode.DANGLING_CLOSE_ELEMENT);
    expect(e.offset, 32);
    expect(e.length, 6);
  });

  test('Should resolve complicated nested danglings', () {
    var asts = parse('<a><b></c></a></b>');
    expect(asts.length, 2);

    var elementA = asts[0];
    expect(elementA.childNodes.length, 1);
    expect(elementA.isSynthetic, false);
    expect((elementA as ElementAst).closeComplement.isSynthetic, false);

    var elementInnerB = elementA.childNodes[0];
    expect(elementInnerB.childNodes.length, 1);
    expect(elementInnerB.isSynthetic, false);
    expect((elementInnerB as ElementAst).closeComplement.isSynthetic, true);

    var elementC = elementInnerB.childNodes[0];
    expect(elementC.childNodes.length, 0);
    expect(elementC.isSynthetic, true);
    expect((elementC as ElementAst).closeComplement.isSynthetic, false);

    var elementOuterB = asts[1];
    expect(elementOuterB.childNodes.length, 0);
    expect(elementOuterB.isSynthetic, true);
    expect((elementOuterB as ElementAst).closeComplement.isSynthetic, false);

    expect(astsToString(asts), '<a><b><c></c></b></a><b></b>');

    var exceptions = recoveringExceptionHandler.exceptions;
    expect(exceptions.length, 3);

    // Dangling '</c>'
    var e1 = exceptions[0];
    expect(e1.errorCode, NgParserWarningCode.DANGLING_CLOSE_ELEMENT);
    expect(e1.offset, 6);
    expect(e1.length, 4);

    // Unmatching '</a>'; error at <b>
    var e2 = exceptions[1];
    expect(e2.errorCode, NgParserWarningCode.CANNOT_FIND_MATCHING_CLOSE);
    expect(e2.offset, 3);
    expect(e2.length, 3);

    // Dangling '</b>'
    var e3 = exceptions[2];
    expect(e3.errorCode, NgParserWarningCode.DANGLING_CLOSE_ELEMENT);
    expect(e3.offset, 14);
    expect(e3.length, 4);
  });

  test('Should resolve dangling open ng-content', () {
    var asts = parse('<div><ng-content></div>');
    expect(asts.length, 1);

    var div = asts[0];
    expect(div.childNodes.length, 1);

    var ngContent = div.childNodes[0];
    expect(ngContent, new isInstanceOf<EmbeddedContentAst>());
    expect(ngContent.isSynthetic, false);
    expect((ngContent as EmbeddedContentAst).closeComplement.isSynthetic, true);

    expect(
        astsToString(asts), '<div><ng-content select="*"></ng-content></div>');

    checkException(NgParserWarningCode.CANNOT_FIND_MATCHING_CLOSE, 5, 12);
  });

  test('Should resolve dangling close ng-content', () {
    var asts = parse('<div></ng-content></div>');
    expect(asts.length, 1);

    var div = asts[0];
    expect(div.childNodes.length, 1);

    var ngContent = div.childNodes[0];
    expect(ngContent, new isInstanceOf<EmbeddedContentAst>());
    expect(ngContent.isSynthetic, true);
    expect(
        (ngContent as EmbeddedContentAst).closeComplement.isSynthetic, false);
    expect(
        astsToString(asts), '<div><ng-content select="*"></ng-content></div>');

    checkException(NgParserWarningCode.DANGLING_CLOSE_ELEMENT, 5, 13);
  });

  test('Should handle ng-content used with void end', () {
    var asts = parse('<ng-content/></ng-content>');
    expect(asts.length, 1);

    var ngContent = asts[0];
    expect(ngContent, new isInstanceOf<EmbeddedContentAst>());
    expect(astsToString(asts), '<ng-content select="*"></ng-content>');

    checkException(NgParserWarningCode.NONVOID_ELEMENT_USING_VOID_END, 11, 2);
  });

  test('Should drop invalid attrs in ng-content', () {
    var html =
        '<ng-content bad = "badValue" select="*" [badProp] = "badPropValue" #badRef></ng-content>';
    var asts = parse(html);
    expect(asts.length, 1);

    var ngcontent = asts[0] as EmbeddedContentAst;
    expect(ngcontent.selector, '*');

    var exceptions = recoveringExceptionHandler.exceptions;
    expect(exceptions.length, 3);

    var e1 = exceptions[0];
    expect(e1.errorCode, NgParserWarningCode.INVALID_DECORATOR_IN_NGCONTENT);
    expect(e1.offset, 11);
    expect(e1.length, 17);

    var e2 = exceptions[1];
    expect(e2.errorCode, NgParserWarningCode.INVALID_DECORATOR_IN_NGCONTENT);
    expect(e2.offset, 39);
    expect(e2.length, 27);

    var e3 = exceptions[2];
    expect(e3.errorCode, NgParserWarningCode.INVALID_DECORATOR_IN_NGCONTENT);
    expect(e3.offset, 66);
    expect(e3.length, 8);
  });

  test('Should drop duplicate select attrs in ng-content', () {
    var html = '<ng-content select = "*" select = "badSelect"></ng-content>';
    var asts = parse(html);
    expect(asts.length, 1);

    var ngcontent = asts[0] as EmbeddedContentAst;
    expect(ngcontent.selector, '*');

    checkException(NgParserWarningCode.DUPLICATE_SELECT_DECORATOR, 24, 21);
  });

  test('Should parse property decorators with invalid dart value', () {
    var asts = parse('<div [myProp]="["></div>');
    expect(asts.length, 1);

    var element = asts[0] as ElementAst;
    expect(element.properties.length, 1);
    var property = element.properties[0];
    expect(property.expression, null);
    expect(property.value, '[');

    checkException(ParserErrorCode.MISSING_IDENTIFIER, 15, 1);
  });

  test('Should parse event decorators with invalid dart value', () {
    var asts = parse('<div (myEvnt)="["></div>');
    expect(asts.length, 1);

    var element = asts[0] as ElementAst;
    expect(element.events.length, 1);
    var event = element.events[0];
    expect(event.expression, null);
    expect(event.value, '[');

    checkException(ParserErrorCode.MISSING_IDENTIFIER, 15, 1);
  });

  test('Should parse banana decorator with invalid dart value', () {
    var asts = parsePreserve('<div [(myBnna)]="["></div>');
    expect(asts.length, 1);

    var element = asts[0] as ElementAst;
    expect(element.bananas.length, 1);
    expect(element.bananas[0].value, '[');

    element.accept(desugarVisitor);
    expect(element.events.length, 1);
    expect(element.properties.length, 1);
    expect(element.events[0].expression, null);
    expect(element.properties[0].expression, null);

    expect(recoveringExceptionHandler.exceptions.length, 2);
    var e1 = recoveringExceptionHandler.exceptions[0];
    expect(e1.errorCode, ParserErrorCode.MISSING_IDENTIFIER);
    expect(e1.offset, 19);
    expect(e1.length, 1);

    var e2 = recoveringExceptionHandler.exceptions[1];
    expect(e2.errorCode, ParserErrorCode.MISSING_IDENTIFIER);
    expect(e2.offset, 17);
    expect(e2.length, 1);
  });

  test('Should parse star(non micro) decorator with invalid dart value', () {
    var asts = parsePreserve('<div *ngFor="["></div>');
    expect(asts.length, 1);

    var element = asts[0] as ElementAst;
    expect(element.stars.length, 1);
    expect(element.stars[0].value, '[');

    var template = element.accept(desugarVisitor) as EmbeddedTemplateAst;
    expect(template.properties.length, 1);
    expect(template.properties[0].expression, null);

    expect(recoveringExceptionHandler.exceptions.length, 1);
    var exception = recoveringExceptionHandler.exceptions[0];
    expect(exception.errorCode, ParserErrorCode.MISSING_IDENTIFIER);
    expect(exception.offset, 13);
    expect(exception.length, 1);
  });

  test('Should parse star(micro) decorator with invalid dart value', () {
    var asts = parsePreserve('<div *ngFor="let["></div>');
    expect(asts.length, 1);

    var element = asts[0] as ElementAst;
    expect(element.stars.length, 1);
    expect(element.stars[0].value, 'let[');

    var template = element.accept(desugarVisitor) as EmbeddedTemplateAst;
    expect(template.properties.length, 0);
    expect(template.references.length, 0);

    checkException(NgParserWarningCode.INVALID_MICRO_EXPRESSION, 13, 4);
  });
}
