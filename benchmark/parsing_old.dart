// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:angular2/src/compiler/html_parser.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

import 'shared/html.dart';

void main() {
  const PkgAngular2Benchmark().report();
}

/// Runs `package:angular2`.
class PkgAngular2Benchmark extends BenchmarkBase {
  /// Create the benchmark.
  const PkgAngular2Benchmark() : super('Old Ng2');

  @override
  void run() {
    new HtmlParser().parse(html, 'foo.html');
  }
}
