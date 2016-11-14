// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:angular_template_parser/angular_template_parser.dart';
import 'package:test/test.dart';

void main() {
  group('$NgElement', () {
    test('should equal an identical element', () {
      expect(
        new NgElement.unknown('button'),
        new NgElement.unknown('button'),
      );
    });

    test('should equal an identical set of nodes', () {
      expect(
        new NgElement.unknown(
          'button',
          childNodes: [
            new NgElement.unknown('span'),
          ],
        ),
        new NgElement.unknown(
          'button',
          childNodes: [
            new NgElement.unknown('span'),
          ],
        ),
      );
    });
  });

  group('$NgText', () {
    test('should equal an identical text node', () {
      expect(new NgText('Hello'), new NgText('Hello'));
    });

    test('should not equal a non-identical text node', () {
      expect(new NgText('Hello'), isNot(new NgText('World')));
    });
  });
}
