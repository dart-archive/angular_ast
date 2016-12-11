import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/lexer.dart';
import 'package:angular_ast/src/parser/recursive.dart';
import 'package:meta/meta.dart';

class NgParser {
  @literal
  const factory NgParser() = NgParser._;

  const NgParser._();

  List<TemplateAst> parse(String html) {
    return new List<TemplateAst>.unmodifiable(
      new RecursiveAstParser(html).parse(const NgLexer().tokenize(html)),
    );
  }
}
