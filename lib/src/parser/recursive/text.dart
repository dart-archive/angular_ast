part of angular_ast.src.parser.recursive;

// AST node that originated from token(s).
class _ParsedTextAst extends Object
    with TextAstMixin
    implements TextAst {
  final NgToken _token;

  _ParsedTextAst(this._token);

  @override
  SourceSpan sourceSpan(SourceFile source) {
    return source.span(_token.offset, _token.end);
  }

  @override
  String get value => _token.lexeme;
}
