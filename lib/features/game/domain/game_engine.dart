import 'dart:math';

class GameEngine {
  /// Normalizes a word by removing whitespace and converting to uppercase.
  static String normalizeWord(String word) {
    return word.trim().toUpperCase();
  }

  /// Scrambles the word. Guarantees the output is different from the input
  /// if the word has more than one unique character.
  static String scrambleWord(String word) {
    final original = normalizeWord(word);

    // If word is only 1 character, or all characters are identical (e.g. "AAA"),
    // it can't be scrambled into a different string.
    final uniqueChars = original.split('').toSet();
    if (uniqueChars.length <= 1) {
      return original;
    }

    final random = Random();
    String scrambled;

    do {
      final chars = original.split('');
      chars.shuffle(random);
      scrambled = chars.join('');
    } while (scrambled == original); // Ensure it's strictly different

    return scrambled;
  }

  /// Checks if the guessed word matches the original word.
  static bool checkAnswer({required String original, required String guess}) {
    return normalizeWord(original) == normalizeWord(guess);
  }
}
