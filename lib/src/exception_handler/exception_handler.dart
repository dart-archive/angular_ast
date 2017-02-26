// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

abstract class ExceptionHandler {
  void handle(Exception e);
}

class ThrowingExceptionHandler implements ExceptionHandler {
  @override
  void handle(Exception e) {
    throw e;
  }

  @literal
  const factory ThrowingExceptionHandler() = ThrowingExceptionHandler._;
  const ThrowingExceptionHandler._();
}

class RecoveringExceptionHandler implements ExceptionHandler {
  final List<Exception> exceptions = new List<Exception>();

  @override
  void handle(Exception e) {
    exceptions.add(e);
  }
}
