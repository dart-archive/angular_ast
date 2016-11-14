// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:angular_template_parser/angular_template_parser.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

import 'shared/html.dart';

void main() {
  const PkgHtmlParserBenchmark().report();
}

/// Runs the `package:html_parser` benchmark.
class PkgHtmlParserBenchmark extends BenchmarkBase {
  /// Create the benchmark.
  const PkgHtmlParserBenchmark() : super('New Ng2');

  @override
  void run() {
    const NgTemplateParser().parse(html).toList();
  }
}
