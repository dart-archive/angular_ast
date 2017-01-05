// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/expression/micro/ast.dart';
import 'package:angular_ast/src/expression/micro/parser.dart';
import 'package:test/test.dart';

void main() {
  NgMicroAst parse(String directive, String expression) {
    return const NgMicroParser().parse(
      directive,
      expression,
      sourceUrl: '/test/expression/micro/parser_test.dart#inline',
    );
  }

  test('should parse a simple let', () {
    expect(
      parse('ngThing', 'let foo'),
      new NgMicroAst(
        assignments: [
          new ReferenceAst('foo'),
        ],
        properties: [],
      ),
    );
  });

  test('should parse a let assignment', () {
    expect(
      parse('ngThing', 'let foo = bar;let baz'),
      new NgMicroAst(
        assignments: [
          new ReferenceAst('foo', 'bar'),
          new ReferenceAst('baz'),
        ],
        properties: [],
      ),
    );
  });

  test('should parse a let/bind pair', () {
    expect(
      parse('ngFor', 'let item of items; trackBy: byId'),
      new NgMicroAst(
        assignments: [
          new ReferenceAst('item'),
        ],
        properties: [
          new PropertyAst(
            'ngForOf',
            new ExpressionAst.parse(
              'items',
              sourceUrl: '/test/expression/micro/parser_test.dart#inline',
            ),
          ),
          new PropertyAst(
            'ngForTrackBy',
            new ExpressionAst.parse(
              'byId',
              sourceUrl: '/test/expression/micro/parser_test.dart#inline',
            ),
          ),
        ],
      ),
    );
  });
}
