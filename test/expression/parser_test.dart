// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/expression/parser.dart';
import 'package:test/test.dart';

void main() {
  test('should parse non-pipe expressions', () {
    const [
      'foo',
      'foo + bar',
      'foo(bar)',
      'foo ? bar : baz',
      'foo?.bar?.baz',
      'foo & bar',
      'foo ?? bar',
      'foo ??= bar',
      'foo == bar',
      'foo || bar',
    ].forEach((expression) {
      expect(
        parseExpression(
          expression,
          sourceUrl: '/test/expression/parser_test.dart#inline',
        )
            .toSource(),
        expression,
      );
    });
  });

  test('should parse a simple pipe', () {
    expect(
      parseExpression(
        'foo | bar',
        sourceUrl: '/test/expression/parser_test.dart#inline',
      )
          .toSource(),
      r'foo | bar',
    );
  });

  test('should parse multiple occurring pipes', () {
    expect(
      parseExpression(
        'foo | bar | baz',
        sourceUrl: '/test/expression/parser_test.dart#inline',
      )
          .toSource(),
      r'foo | bar | baz',
    );
  });

  test('should parse pipes used as part of a larger expression', () {
    expect(
      parseExpression(
        r'''
        (getThing(foo) | bar) + (getThing(baz) | bar)
      ''',
        sourceUrl: '/test/expression/parser_test.dart#inline',
      )
          .toSource(),
      r'(getThing(foo) | bar) + (getThing(baz) | bar)',
    );
  });

  test('should parse pipes with arguments', () {
    expect(
      parseExpression(
        'foo | bar:baz',
        sourceUrl: '/test/expression/parser_test.dart#inline',
      )
          .toSource(),
      r'foo | bar:baz',
    );
  });

  test('should parse pipes with multiple arguments', () {
    expect(
      parseExpression(
        r''' foo | date:'YY/MM/DD':false ''',
        sourceUrl: '/test/expression/parser_test.dart#inline',
      )
          .toSource(),
      r"foo | date:'YY/MM/DD':false",
    );
  });
}
