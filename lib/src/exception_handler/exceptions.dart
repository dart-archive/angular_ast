// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
part of angular_ast.src.exceptions;

/// Error codes used for exceptions that occur during the parsing.
/// The convention for this class is for the name of the error code
/// to indicate the problem that caused the error code to be generated
/// and for the error message to explain what is wrong, and when appropriate,
/// how the problem can be corrected.
class NgParserWarningCode extends ErrorCode {
  static const NgParserWarningCode AFTER_COMMENT = const NgParserWarningCode(
    'AFTER_COMMENT',
    'Unterminated comment',
  );

  static const NgParserWarningCode AFTER_DECORATOR_NEED_CLOSE =
      const NgParserWarningCode(
    'AFTER_DECORATOR_NEED_CLOSE',
    "Expected tag close: '>' or '/>' after decorator",
  );

  static const NgParserWarningCode AFTER_DECORATOR_NEED_EQUAL =
      const NgParserWarningCode('AFTER_DECORATOR_NEED_EQUAL',
          "Expected '=' between decorator and value");

  static const NgParserWarningCode AFTER_DECORATOR_NEED_WHITESPACE =
      const NgParserWarningCode(
    'AFTER_DECORATOR_NEED_WHITESPACE',
    'Expected whitespace between differing decorators',
  );

  static const NgParserWarningCode AFTER_DECORATOR_VALUE_NEED_CLOSE =
      const NgParserWarningCode(
    'AFTER_DECORATOR_VALUE_NEED_CLOSE',
    "Expected tag close: '>' or '/>' after decorator value",
  );

  static const NgParserWarningCode AFTER_DECORATOR_VALUE_NEED_WHITESPACE =
      const NgParserWarningCode(
    'AFTER_DECORATOR_VALUE_NEED_WHITESPACE',
    'Expected whitespace after decorator value',
  );

  static const NgParserWarningCode AFTER_ELEMENT_IDENTIFIER =
      const NgParserWarningCode(
    'AFTER_ELEMENT_IDENTIFIER',
    'Expected either whitespace or close tag end after element identifier',
  );

  static const NgParserWarningCode
      AFTER_ELEMENT_IDENTIFIER_OPEN_NEED_WHITESPACE = const NgParserWarningCode(
    'AFTER_ELEMENT_IDENTIFIER_OPEN_NEED_WHITESPACE',
    'Expected whitespace after element identifier before decorator',
  );

  static const NgParserWarningCode AFTER_INTERPOLATION =
      const NgParserWarningCode(
    'AFTER_INTERPOLATION',
    'Unterminated mustache',
  );

  static const NgParserWarningCode BEFORE_INTERPOLATION =
      const NgParserWarningCode(
    'BEFORE_INTERPOLATION',
    'Unopened mustache',
  );

  static const NgParserWarningCode CANNOT_FIND_MATCHING_CLOSE =
      const NgParserWarningCode(
    'CANNOT_FIND_MATCHING_CLOSE',
    'Cannot find matching close element to this',
  );

  static const NgParserWarningCode DANGLING_CLOSE_ELEMENT =
      const NgParserWarningCode(
    'DANGLING_CLOSE_ELEMENT',
    'Closing tag is dangling and no matching open tag can be found',
  );

  static const NgParserWarningCode DANGLING_DECORATOR_SUFFIX =
      const NgParserWarningCode('DANGING_DECORATOR_SUFFIX',
          'Decorator suffix needs a matching prefix');

  static const NgParserWarningCode DUPLICATE_STAR_DIRECTIVE =
      const NgParserWarningCode(
    'DUPLICATE_STAR_DIRECTIVE',
    'Already found a *-directive, limit 1 per element.',
  );

  static const NgParserWarningCode DUPLICATE_SELECT_DECORATOR =
      const NgParserWarningCode(
    'DUPLICATE_SELECT_DECORATOR',
    "Only 1 'select' decorator can exist in <ng-content>, found duplicate",
  );

  static const NgParserWarningCode ELEMENT_DECORATOR =
      const NgParserWarningCode(
    'ELEMENT_DECORATOR',
    'Expected element decorator after whitespace',
  );

