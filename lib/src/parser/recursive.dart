library angular_ast.src.parser.recursive;

import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token.dart';
import 'package:source_span/source_span.dart';

part 'recursive/attribute.dart';
part 'recursive/element.dart';
part 'recursive/text.dart';

/// A recursive descent parser for a template AST.
class RecursiveAstParser {
  final String _source;

  const RecursiveAstParser(this._source);

  // Assert that the token is the expected type.
  void _expect(NgToken token, NgTokenType type) {
    if (token.type != type) {
      throw new FormatException(
        'Expected $type, got ${token.type}',
        _source,
        token.offset,
      );
    }
  }

  /// Return [tokens] parsed a series of HTML-like AST nodes.
  Iterable<TemplateAst> parse(Iterable<NgToken> tokens) {
    return _parseStandalone(tokens.iterator);
  }

  // Returns an attribute AST by parsing the iterator.
  AttributeAst _parseAttribute(Iterator<NgToken> iterator) {
    // Get the name token and assert the next token type.
    final nameToken = iterator.current;
    _expect(nameToken, NgTokenType.elementDecorator);
    iterator.moveNext();

    // Find value, if any.
    NgToken valueToken;
    if (iterator.current.type == NgTokenType.beforeElementDecoratorValue) {
      iterator.moveNext();
      valueToken = iterator.current;
      _expect(valueToken, NgTokenType.elementDecoratorValue);
      iterator.moveNext();
      _expect(iterator.current, NgTokenType.afterElementDecoratorValue);
    }

    // Return the parsed attribute.
    return new _ParsedAttributeAst(nameToken, valueToken);
  }

  // Returns an element AST by parsing the iterator.
  ElementAst _parseElement(
    NgToken startToken,
    Iterator<NgToken> iterator,
  ) {
    // Assert that we are starting with the right element.
    _expect(startToken, NgTokenType.openElementStart);
    iterator.moveNext();

    // Get the name token and assert the next token type.
    final nameToken = iterator.current;
    _expect(nameToken, NgTokenType.elementIdentifier);

    // Find decorators.
    final attributes = <AttributeAst>[];
    while (iterator.current.type != NgTokenType.openElementEnd) {
      if (iterator.current.type != NgTokenType.beforeElementDecorator) {
        iterator.moveNext();
      }
      if (iterator.current.type == NgTokenType.beforeElementDecorator) {
        iterator.moveNext();
        switch (iterator.current.type) {
          case NgTokenType.elementDecorator:
            attributes.add(_parseAttribute(iterator));
            break;
        }
      }
    }

    // Find children.
    final children = _parseStandalone(iterator);
    while (iterator.current.type != NgTokenType.closeElementStart) {
      iterator.moveNext();
    }

    // Assert the closing tag.
    iterator.moveNext();
    _expect(iterator.current, NgTokenType.elementIdentifier);
    if (iterator.current.lexeme != nameToken.lexeme) {
      throw new FormatException(
        'Expected ${nameToken.lexeme} but got ${iterator.current.lexeme}',
        _source,
        iterator.current.offset,
      );
    }
    while (iterator.current.type != NgTokenType.closeElementEnd) {
      iterator.moveNext();
    }

    // Return the parsed element.
    final endToken = iterator.current;
    return new _ParsedElementAst(
      startToken,
      nameToken,
      endToken,
      attributes: attributes,
      children: children,
    );
  }

  // Using the tokens in iterator, finds what can be a standalone AST.
  //
  // That means the following ASTs can be collected:
  // - ElementAst
  // - TestAst
  //
  // Any other tokens stop parsing the iterator and return results so far.
  List<TemplateAst> _parseStandalone(Iterator<NgToken> iterator) {
    final results = <TemplateAst>[];
    while (iterator.moveNext()) {
      final token = iterator.current;
      switch (token.type) {
        case NgTokenType.openElementStart:
          results.add(_parseElement(token, iterator));
          break;
        case NgTokenType.text:
          results.add(_parseText(token));
          break;
        default:
          return results;
      }
    }
    return results;
  }

  // Returns the text node as a parsed AST.
  TextAst _parseText(NgToken token) => new _ParsedTextAst(token);
}
