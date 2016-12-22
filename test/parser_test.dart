// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:angular_ast/angular_ast.dart';
import 'package:test/test.dart';

main() {
  final parse = const NgParser().parse;

  test('should parse a text node', () {
    expect(
      parse('Hello World'),
      [
        new TextAst('Hello World'),
      ],
    );
  });

  test('should parse a DOM element', () {
    expect(
      parse('<div></div>'),
      [
        new ElementAst('div'),
      ],
    );
  });

  test('should parse a comment', () {
    expect(
      parse('<!--Hello World-->'),
      [
        new CommentAst('Hello World'),
      ],
    );
  });

  test('should parse multi-line comments', () {
    expect(parse('<!--Hello\nWorld-->'), [
      new CommentAst('Hello\nWorld'),
    ]);

    expect(
      parse('<!--\nHello\nWorld\n-->'),
      [
        new CommentAst('\nHello\nWorld\n'),
      ],
    );
  });

  test('should parse an interpolation', () {
    expect(
      parse('{{name}}'),
      [
        new InterpolationAst(new ExpressionAst.parse('name')),
      ],
    );
  });

  test('should parse all the standalone ASTs', () {
    expect(
      parse('Hello<div></div><!--Goodbye-->{{name}}'),
      [
        new TextAst('Hello'),
        new ElementAst('div'),
        new CommentAst('Goodbye'),
        new InterpolationAst(new ExpressionAst.parse('name')),
      ],
    );
  });

  test('shoud parse a nested DOM structure', () {
    expect(
      parse(''
          '<div>\n'
          '  <span>Hello World</span>\n'
          '</div>\n'),
      [
        new ElementAst('div', childNodes: [
          new TextAst('\n  '),
          new ElementAst('span', childNodes: [
            new TextAst('Hello World'),
          ]),
          new TextAst('\n'),
        ]),
        new TextAst('\n'),
      ],
    );
  });

  test('should parse an attribute without a value', () {
    expect(
      parse('<button disabled></button>'),
      [
        new ElementAst('button', attributes: [
          new AttributeAst('disabled'),
        ]),
      ],
    );
  });

  test('should parse an attribute with a value', () {
    expect(
      parse('<button title="Submit"></button>'),
      [
        new ElementAst('button', attributes: [
          new AttributeAst('title', 'Submit'),
        ]),
      ],
    );
  });

  test('should parse an event', () {
    expect(
      parse('<button (click)="onClick()"></button>'),
      [
        new ElementAst('button', events: [
          new EventAst('click', new ExpressionAst.parse('onClick()')),
        ]),
      ],
    );
  });

  test('should parse a property without a value', () {
    expect(
      parse('<button [value]></button>'),
      [
        new ElementAst('button', properties: [
          new PropertyAst('value'),
        ]),
      ],
    );
  });

  test('should parse a property with a value', () {
    expect(
      parse('<button [value]="btnValue"></button>'),
      [
        new ElementAst('button', properties: [
          new PropertyAst('value', new ExpressionAst.parse('btnValue')),
        ]),
      ],
    );
  });

  test('should parse a reference', () {
    expect(
      parse('<button #btnRef></button>'),
      [
        new ElementAst('button', references: [
          new ReferenceAst('btnRef'),
        ]),
      ],
    );
  });

  test('should parse a reference with an identifier', () {
    expect(
      parse('<mat-button #btnRef="mat-button"></mat-button>'),
      [
        new ElementAst('mat-button', references: [
          new ReferenceAst('btnRef', 'mat-button'),
        ]),
      ],
    );
  });

  test('should parse an embedded content directive', () {
    expect(
      parse('<ng-content></ng-content>'),
      [
        new EmbeddedContentAst(),
      ],
    );
  });

  test('should parse an embedded content directive with a selector', () {
    expect(
      parse('<ng-content select="tab"></ng-content>'),
      [
        new EmbeddedContentAst('tab'),
      ],
    );
  });

  test('should parse a <template> directive', () {
    expect(
      parse('<template></template>'),
      [
        new EmbeddedTemplateAst(),
      ],
    );
  });

  test('should parse a <template> directive with a property', () {
    expect(
      parse('<template [ngIf]="someValue"></template>'),
      [
        new EmbeddedTemplateAst(
          properties: [
            new PropertyAst('ngIf', new ExpressionAst.parse('someValue')),
          ],
        ),
      ],
    );
  });

  test('should parse a <template> directive with a reference', () {
    expect(
      parse('<template #named></template>'),
      [
        new EmbeddedTemplateAst(
          references: [
            new ReferenceAst('named'),
          ],
        ),
      ],
    );
  });

  test('should parse a <template> directive with children', () {
    expect(
      parse('<template>Hello World</template>'),
      [
        new EmbeddedTemplateAst(
          childNodes: [
            new TextAst('Hello World'),
          ],
        ),
      ],
    );
  });

  test('should parse a structural directive with the * sugar syntax', () {
    expect(
      parse('<div *ngIf="someValue">Hello World</div>'),
      parse('<template [ngIf]="someValue"><div>Hello World</div></template>'),
    );
  });

  test('should parse a void element (implicit)', () {
    expect(
      parse('<input><div></div>'),
      [
        new ElementAst('input'),
        new ElementAst('div'),
      ],
    );
  });

  test('should parse a banana syntax', () {
    expect(
      parse('<custom [(name)]="myName"></custom>'),
      [
        new ElementAst(
          'custom',
          events: [
            new EventAst(
                'nameChanged', new ExpressionAst.parse('myName = \$event')),
          ],
          properties: [
            new PropertyAst('name', new ExpressionAst.parse('myName')),
          ],
        )
      ],
    );
  });
}
