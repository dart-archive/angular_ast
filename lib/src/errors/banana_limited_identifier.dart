// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
part of angular2_template_parser.src.compiler_error;

/// When a banana (in a box) binding contains more than a single
/// identifier.
///
/// TODO: find a better name for this guy.
class BananaLimitedIdentifierError extends SourceError {
  /// The parsed [NgToken] representing the element name.
  final NgToken elementToken;

  factory BananaLimitedIdentifierError(NgToken elementToken) {
    return new BananaLimitedIdentifierError._(
        elementToken, elementToken.source);
  }

  BananaLimitedIdentifierError._(this.elementToken, SourceSpan context)
      : super._(context);

  @override
  String toString() => toFriendlyMessage(
      header: 'Banana (in a box) should only contain an identifier');
}
