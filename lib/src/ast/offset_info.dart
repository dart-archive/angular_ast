// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Mixin used to preserve offsets of tokens to be able to reproduce the same
/// text. In addition, preserves offsets in cases where banana syntax and
/// template syntax are desugared.
abstract class OffsetInfo {
  int get nameOffset;
  int get valueOffset;
  int get quotedValueOffset;
  int get equalSignOffset;
}

/// Mixin used to preserve offset of special attribute token tokens
/// used for banana, property, event, reference, and template
abstract class SpecialOffsetInfo {
  int get specialPrefixOffset;
  int get specialSuffixOffset; //May be null for reference and template
}

/// Usage: Above two Mixins are useful to obtain extra offset information
/// as needed without having to import NgTokens while dealing with parsed
/// results. MUST verify of valid type and is NOT synthetic before usage.
///
/// For example:
/// TemplateAst someAttr = ...
/// if (someAttr is BananaAst && !someAttr.synthetic) {
///   OffsetInfo bananaAstOffsets = someAttr as OffsetInfo;
///   SpecialOffsetInfo bananaNameOffsets = someAttr as SpecialOffsetInfo;
///   ... do something ...
/// }
/// Refer to parser_test.dart for more examples.
