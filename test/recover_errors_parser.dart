// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
  HumanizingTemplateAstVisitor visitor = const HumanizingTemplateAstVisitor();
  return asts.map((t) => t.accept(visitor)).join('');
}

void main() {
  test('Should close unclosed element tag', () {
    final asts = parse('<div>');
    expect(asts.length, 1);

    ElementAst element = asts[0];
    expect(element, new ElementAst('div', new CloseElementAst('div')));
    expect(element.closeComplement, new CloseElementAst('div'));
    expect(element.isSynthetic, false);
    expect(element.closeComplement.isSynthetic, true);
    expect(astsToString(asts), '<div></div>');
  });

  test('Should add open element tag to dangling close tag', () {
    final asts = parse('</div>');
    expect(asts.length, 1);

    ElementAst element = asts[0];
    expect(element, new ElementAst('div', new CloseElementAst('div')));
    expect(element.closeComplement, new CloseElementAst('div'));
    expect(element.isSynthetic, true);
    expect(element.closeComplement.isSynthetic, false);
    expect(astsToString(asts), '<div></div>');
  });

  test('Should not close a void tag', () {
    final asts = parse('<hr/>');
    expect(asts.length, 1);

    ElementAst element = asts[0];
    expect(element, new ElementAst('hr', null));
    expect(element.closeComplement, null);
  });

  test('Should add close tag to dangling open within nested', () {
    final asts = parse('<div><div><div>text1</div>text2</div>');
    expect(asts.length, 1);

    ElementAst element = asts[0];
    expect(element.childNodes.length, 1);
    expect(element.childNodes[0].childNodes.length, 2);
    expect(element.closeComplement.isSynthetic, true);
    expect(astsToString(asts), '<div><div><div>text1</div>text2</div></div>');
  });

  test('Should add synthetic open to dangling close within nested', () {
    final asts = parse('<div><div></div>text1</div>text2</div>');
    expect(asts.length, 3);

    ElementAst element = asts[2];
    expect(element.isSynthetic, true);
    expect(element.closeComplement.isSynthetic, false);
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
  });

  test('Should drop invalid attrs in ng-content', () {
    var asts = parse(
        '<ng-content bad = "badValue" select="*" [badProp] = "badPropValue"></ng-content>');
    expect(asts.length, 1);

    var ngcontent = asts[0] as EmbeddedContentAst;
    expect(ngcontent.selector, '*');

    var exceptions = recoveringExceptionHandler.exceptions;
    expect(exceptions.length, 2);

    var e1 = exceptions[0];
    var e2 = exceptions[1];

    expect(e1.context, ' bad="badValue"');
    expect(e1.offset, 11);
    expect(e2.context, ' [badProp]="badPropValue"');
    expect(e2.offset, 39);
  });

  test('Should drop duplicate select attrs in ng-content', () {
    var asts =
        parse('<ng-content select = "*" select = "badSelect"></ng-content>');
    expect(asts.length, 1);

    var ngcontent = asts[0] as EmbeddedContentAst;
    expect(ngcontent.selector, '*');

    var exceptions = recoveringExceptionHandler.exceptions;
    expect(exceptions.length, 1);

    var e = exceptions[0];
    expect(e.context, ' select="badSelect"');
    expect(e.offset, 24);
  });

  test('Should parse property decorators with invalid dart value', () {
    final asts = parse('<div [myProp]="["></div>');
    expect(asts.length, 1);

    ElementAst element = asts[0];
    expect(element.properties.length, 1);
    PropertyAst property = element.properties[0];
    expect(property.expression, null);
    expect(property.value, '[');

    expect(recoveringExceptionHandler.exceptions.length, 1);
    var exception = recoveringExceptionHandler.exceptions[0];
    expect(exception.offset, 0); // 0 offset is relative to value offset
  });

  test('Should parse event decorators with invalid dart value', () {
    final asts = parse('<div (myEvnt)="["></div>');
    expect(asts.length, 1);

    ElementAst element = asts[0];
    expect(element.events.length, 1);
    EventAst event = element.events[0];
    expect(event.expression, null);
    expect(event.value, '[');

    expect(recoveringExceptionHandler.exceptions.length, 1);
    var exception = recoveringExceptionHandler.exceptions[0];
    expect(exception.offset, 0); // 0 offset is relative to value offset
  });

  test('Should parse banana decorator with invalid dart value', () {
    List asts = parsePreserve('<div [(myBnna)]="["></div>');
    expect(asts.length, 1);

    ElementAst element = asts[0];
    expect(element.bananas.length, 1);
    expect(element.bananas[0].value, '[');

    element.accept(desugarVisitor);
    expect(element.events.length, 1);
    expect(element.properties.length, 1);
    expect(element.events[0].expression, null);
    expect(element.properties[0].expression, null);

    expect(recoveringExceptionHandler.exceptions.length, 2);
    var exception1 = recoveringExceptionHandler.exceptions[0];
    var exception2 = recoveringExceptionHandler.exceptions[1];
    expect(exception1.offset, 2);
    expect(exception2.offset, 0);
  });

  test('Should parse star(non micro) decorator with invalid dart value', () {
    List asts = parsePreserve('<div *ngFor="["></div>');
    expect(asts.length, 1);

    ElementAst element = asts[0];
    expect(element.stars.length, 1);
    expect(element.stars[0].value, '[');

    EmbeddedTemplateAst template =
        element.accept(desugarVisitor) as EmbeddedTemplateAst;
    expect(template.properties.length, 1);
    expect(template.properties[0].expression, null);

    expect(recoveringExceptionHandler.exceptions.length, 1);
    var exception = recoveringExceptionHandler.exceptions[0];
    expect(exception.offset, 0);
  });

  test('Should parse star(micro) decorator with invalid dart value', () {
    List asts = parsePreserve('<div *ngFor="let["></div>');
    expect(asts.length, 1);

    ElementAst element = asts[0];
    expect(element.stars.length, 1);
    expect(element.stars[0].value, 'let[');

    EmbeddedTemplateAst template =
        element.accept(desugarVisitor) as EmbeddedTemplateAst;
    expect(template.properties.length, 0);
    expect(template.references.length, 0);

    expect(recoveringExceptionHandler.exceptions.length, 1);
  });
}
