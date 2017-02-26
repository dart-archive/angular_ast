// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Mixin used to preserve offsets of tokens to be able to reproduce the same
/// text. In addition, preserves offsets in cases where banana syntax and
/// template syntax are desugared.
abstract class TagOffsetInfo {
  int get nameOffset;
  int get valueOffset;
  int get quotedValueOffset;
  int get equalSignOffset;
}

/// Mixin used to preserve offset of special attribute token tokens
/// used for banana, property, event, reference, and template
abstract class SpecialOffsetInfo {
  int get prefixOffset;
  int get suffixOffset; //May be null for reference and template
}
