part of angular_ast.src.parser.recursive;

// AST node that originated from token(s).
class _ParsedElementAst extends Object
    with ElementAstMixin
    implements ElementAst {
  final NgToken _beginToken;
  final NgToken _nameToken;
  final NgToken _endToken;

  @override
  final List<TemplateAst> children;

  _ParsedElementAst(
    this._beginToken,
    this._nameToken,
    this._endToken, {
    this.children: const [],
  });

  @override
  String get name => _nameToken.lexeme;

  @override
  SourceSpan sourceSpan(SourceFile source) {
    return source.span(_beginToken.offset, _endToken.end);
  }
}
