// TODO: This is a placeholder.
//
// Probably want to either:
// - Port the original one
// - Write a new one
// - Use the Dart analyzer and special case pipes
// - Use the Dart analyzer and transform pipes
class ExpressionAst {
  final String expression;

  const ExpressionAst(this.expression);

  @override
  bool operator ==(Object o) =>
      o is ExpressionAst && o.expression == expression;

  @override
  int get hashCode => expression.hashCode;

  @override
  String toString() => '$ExpressionAst {$expression}';
}
