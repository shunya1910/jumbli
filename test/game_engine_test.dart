import 'package:flutter_test/flutter_test.dart';
import 'package:jumbli/features/game/domain/game_engine.dart';

void main() {
  group('GameEngine Normalization', () {
    test('removes whitespace and converts to uppercase', () {
      expect(GameEngine.normalizeWord(' hello '), 'HELLO');
      expect(GameEngine.normalizeWord('WoRd'), 'WORD');
    });
  });

  group('GameEngine Scrambling', () {
    test('scrambles word to be different from original', () {
      const original = 'FLUTTER';
      final scrambled = GameEngine.scrambleWord(original);
      
      expect(scrambled.length, original.length);
      expect(scrambled, isNot(equals(original)));
      
      // Ensure all letters are still present
      final originalSorted = original.split('')..sort();
      final scrambledSorted = scrambled.split('')..sort();
      expect(originalSorted, equals(scrambledSorted));
    });

    test('handles identical characters gracefully', () {
      const original = 'AAA';
      final scrambled = GameEngine.scrambleWord(original);
      expect(scrambled, equals('AAA')); // Cannot be scrambled differently
    });
    
    test('handles case differences during scramble', () {
      final scrambled = GameEngine.scrambleWord('word');
      expect(scrambled, isNot(equals('WORD')));
      expect(scrambled.toUpperCase(), equals(scrambled));
    });
  });

  group('GameEngine Answer Checking', () {
    test('returns true for correct answer ignoring case', () {
      expect(GameEngine.checkAnswer(original: 'FLUTTER', guess: 'flutter'), isTrue);
      expect(GameEngine.checkAnswer(original: 'FLUTTER', guess: ' FLUTTER '), isTrue);
    });

    test('returns false for incorrect answer', () {
      expect(GameEngine.checkAnswer(original: 'FLUTTER', guess: 'FLUTTERR'), isFalse);
      expect(GameEngine.checkAnswer(original: 'FLUTTER', guess: 'DART'), isFalse);
    });
  });
}
