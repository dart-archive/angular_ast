// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/standard_ast_factory.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/src/dart/ast/token.dart';
import 'package:analyzer/src/dart/scanner/reader.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/generated/parser.dart';
import 'package:analyzer/src/generated/source.dart';

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
  String sourceUrl: '/~test.dart',
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
    final ngInternalNamespace = astFactory.simpleIdentifier(
      new StringToken(TokenType.IDENTIFIER, r'$$ng.pipe', 0),
    );
    // TODO: Support pipe arguments.
    var pipeArgs = <Expression>[];
    while (currentToken.lexeme == ':') {
      currentToken = currentToken.next;
      pipeArgs.add(this.parseExpression2());
    }
    var callArgs = <Expression>[expression.leftOperand];
    if (pipeArgs.isNotEmpty) {
      callArgs.add(new ListLiteral(
        null,
        null,
        new Token(TokenType.OPEN_SQUARE_BRACKET, 0),
        pipeArgs,
        new Token(TokenType.CLOSE_SQUARE_BRACKET, 0),
      ));
    }
    return astFactory.methodInvocation(
      ngInternalNamespace,
      new Token(TokenType.PERIOD, 0),
      expression.rightOperand,
      null,
      astFactory.argumentList(
        new Token(TokenType.OPEN_PAREN, 0),
        callArgs,
        new Token(TokenType.CLOSE_PAREN, 0),
      ),
    );
  }
}