  static const NgParserWarningCode ELEMENT_DECORATOR_AFTER_PREFIX =
      const NgParserWarningCode(
    'ELEMENT_DECORATOR_AFTER_PREFIX',
    'Expected element decorator identifier after prefix',
  );

  static const NgParserWarningCode ELEMENT_DECORATOR_SUFFIX_BEFORE_PREFIX =
      const NgParserWarningCode(
    'ELEMENT_DECORATOR',
    'Found special decorator suffix before prefix',
  );

  static const NgParserWarningCode ELEMENT_DECORATOR_VALUE =
      const NgParserWarningCode(
    'ELEMENT_DECORATOR_VALUE',
    "Expected quoted value following '='",
  );

  static const NgParserWarningCode ELEMENT_IDENTIFIER =
      const NgParserWarningCode(
    'ELEMENT_IDENTIFIER',
    'Expected element tag name',
  );

  static const NgParserWarningCode ELEMENT_END = const NgParserWarningCode(
    'ELEMENT_END',
    'Expected element tag close',
  );

  static const NgParserWarningCode EXPECTED_STANDALONE =
      const NgParserWarningCode(
    'EXPECTING_STANDALONE',
    'Expected standalone token',
  );

  static const NgParserWarningCode EXPRESSION_UNEXPECTED =
      const NgParserWarningCode(
    'EXPRESSION_UNEXPECTED',
    'Unexpected token in expression',
  );

  static const NgParserWarningCode INTERPOLATION = const NgParserWarningCode(
    'INTERPOLATION',
    "Expected expression after mustache '{{'",
  );

  static const NgParserWarningCode INVALID_DECORATOR_IN_NGCONTENT =
      const NgParserWarningCode(
    'INVALID_DECORATOR_IN_NGCONTENT',
    "Only 'select' is a valid attribute/decorate in <ng-content>",
  );

  static const NgParserWarningCode NONVOID_ELEMENT_USING_VOID_END =
      const NgParserWarningCode(
          'NONVOID_ELEMENT_USING_VOID_END', 'Element is not a void-element');

  static const NgParserWarningCode PIPE_INVALID_IDENTIFIER =
      const NgParserWarningCode(
    'PIPE_INVALID_IDENTIFIER',
    'Pipe must be a valid identifier',
  );

  static const NgParserWarningCode SUFFIX_BANANA = const NgParserWarningCode(
    'SUFFIX_BANANA',
    "Expected closing banana ')]'",
  );

  static const NgParserWarningCode SUFFIX_EVENT = const NgParserWarningCode(
    'SUFFIX_EVENT',
    "Expected closing parenthesis ')'",
  );

  static const NgParserWarningCode SUFFIX_PROPERTY = const NgParserWarningCode(
    'SUFFIX_PROPERTY',
    "Expected closing bracket ']'",
  );

  static const NgParserWarningCode UNCLOSED_QUOTE = const NgParserWarningCode(
    'UNCLOSED_QUOTE',
    'Expected close quote for element decorator value',
  );

  // 'Catch-all' error code.
  static const NgParserWarningCode UNEXPECTED_TOKEN = const NgParserWarningCode(
    'UNEXPECTED_TOKEN',
    'Unexpected token',
  );

  static const NgParserWarningCode VOID_ELEMENT_IN_CLOSE_TAG =
      const NgParserWarningCode(
    'VOID_ELEMENT_IN_CLOSE_TAG',
    'Void element identifiers cannot be used in close element tag',
  );

  static const NgParserWarningCode VOID_CLOSE_IN_CLOSE_TAG =
      const NgParserWarningCode('VOID_CLOSE_IN_CLOSE_TAG',
          "Void close '/>' cannot be used in a close element");

  /// Initialize a newly created erorr code to have the given [name].
  /// The message associated with the error will be created from the
  /// given [message] template. The correction associated with the error
  /// will be created from the given [correction] template.
  const NgParserWarningCode(
    String name,
    String message, [
    String correction,
  ])
      : super(name, message, correction);

  NgParserWarningCode.DART_PARSER(
    String message, [
    String correction,
  ])
      : super('DART_PARSER', message, correction);

  @override
  ErrorSeverity get errorSeverity => ErrorSeverity.ERROR;

  @override
  ErrorType get type => ErrorType.SYNTACTIC_ERROR;
}
