class Validators {
  static String? validateWord(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a word';
    }

    final word = value.trim();

    if (word.length < 3) {
      return 'Word must be at least 3 letters';
    }

    if (word.length > 12) {
      return 'Word is too long (max 12 letters)';
    }

    if (word.contains(' ')) {
      return 'Please enter a single word only';
    }

    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(word)) {
      return 'Only letters are allowed (no numbers)';
    }

    return null;
  }
}
