// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
part of angular2_template_parser.src.ast;

/// A parsed binding AST.
class NgBanana extends NgAstNode with NgAstSourceTokenMixin {
  /// Name of the binding.
  final String name;

  /// Value of the binding (Optional).
  final String value;

  /// Create a new [NgBanana].
  NgBanana(this.name, this.value) : super._(const []);

  /// Create a new [NgBanana] from tokenized HTML.
  NgBanana.fromTokens(
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
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object o) {
    if (o is NgBanana) {
      return o.name == name && o.value == value;
    }
    return false;
  }

  @override
  String toString() => '$NgBanana [($name)]=$value';

  @override
  void visit(Visitor visitor) => visitor.visitBanana(this);
}
