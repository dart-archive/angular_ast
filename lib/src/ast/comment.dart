import 'package:angular_ast/src/ast.dart';
import 'package:angular_ast/src/token.dart';
import 'package:source_span/source_span.dart';

/// Represents a comment block of static text.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class CommentAst implements StandaloneTemplateAst {
  /// Create a new synthetic [CommentAst] with a string [value].
  factory CommentAst(String value) = _SyntheticCommentAst;

  /// Create a new synthetic [CommentAst] that originated from node [origin].
  factory CommentAst.from(
    TemplateAst origin,
    String value,
  ) = _SyntheticCommentAst.from;

  /// Create a new [CommentAst] parsed from tokens in [sourceFile].
  factory CommentAst.parsed(
    SourceFile sourceFile,
    NgToken startCommentToken,
    NgToken valueToken,
    NgToken endCommentToken,
  ) = _ParsedCommentAst;

  @override
  bool operator ==(Object o) => o is CommentAst && value == o.value;

  @override
  int get hashCode => value.hashCode;

  /// Static text value.
  String get value;

  @override
  String toString() => '$CommentAst {$value}';
}

class _ParsedCommentAst extends TemplateAst with CommentAst {
  final NgToken _valueToken;

  _ParsedCommentAst(
    SourceFile sourceFile,
    NgToken startCommentToken,
    this._valueToken,
    NgToken endCommentToken,
  )
      : super.parsed(
          startCommentToken,
          endCommentToken,
          sourceFile,
        );

  @override
  String get value => _valueToken.lexeme;
}

class _SyntheticCommentAst extends SyntheticTemplateAst with CommentAst {
  @override
  final String value;

  _SyntheticCommentAst(this.value);

  _SyntheticCommentAst.from(
    TemplateAst origin,
    this.value,
  )
      : super.from(origin);
}
