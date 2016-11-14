// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:angular_template_parser/angular_template_parser.dart';
import 'package:test/test.dart';

void main() {
  List<NgAstNode> parse(String text) =>
      const NgTemplateParser().parse(text, onError: (_) => null).toList();

  // Example migration program - add test to all NgAstNames, remove comments.
  NgAstNode migrate(NgAstNode node) {
    if (node is NgElement) {
      return new NgElement.unknown('${node.name}-test',
          childNodes: node.childNodes
              .map((x) => x.map(migrate))
              .where((x) => x != null)
              .toList());
    }
    if (node is NgComment) {
      return null;
    }
    return node;
  }

  test('can perform simple migrations on AST trees', () {
    final source = '<div [foo]="baz"><app *ngIf="isLoaded">'
        '<!-- App Loaded Below--></app></div>';
    final oldAst = parse(source);
    final newAst = oldAst.map((x) => x.map(migrate));
    expect(newAst, [
      new NgElement.unknown('div-test', childNodes: [
        new NgProperty('foo', 'baz'),
        new NgElement.unknown('template-test', childNodes: [
          new NgProperty('ngIf', 'isLoaded'),
          new NgElement.unknown('app-test', childNodes: [])
        ])
      ])
    ]);
  });
}
