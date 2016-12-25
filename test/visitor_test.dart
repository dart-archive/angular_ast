// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/angular_ast.dart';
import 'package:test/test.dart';

void main() {
  test('should humanize a simple template', () {
    final template = parse(
      '<button [title]="aTitle">Hello {{name}}</button>',
      sourceUrl: '/test/visitor_test.dart#inline',
    );
    final visitor = const HumanizingTemplateAstVisitor();
    expect(
      template.map((t) => t.accept(visitor)).join(''),
      equalsIgnoringWhitespace(r'''
        <button [title]="aTitle">Hello {{name}}</button>
      '''),
    );
  });
}
