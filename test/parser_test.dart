import 'package:angular_ast/angular_ast.dart';
import 'package:test/test.dart';

main() {
  List<TemplateAst> parse(String html) => const NgParser().parse(html);

  test('shoud parse a text node', () {
    expect(
      parse('Hello World'),
      [
        new TemplateAst.text('Hello World'),
      ],
    );
  });

  test('should parse an element', () {
    expect(
      parse('<div></div>'),
      [
        new TemplateAst.element('div'),
      ],
    );
  });

  test('should parse an element with text', () {
    expect(
      parse('<div>Hello World</div>'),
      [
        new TemplateAst.element('div', children: [
          new TemplateAst.text('Hello World'),
        ]),
      ],
    );
  });

  test('should parse nested elements', () {
    expect(
      parse('<div>Click: <button>Save</button></div>'),
      [
        new TemplateAst.element('div', children: [
          new TemplateAst.text('Click: '),
          new TemplateAst.element('button', children: [
            new TemplateAst.text('Save'),
          ]),
        ]),
      ],
    );
  });

  test('should parse elements with an attribute', () {
    expect(
      parse('<button hidden title="Hello" disabled></button>'),
      [
        new TemplateAst.element('button', attributes: <AttributeAst> [
          new TemplateAst.attribute('hidden'),
          new TemplateAst.attribute('title', 'Hello'),
          new TemplateAst.attribute('disabled'),
        ]),
      ],
    );
  });
}
