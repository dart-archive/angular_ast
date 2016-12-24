import 'package:angular_ast/angular_ast.dart';
import 'package:test/test.dart';

void main() {
  test('should humanize a simple template', () {
    final template = parse('<button [title]="aTitle">Hello {{name}}</button>');
    expect(
      template.map(const HumanizingTemplateAstVisitor().visit).join(''),
      equalsIgnoringWhitespace(r'''
        <button [title]="aTitle">Hello {{name}}</button>
      '''),
    );
  });
}
