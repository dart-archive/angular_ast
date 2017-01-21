import 'package:angular_ast/src/simple_tokenizer.dart';
import 'package:angular_ast/src/simple_token.dart';
import 'package:test/test.dart';

void main() {
  test('should greedily parse only text nodes', () {
    expect(
      new NgSimpleScanner("some random text <div>").scan(),
      new NgSimpleToken.text(0, "some random text"),
    );
  });

  test('should parse only an elementStart tag', () {
    expect(new NgSimpleScanner("<div></div>").scan(),
        new NgSimpleToken.elementStart(0));
  });

  test('should parse end of file', () {
    expect(new NgSimpleScanner("").scan(), new NgSimpleToken.EOF(0));
  });
}
