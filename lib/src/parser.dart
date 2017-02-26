// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/lexer.dart';
import 'package:angular_ast/src/parser/recursive.dart';
import 'package:angular_ast/src/exception_handler/exception_handler.dart';
import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';
import 'package:angular_ast/src/visitor.dart';

class NgParser {
  // Elements that explicitly don't have a closing tag.
  //
  // https://www.w3.org/TR/html/syntax.html#void-elements
  static const _voidElements = const <String>[
    'area',
    'base',
    'br',
    'col',
    'command',
    'embed',
    'hr',
    'img',
    'input',
    'keygen',
    'link',
    'meta',
    'param',
    'source',
    'track',
    'wbr',
  ];

  final bool _toolFriendlyAstOrigin;

  @literal
  const factory NgParser({
    bool toolFriendlyAstOrigin,
  }) = NgParser._;

  // Prevent inheritance.
  const NgParser._({
    bool toolFriendlyAstOrigin: false,
  })
      : _toolFriendlyAstOrigin = toolFriendlyAstOrigin;

  /// Return a series of tokens by incrementally scanning [template].
  ///
  /// Automatically desugars.
  List<StandaloneTemplateAst> parse(
    String template, {
    @required String sourceUrl,
    ExceptionHandler exceptionHandler: const ThrowingExceptionHandler(),
  }) {
    final asts = parsePreserve(
      template,
      sourceUrl: sourceUrl,
      exceptionHandler: exceptionHandler,
    );
    DesugarVisitor visitor =
        new DesugarVisitor(toolFriendlyAstOrigin: _toolFriendlyAstOrigin);
    return asts.map((t) => t.accept(visitor)).toList();
  }

  /// Return a series of tokens by incrementally scanning [template].
  ///
  /// Does not automatically desugar.
  List<StandaloneTemplateAst> parsePreserve(
    String template, {
    @required String sourceUrl,
    ExceptionHandler exceptionHandler: const ThrowingExceptionHandler(),
  }) {
    final tokens = const NgLexer().tokenize(template, exceptionHandler);
    final parser = new RecursiveAstParser(
      new SourceFile(
        template,
        url: sourceUrl,
      ),
      tokens,
      _voidElements,
    );
    return parser.parse();
  }
}
