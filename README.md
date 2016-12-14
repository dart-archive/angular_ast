# angular_ast

Parser and utilities for [AngularDart][gh_angular_dart] templates.

[gh_angular_dart]: https://github.com/dart-lang/angular2

<!-- Badges will go here -->

This package is _platform agnostic_ (no HTML or Dart VM dependencies).

## Usage

*Currently in development* and **not stable**.

```dart
import 'package:angular_ast/angular_ast.dart';

main() {
  // Create an AST tree by parsing an AngularDart template.
  var tree = parse('<button [title]="someTitle">Hello</button>');

  // Print to console.
  print(tree);

  // Output:
  // [
  //    ElementAst <button> { 
  //      properties=
  //        PropertyAst {
  //          title="ExpressionAst {someTitle}"} 
  //          childNodes=TextAst {Hello} 
  //      }
  //    }
  // ]
}
```
