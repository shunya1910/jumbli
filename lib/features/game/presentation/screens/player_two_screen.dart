import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jumbli/core/theme/app_colors.dart';
import '../../domain/game_engine.dart';
import 'package:jumbli/core/utils/audio_manager.dart';
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
  
  Timer? _timer;
  int _timeLeft = 10;
  bool _isGameOver = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late List<Map<String, dynamic>> _currentCards;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Assign a unique ID to each letter so ReorderableListView can track them reliably
    _currentCards = widget.scrambledWord.split('').asMap().entries.map((e) => {
      'letter': e.value,
      'id': e.key,
    }).toList();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

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
          AudioManager.playTick();
          if (_timeLeft <= 3) {
            _pulseController.repeat(reverse: true);
          }
        } else {
          _endGame(isTimeout: true);
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
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
    super.dispose();
  }

  void _checkWinCondition() {
    if (_isGameOver) return;
    final currentWord = _currentCards.map((c) => c['letter'] as String).join('');
    if (GameEngine.checkAnswer(original: widget.originalWord, guess: currentWord)) {
      _endGame(isCorrect: true);
    }
  }

  void _endGame({bool isTimeout = false, bool isCorrect = false}) {
    if (_isGameOver) return;
    setState(() { _isGameOver = true; });
    _timer?.cancel();
    _pulseController.stop();

    final resultState = isTimeout
        ? GameResult.timeout
        : (isCorrect ? GameResult.correct : GameResult.wrong);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          result: resultState,
          originalWord: widget.originalWord,
          playerGuess: _currentCards.map((c) => c['letter'] as String).join(''),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate a good width for the cards, making them significantly larger
    final screenWidth = MediaQuery.of(context).size.width;
    final maxCardWidth = (screenWidth - 48 - ((_currentCards.length - 1) * 8)) / _currentCards.length;
    // Allow cards to be much larger, capping at 130 instead of 80. If there are many letters, they will comfortably scroll horizontally.
    final cardWidth = maxCardWidth > 130.0 ? 130.0 : (maxCardWidth < 90.0 ? 90.0 : maxCardWidth);
    final cardHeight = cardWidth * 1.3;

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
              AppColors.secondary.withOpacity(0.15),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Small Timer Top Left
              Positioned(
                top: 16,
                left: 16,
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: _timeLeft <= 3 ? AppColors.secondary : AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Text(
                        '00:${_timeLeft.toString().padLeft(2, '0')}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: _timeLeft <= 3 ? AppColors.secondary : AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Top Right Indicator
              Positioned(
                top: 20,
                right: 16,
                child: Text(
                  'DRAG TO SOLVE',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondaryLight,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Center Content: Reorderable Cards
              Center(
                child: SizedBox(
                  height: cardHeight + 40,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.transparent, // Prevents white background on drag
                    ),
                    child: ReorderableListView.builder(
                      buildDefaultDragHandles: false, // Disables the long-press requirement
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true, // Centers the list
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      itemCount: _currentCards.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final item = _currentCards.removeAt(oldIndex);
                          _currentCards.insert(newIndex, item);
                        });
                        // Add a small delay so the animation finishes before jumping to results
                        Future.delayed(const Duration(milliseconds: 300), _checkWinCondition);
                      },
                      itemBuilder: (context, index) {
                        final card = _currentCards[index];
                        final letter = card['letter'] as String;
                        final id = card['id'] as int;
                        return ReorderableDragStartListener(
                          index: index,
                          key: ValueKey(id),
                          child: Container(
                            width: cardWidth,
                            height: cardHeight,
                            margin: EdgeInsets.only(right: index == _currentCards.length - 1 ? 0 : 8),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 2,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: cardWidth * 0.6, // Responsive text
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
