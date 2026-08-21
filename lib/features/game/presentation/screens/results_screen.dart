import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:jumbli/core/theme/app_colors.dart';
import 'package:jumbli/core/utils/audio_manager.dart';
import 'player_one_screen.dart';

enum GameResult { correct, wrong, timeout }

class ResultsScreen extends StatefulWidget {
  final GameResult result;
  final String originalWord;
  final String playerGuess;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.originalWord,
    required this.playerGuess,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _iconAnimationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Confetti
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    if (widget.result == GameResult.correct) {
      _confettiController.play();
    }

    // Icon Animation
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 60),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 40),
        ]).animate(
          CurvedAnimation(
            parent: _iconAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    _iconAnimationController.forward();

    // Play sound based on result
    if (widget.result == GameResult.correct) {
      AudioManager.playSuccess();
    } else if (widget.result == GameResult.wrong) {
      AudioManager.playFailure();
    } else {
      AudioManager.playTimeout();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  void _nextRound() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PlayerOneScreen()),
      (route) => false,
    );
  }

  Color get _resultColor {
    switch (widget.result) {
      case GameResult.correct:
        return AppColors.success;
      case GameResult.wrong:
      case GameResult.timeout:
        return AppColors.secondary;
    }
  }

  String get _title {
    switch (widget.result) {
      case GameResult.correct:
        return 'BRILLIANT!';
      case GameResult.wrong:
        return 'NICE TRY!';
      case GameResult.timeout:
        return 'TIME\'S UP!';
    }
  }

  IconData get _icon {
    switch (widget.result) {
      case GameResult.correct:
        return Icons.star_rounded;
      case GameResult.wrong:
        return Icons.close_rounded;
      case GameResult.timeout:
        return Icons.timer_off_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface,
                  _resultColor.withOpacity(0.15),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Animated Icon
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Icon(_icon, size: 100, color: _resultColor),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    _title,
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: _resultColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Word Reveal Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'The word was',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.originalWord,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (widget.result == GameResult.wrong) ...[
                          const SizedBox(height: 24),
                          Text(
                            'You guessed',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.playerGuess.isEmpty
                                ? '(Nothing)'
                                : widget.playerGuess,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColors.secondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 64),

                  // Next Round Button
                  ElevatedButton(
                    onPressed: _nextRound,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      elevation: 8,
                      backgroundColor: _resultColor,
                      shadowColor: _resultColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'PLAY NEXT ROUND',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confetti Layer (Top)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // blast downwards
              maxBlastForce: 20, // set a lower max blast force
              minBlastForce: 5, // set a lower min blast force
              emissionFrequency: 0.05,
              numberOfParticles: 50, // a lot of particles at once
              gravity: 0.2,
              colors: const [
                AppColors.primary,
                AppColors.secondary,
                AppColors.accent,
                AppColors.success,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
