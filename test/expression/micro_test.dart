import 'package:angular_ast/angular_ast.dart';
import 'package:angular_ast/src/expression/micro.dart';
import 'package:test/test.dart';

void main() {
  test('should parse a simple *ngFor', () {
    expect(
      parseMicroExpression('let item of items', 'ngFor'),
      new NgMicroExpression(
        assignments: [
          new ReferenceAst('item'),
        ],
        properties: [
          new PropertyAst('ngForOf', new ExpressionAst.parse('items'))
        ],
      ),
    );
  });

  test('should parse an *ngFor with a trackBy', () {
    expect(
      parseMicroExpression('let item of items; trackBy: byId', 'ngFor'),
      new NgMicroExpression(
        assignments: [
          new ReferenceAst('item'),
        ],
        properties: [
          new PropertyAst('ngForOf', new ExpressionAst.parse('items')),
          new PropertyAst('ngForTrackBy', new ExpressionAst.parse('byId')),
        ],
      ),
    );
  });

  test('should parse an *ngFor using \$index', () {
    expect(
      parseMicroExpression('let item of items; let i = index', 'ngFor'),
      new NgMicroExpression(
        assignments: [
          new ReferenceAst('item'),
          new ReferenceAst('i', 'index'),
        ],
        properties: [
          new PropertyAst('ngForOf', new ExpressionAst.parse('items')),
        ],
      ),
    );
  });
}
