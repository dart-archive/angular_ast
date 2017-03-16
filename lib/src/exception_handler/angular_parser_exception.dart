// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Exception class to be used in AngularAst parser.
class AngularParserException {
  /// The string where the error occurs. Begins at [offset].
  final String context;

  /// Reasoning for exception to be raised.
  final String message;

  /// Offset of where the exception was detected.
  final int offset;

  AngularParserException(
    this.message,
    this.context,
    this.offset,
  );
}
