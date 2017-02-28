// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/angular_ast.dart';
import 'package:test/test.dart';

RecoveringExceptionHandler recoveringExceptionHandler =
    new RecoveringExceptionHandler();

List<StandaloneTemplateAst> parse(String template) {
  return const NgParser().parse(
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
    expect(element, new ElementAst('div'));
    expect(element.closeComplement, new CloseElementAst('div'));
    expect(element.isSynthetic, false);
    expect(element.closeComplement.isSynthetic, true);
    expect(astsToString(asts), '<div></div>');
  });

  test('Should add open element tag to dangling close tag', () {
    final asts = parse('</div>');
    expect(asts.length, 1);

    ElementAst element = asts[0];
    expect(element, new ElementAst('div'));
    expect(element.closeComplement, new CloseElementAst('div'));
    expect(element.isSynthetic, true);
    expect(element.closeComplement.isSynthetic, false);
    expect(astsToString(asts), '<div></div>');
  });

  test('Should not close a void tag', () {
    final asts = parse('<hr/>');
    expect(asts.length, 1);

    ElementAst element = asts[0];
    expect(element,
        new ElementAst('hr', isVoidElement: true, usesVoidTagEnd: true));
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
}
