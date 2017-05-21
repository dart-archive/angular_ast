// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token/tokens.dart';
import 'package:angular_ast/src/visitor.dart';
import 'package:source_span/source_span.dart';
import 'package:quiver/core.dart';

/// Represents a 'let-' binding attribute within a <template> AST.
/// This AST cannot exist anywhere else except as part of the attribute
/// for a [EmbeddedTemplateAst].
///
/// Clients should not extend, implement, or mix-in this class.
abstract class LetBindingAst implements TemplateAst {
  /// Create a new synthetic [LetBindingAst] listening to [name].
  /// [value] is an optional parameter, which indicates that the variable is
  /// bound to a the value '$implicit'.
  factory LetBindingAst(
    String name, [
    String value,
  ]) = _SyntheticLetBindingAst;

  /// Create a new synthetic [LetBindingAst] that originated from [origin].
  factory LetBindingAst.from(
    TemplateAst oriign,
    String name, [
    String value,
  ]) = _SyntheticLetBindingAst.from;

  /// Create a new [LetBindingAst] parsed from tokens in [sourceFile].
  /// The [prefixToken] is the 'let-' component, the [elementDecoratorToken]
  /// is the variable name, and [valueToken] is the value bound to the
  /// variable.
  factory LetBindingAst.parsed(
    SourceFile sourceFile,
    NgToken beginToken,
    NgToken prefixToken,
    NgToken elementDecoratorToken,[
    NgAttributeValueToken valueToken,
  ])
}