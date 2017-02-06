// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_ast/angular_ast.dart';
import 'package:test/test.dart';

void main() {
  List<StandaloneTemplateAst> parseAndDesugar(String template) {
    return const NgParser().parseAndDesugar(
      template,
      sourceUrl: '/test/parser_test.dart#inline',
    );
  }

  test('should parse a text node', () {
    expect(
      parseAndDesugar('Hello World'),
      [
        new TextAst('Hello World'),
      ],
    );
  });

  test('should parse a DOM element', () {
    expect(
      parseAndDesugar('<div></div  >'),
      [
        new ElementAst('div'),
      ],
    );
  });

  test('should parse a comment', () {
    expect(
      parseAndDesugar('<!--Hello World-->'),
      [
        new CommentAst('Hello World'),
      ],
    );
  });

  test('should parse multi-line comments', () {
    expect(parseAndDesugar('<!--Hello\nWorld-->'), [
      new CommentAst('Hello\nWorld'),
    ]);

    expect(
      parseAndDesugar('<!--\nHello\nWorld\n-->'),
      [
        new CommentAst('\nHello\nWorld\n'),
      ],
    );
  });

  test('should parse an interpolation', () {
    expect(
      parseAndDesugar('{{ name }}'),
      [
        new InterpolationAst(new ExpressionAst.parse(
          'name',
          sourceUrl: '/test/expression/parser_test.dart#inline',
        )),
      ],
    );
  });

  test('should parse all the standalone ASTs', () {
    expect(
      parseAndDesugar('Hello<div></div><!--Goodbye-->{{name}}'),
      [
        new TextAst('Hello'),
        new ElementAst('div'),
        new CommentAst('Goodbye'),
        new InterpolationAst(new ExpressionAst.parse(
          'name',
          sourceUrl: '/test/expression/parser_test.dart#inline',
        )),
      ],
    );
  });

  test('shoud parse a nested DOM structure', () {
    expect(
      parseAndDesugar(''
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
      parseAndDesugar('<button disabled ></button>'),
      [
        new ElementAst('button', attributes: [
          new AttributeAst('disabled'),
        ]),
      ],
    );
  });

  test('should parse an attribute with a value', () {
    expect(
      parseAndDesugar('<button title="Submit"></button>'),
      [
        new ElementAst('button', attributes: [
          new AttributeAst('title', 'Submit'),
        ]),
      ],
    );
  });

  test('should parse an event', () {
    expect(
      parseAndDesugar('<button (click) = "onClick()"  ></button>'),
      [
        new ElementAst('button', events: [
          new EventAst(
              'click',
              new ExpressionAst.parse(
                'onClick()',
                sourceUrl: '/test/expression/parser_test.dart#inline',
              )),
        ]),
      ],
    );
  });

  test('should parse a property without a value', () {
    expect(
      parseAndDesugar('<button [value]></button>'),
      [
        new ElementAst('button', properties: [
          new PropertyAst('value'),
        ]),
      ],
    );
  });

  test('should parse a property with a value', () {
    expect(
      parseAndDesugar('<button [value]="btnValue"></button>'),
      [
        new ElementAst('button', properties: [
          new PropertyAst(
              'value',
              new ExpressionAst.parse(
                'btnValue',
                sourceUrl: '/test/expression/parser_test.dart#inline',
              )),
        ]),
      ],
    );
  });

  test('should parse a reference', () {
    expect(
      parseAndDesugar('<button #btnRef></button>'),
      [
        new ElementAst('button', references: [
          new ReferenceAst('btnRef'),
        ]),
      ],
    );
  });

  test('should parse a reference with an identifier', () {
    expect(
      parseAndDesugar('<mat-button #btnRef="mat-button"></mat-button>'),
      [
        new ElementAst('mat-button', references: [
          new ReferenceAst('btnRef', 'mat-button'),
        ]),
      ],
    );
  });

  test('should parse an embedded content directive', () {
    expect(
      parseAndDesugar('<ng-content></ng-content>'),
      [
        new EmbeddedContentAst(),
      ],
    );
  });

  test('should parse an embedded content directive with a selector', () {
    expect(
      parseAndDesugar('<ng-content select="tab"></ng-content>'),
      [
        new EmbeddedContentAst('tab'),
      ],
    );
  });

  test('should parse a <template> directive', () {
    expect(
      parseAndDesugar('<template></template>'),
      [
        new EmbeddedTemplateAst(),
      ],
    );
  });

  test('should parse a <template> directive with a property', () {
    expect(
      parseAndDesugar('<template [ngIf]="someValue"></template>'),
      [
        new EmbeddedTemplateAst(
          properties: [
            new PropertyAst(
                'ngIf',
                new ExpressionAst.parse(
                  'someValue',
                  sourceUrl: '/test/expression/parser_test.dart#inline',
                )),
          ],
        ),
      ],
    );
  });

  test('should parse a <template> directive with a reference', () {
    expect(
      parseAndDesugar('<template #named ></template>'),
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
      parseAndDesugar('<template>Hello World</template>'),
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
      parseAndDesugar('<div *ngIf="someValue">Hello World</div>'),
      parseAndDesugar(
          '<template [ngIf]="someValue"><div>Hello World</div></template>'),
    );
  });

  test('should parse a void element (implicit)', () {
    expect(
      parseAndDesugar('<input><div></div>'),
      [
        new ElementAst('input'),
        new ElementAst('div'),
      ],
    );
  });

  test('should parse a banana syntax', () {
    expect(
      parseAndDesugar('<custom [(name)] ="myName"></custom>'),
      [
        new ElementAst(
          'custom',
          events: [
            new EventAst(
                'nameChanged',
                new ExpressionAst.parse(
                  'myName = \$event',
                  sourceUrl: '/test/expression/parser_test.dart#inline',
                )),
          ],
          properties: [
            new PropertyAst(
                'name',
                new ExpressionAst.parse(
                  'myName',
                  sourceUrl: '/test/expression/parser_test.dart#inline',
                )),
          ],
        )
      ],
    );
  });

  test('should parse an *ngFor multi-expression', () {
    expect(
      parseAndDesugar(
          '<a *ngFor="let item of items; trackBy: byId; let i = index"></a>'),
      [
        new EmbeddedTemplateAst(
          attributes: [
            new AttributeAst('ngFor'),
          ],
          childNodes: [
            new ElementAst('a'),
          ],
          properties: [
            new PropertyAst(
              'ngForOf',
              new ExpressionAst.parse(
                'items',
                sourceUrl: '/test/expression/parser_test.dart#inline',
              ),
            ),
            new PropertyAst(
              'ngForTrackBy',
              new ExpressionAst.parse(
                'byId',
                sourceUrl: '/test/expression/parser_test.dart#inline',
              ),
            ),
          ],
          references: [
            new ReferenceAst(
              'item',
            ),
            new ReferenceAst(
              'i',
              'index',
            ),
          ],
        )
      ],
    );
  });

  test('should parse and preserve strict offset', () {
    String templateString = '''
<tab-button *ngFor="let tabLabel of tabLabels; let idx = index"  (trigger)="switchTo(idx)" [id]="tabId(idx)" class="tab-button"  ></tab-button>''';
    List<StandaloneTemplateAst> asts =
        parse(templateString, sourceUrl: '/test/parser_test.dart#inline');
    ElementAst element = asts[0] as ElementAst;
    expect(element.beginToken.offset, 0);

    expect(element.stars[0].beginToken.offset, 11);
    expect((element.stars[0] as ParsedStarAst).specialPrefixOffset, 12);

    expect(element.events[0].beginToken.offset, 63);
    expect((element.events[0] as ParsedEventAst).specialPrefixOffset, 65);

    expect(element.properties[0].beginToken.offset, 90);
    expect(
        (element.properties[0] as ParsedPropertyAst).specialPrefixOffset, 91);

    expect(element.attributes[0].beginToken.offset, 108);
    expect((element.attributes[0] as ParsedAttributeAst).nameOffset, 109);

    expect(element.whitespaces[0].offset, 127);
  });
}
