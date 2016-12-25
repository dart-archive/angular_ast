// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/src/dart/scanner/reader.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/generated/parser.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:angular_ast/src/expression/pipe.dart';
import 'package:meta/meta.dart';

final _resourceProvider = new MemoryResourceProvider();

class _ThrowingListener implements AnalysisErrorListener {
  const _ThrowingListener();

  @override
  void onError(AnalysisError error) {
    throw new FormatException(
      error.toString(),
      error.source.contents.data,
      error.offset,
    );
  }
}

/// Parses a template [expression].
Expression parseExpression(
  String expression, {
  bool deSugarPipes: true,
  @required String sourceUrl,
}) {
  final source = _resourceProvider
      .newFile(
        sourceUrl,
        expression,
      )
      .createSource();
  final reader = new CharSequenceReader(expression);
  final listener = const _ThrowingListener();
  final scanner = new Scanner(source, reader, listener);
  final parser = new _NgExpressionParser(
    source,
    listener,
    deSugarPipes: deSugarPipes,
  );
  return parser.parseExpression(scanner.tokenize());
}

/// Extends the Dart language to understand the current Angular 'pipe' syntax.
///
/// Based on https://github.com/dart-lang/angular_analyzer_plugin/pull/160
class _NgExpressionParser extends Parser {
  final bool _deSugarPipes;

  _NgExpressionParser(
    Source source,
    AnalysisErrorListener errorListener, {
    bool deSugarPipes,
  })
      : _deSugarPipes = deSugarPipes,
        super(source, errorListener);

  @override
  Expression parseBitwiseOrExpression() {
    if (!_deSugarPipes) {
      return super.parseBitwiseOrExpression();
    }
    Expression expression;
    if (currentToken.keyword == Keyword.SUPER &&
        currentToken.next.type == TokenType.BAR) {
      expression = new SuperExpression(getAndAdvance());
    } else {
      expression = parseBitwiseXorExpression();
    }
    while (currentToken.type == TokenType.BAR) {
      expression = new BinaryExpression(
        expression,
        getAndAdvance(),
        parseBitwiseXorExpression(),
      );
      expression = parseAndTransformPipeExpression(expression);
    }
    return expression;
  }

  /// Given an expression of `{expression} | {pipe}`, returns an expression.
  ///
  /// For example, will return:
  /// ```
  /// $$ng.pipe({pipe}, {expression}, [{args}])
  /// ```
  ///
  /// With the expectation the compiler will optimize further.
  Expression parseAndTransformPipeExpression(BinaryExpression expression) {
    final pipeArgs = <Expression>[];
    while (currentToken.lexeme == ':') {
      currentToken = currentToken.next;
      pipeArgs.add(this.parseExpression2());
    }
    if (expression.rightOperand is! Identifier) {
      throw new FormatException(
        'Pipe name must be a valid identifier',
        expression.toSource(),
        expression.rightOperand.offset,
      );
    }
    return new PipeExpression(
      expression.beginToken,
      expression.endToken,
      expression.end,
      expression.rightOperand,
      expression.operator,
      expression.leftOperand,
      pipeArgs,
    );
  }
}
