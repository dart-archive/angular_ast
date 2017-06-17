// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:angular_ast/src/expression/parser.dart';
import 'package:angular_ast/src/expression/ng_dart_ast.dart';
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
    // AstNodeImpl uses a visitor pattern (bad design?) within their
    // toSource() -> which means it will not be able to read our
    // Pipe asts defined. Therefore must do so manually.
    final expression = parseExpression(
      r'''
        (getThing(foo) | bar) + (getThing(baz) | bar)
      ''',
      sourceUrl: '/test/expression/parser_test.dart#inline',
    );
    expect(expression, new isInstanceOf<BinaryExpression>());
    final bexpression = expression as BinaryExpression;
    final left = bexpression.leftOperand as ParenthesizedExpression;
    final right = bexpression.rightOperand as ParenthesizedExpression;
    expect(left.expression, new isInstanceOf<PipeInvocationExpression>());
    expect(right.expression, new isInstanceOf<PipeInvocationExpression>());
    final pipeLeft = left.expression as PipeInvocationExpression;
    final pipeRight = right.expression as PipeInvocationExpression;
    expect(pipeLeft.toSource(), r'getThing(foo) | bar');
    expect(pipeRight.toSource(), r'getThing(baz) | bar');
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

  test('should parse chained pipes', () {
    final expression = parseExpression(
      r''' foo | date:'YY/MM/DD':false | marioPipe:yoshi:5 ''',
      sourceUrl: '/test/expression/parser_test.dart#inline',
    );
    expect(
      expression.toSource(),
      r"foo | date:'YY/MM/DD':false | marioPipe:yoshi:5",
    );

    expect((expression as PipeInvocationExpression).asFunctionLikeString(),
        r'''marioPipe(date(foo, 'YY/MM/DD', false), yoshi, 5)''');
  });
}
