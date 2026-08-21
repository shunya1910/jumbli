import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jumbli/core/theme/app_colors.dart';
import '../../domain/game_engine.dart';
import 'results_screen.dart';

class PlayerTwoScreen extends StatefulWidget {
  final String originalWord;
  final String scrambledWord;

  const PlayerTwoScreen({
    super.key,
    required this.originalWord,
    required this.scrambledWord,
  });

  @override
  State<PlayerTwoScreen> createState() => _PlayerTwoScreenState();
}

class _PlayerTwoScreenState extends State<PlayerTwoScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {

  final _guessController = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _timer;
  int _timeLeft = 10;
  bool _isGameOver = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-focus after a short delay for smooth entry
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _focusNode.requestFocus();
    });

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isGameOver) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          if (_timeLeft <= 3) {
            _pulseController.repeat(
              reverse: true,
            ); // Pulse when time is running out
          }
        } else {
          _handleTimeout();
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Game logic pause could be implemented here, but for a 10s game it's fair to keep it running
      // or we can pause the timer. Let's pause it to be nice.
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      if (!_isGameOver && _timeLeft > 0) {
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pulseController.dispose();
    _guessController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTimeout() {
    _endGame(isTimeout: true);
  }

  void _submitGuess() {
    if (_isGameOver) return;

    final guess = _guessController.text.trim();
    if (guess.isEmpty) return; // Don't penalize empty submits

    final isCorrect = GameEngine.checkAnswer(
      original: widget.originalWord,
      guess: guess,
    );

    _endGame(isCorrect: isCorrect);
  }

  void _endGame({bool isTimeout = false, bool isCorrect = false}) {
    if (_isGameOver) return;

    setState(() {
      _isGameOver = true;
    });

    _timer?.cancel();
    _focusNode.unfocus();
    _pulseController.stop();

    final resultState = isTimeout
        ? GameResult.timeout
        : (isCorrect ? GameResult.correct : GameResult.wrong);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          result: resultState,
          originalWord: widget.originalWord,
          playerGuess: _guessController.text.trim().toUpperCase(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              AppColors.secondary.withOpacity(0.15), // Red tint for urgency
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Timer
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Text(
                      '00:${_timeLeft.toString().padLeft(2, '0')}',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: _timeLeft <= 3
                            ? AppColors.secondary
                            : AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PLAYER 2',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Scrambled Word Display
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 12,
                    children: widget.scrambledWord.split('').map((letter) {
                      return Container(
                        width: 48,
                        height: 56,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.primaryLight.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 48),

                  // Input Form
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _guessController,
                      focusNode: _focusNode,
                      enabled: !_isGameOver,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                      ],
                      decoration: const InputDecoration(hintText: 'YOUR GUESS'),
                      onSubmitted: (_) => _submitGuess(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isGameOver ? null : _submitGuess,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: 8,
                      backgroundColor: AppColors.secondary, // Red action button
                      shadowColor: AppColors.secondary.withOpacity(0.5),
                    ),
                    child: Text(
                      'GUESS',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Keyboard padding spacer
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom > 0
                        ? 40
                        : 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
