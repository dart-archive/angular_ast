// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:analyzer/analyzer.dart';
import 'package:angular_template_parser/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('The Dart analyzer', () {
    test('can be used to parse expressions', () {
      expect(parseAngularExpression('1 + 1', 'template'),
          new isInstanceOf<Expression>());
    });

    test('will yield errors on bad inputs', () {
      expect(() => parseAngularExpression('1 + ', 'template'), throws);
    });
  });
}
