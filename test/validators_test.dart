import 'package:flutter_test/flutter_test.dart';
import 'package:jumbli/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('rejects empty input', () {
      expect(Validators.validateWord(''), 'Please enter a word');
      expect(Validators.validateWord('   '), 'Please enter a word');
      expect(Validators.validateWord(null), 'Please enter a word');
    });

    test('rejects words shorter than 3 letters', () {
      expect(Validators.validateWord('hi'), 'Word must be at least 3 letters');
      expect(Validators.validateWord(' a '), 'Word must be at least 3 letters');
    });

    test('rejects words longer than 12 letters', () {
      expect(
        Validators.validateWord('thisiswaytoolong'),
        'Word is too long (max 12 letters)',
      );
    });

    test('rejects multiple words (spaces)', () {
      expect(
        Validators.validateWord('hello world'),
        'Please enter a single word only',
      );
    });

    test('rejects non-alphabet characters', () {
      expect(
        Validators.validateWord('word123'),
        'Only letters are allowed (no numbers)',
      );
      expect(
        Validators.validateWord('hello!'),
        'Only letters are allowed (no numbers)',
      );
    });

    test('accepts valid words', () {
      expect(Validators.validateWord('Flutter'), isNull);
      expect(Validators.validateWord('GAME'), isNull);
    });
  });
}
