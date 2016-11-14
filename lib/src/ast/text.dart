// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
part of angular2_template_parser.src.ast;

/// A simple string value (not an expression).
class NgText extends NgAstNode with NgAstSourceTokenMixin {
  /// Text value.
  final String value;

  /// Create a new [text] node.
  factory NgText(
    String text, [
    NgToken parsedToken,
  ]) = NgText._;

  NgText._(
    this.value, [
    NgToken parsedToken,
  ])
      : super._(parsedToken != null ? [parsedToken] : const []);

  @override
  bool operator ==(Object o) => o is NgText && value == o.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '$NgText $value';

  @override
  void visit(Visitor visitor) => visitor.visitText(this);
}
