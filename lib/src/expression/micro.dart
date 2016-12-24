// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/angular_ast.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

const _listEquals = const ListEquality();

/// Returns whether [expression] is a special Angular *-star expression.
///
/// This means it won't parse correctly with the standard expression parser, and
/// [parseMicroExpression] is needed to de-sugar the expression into its
/// multiple intents.
bool isMicroExpression(String expression) => false;

/// Returns a de-sugared [NgMicroExpression] from [expression] on [directive].
///
/// Given a string like `"let x of items; trackBy: foo; let i = index"`:
///
/// - Treats the first statement as "reference x, ngForOf=items".
/// - Treats second as "ngForTrackBy=foo".
/// - Treats last as "reference i = index".
NgMicroExpression parseMicroExpression(
  String expression,
  String directive, {
  bool deSugarPipes: true,
  String sourceUrl: '/test.dart',
}) {
  final assignments = <ReferenceAst>[];
  final properties = <PropertyAst>[];
  final parts = expression.split(';');

  // Parse the first statement, which is special.
  if (!parts[0].startsWith('let')) {
    throw new FormatException('Expected "let"', expression, 0);
  }
  var parse = parts[0].split(' ');
  assignments.add(new ReferenceAst(parse[1]));
  var name = parse[2];
  name = directive + name[0].toUpperCase() + name.substring(1);
  properties.add(
    new PropertyAst(
      name,
      new ExpressionAst.parse(
        parse[3],
        deSugarPipes: deSugarPipes,
        sourceUrl: sourceUrl,
      ),
    ),
  );

  // Parse remaining statements, if any.
  for (var part in parts.skip(1)) {
    part = part.trim();
    if (part.startsWith('let')) {
      var name = part.substring(4, part.indexOf('='));
      var value = part.substring(part.indexOf('=') + 1);
      assignments.add(new ReferenceAst(name.trim(), value.trim()));
    } else {
      var subParts = part.split(':');
      var name = subParts.first.trim();
      name = directive + name[0].toUpperCase() + name.substring(1);
      properties.add(
        new PropertyAst(
          name,
          new ExpressionAst.parse(subParts.last.trim()),
        ),
      );
    }
  }

  // Return the structure.
  return new NgMicroExpression(
    assignments: assignments,
    properties: properties,
  );
}

/// A de-sugared form of longer pseudo expression.
class NgMicroExpression {
  /// What variable assignments were made.
  final List<ReferenceAst> assignments;

  /// What properties are bound.
  final List<PropertyAst> properties;

  @literal
  const NgMicroExpression({
    @required this.assignments,
    @required this.properties,
  });

  @override
  bool operator ==(Object o) {
    if (o is NgMicroExpression) {
      return _listEquals.equals(assignments, o.assignments) &&
          _listEquals.equals(properties, o.properties);
    }
    return false;
  }

  @override
  int get hashCode =>
      hash2(_listEquals.hash(assignments), _listEquals.hash(properties));

  @override
  String toString() => '#$NgMicroExpression <$assignments $properties>';
}
