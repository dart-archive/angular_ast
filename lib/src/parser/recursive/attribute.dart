part of angular_ast.src.parser.recursive;

// AST node that originated from token(s).
class _ParsedAttributeAst extends Object
    with AttributeAstMixin
    implements AttributeAst {
  final NgToken _name;
  final NgToken _value;

  _ParsedAttributeAst(this._name, this._value);

  @override
  SourceSpan sourceSpan(SourceFile source) {
    return source.span(_name.offset, (_value ?? _name).end);
  }

  @override
  String get name => _name.lexeme;

  @override
  String get value => _value?.lexeme;
}
