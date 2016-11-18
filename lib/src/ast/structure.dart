// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
part of angular2_template_parser.src.ast;

/// A parsed structural directive AST.
class NgStructure extends NgAstNode with NgAstSourceTokenMixin {
  /// Name of the property.
  final String name;

  /// Value of the property (structural microsyntax).
  final String value;

  NgStructure(this.name, this.value) : super._(const []);

  NgStructure.fromTokens(
    NgToken before,
    NgToken start,
    NgToken name,
    NgToken equals,
    NgToken value,
    NgToken end,
  )
      : this.name = name.text,
        this.value = value.text,
        super._([before, start, name, equals, value, end]);

  @override
  int get hashCode => hash2(name, value);

  @override
  bool operator ==(Object o) {
    if (o is NgStructure) {
      return o.name == name && o.value == value;
    }
    return false;
  }

  @override
  String toString() => '$NgStructure *$name="$value"';

  @override
  void visit(Visitor visitor) => visitor.visitStructure(this);
}
