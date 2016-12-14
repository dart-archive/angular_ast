import 'package:angular_ast/src/token.dart';
import 'package:source_span/source_span.dart';

/// A narrow interface for reading tokens from a series of tokens.
class NgTokenReader {
  final Iterator<NgToken> _iterator;
  final SourceFile _source;

  NgToken _peek;

  factory NgTokenReader(SourceFile source, Iterable<NgToken> tokens) {
    return new NgTokenReader._(source, tokens.iterator);
  }

  NgTokenReader._(this._source, this._iterator);

  /// Throws a [FormatException] at the current token.
  void error(String message) {
    throw new FormatException(
      message,
      _source.getText(0),
      _iterator.current.offset,
    );
  }

  /// Returns the next token if it is of [type].
  ///
  /// Otherwise throws a [FormatException].
  NgToken expect(NgTokenType type) {
    final next = this.next();
    if (when(type)) {
      return next;
    }
    error('Expected a token of $type but got ${next.type}');
    return null;
  }

  /// Returns the next token, if any, otherwise `null`.
  NgToken next() {
    if (_peek != null) {
      final token = _peek;
      _peek = null;
      return token;
    }
    return _iterator.moveNext() ? _iterator.current : null;
  }

  /// Returns the next token without incrementing.
  NgToken peek() => _peek = next();

  /// Returns whether the current token is of [type].
  bool when(NgTokenType type) => _iterator.current.type == type;
}
