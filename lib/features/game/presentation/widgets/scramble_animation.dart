import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';

class ScrambleAnimation extends StatefulWidget {
  final String originalWord;
  final String scrambledWord;
  final bool isScrambled;

  const ScrambleAnimation({
    super.key,
    required this.originalWord,
    required this.scrambledWord,
    required this.isScrambled,
  });

  @override
  State<ScrambleAnimation> createState() => _ScrambleAnimationState();
}

class _ScrambleAnimationState extends State<ScrambleAnimation> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  
  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    _controllers = List.generate(
      widget.originalWord.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void didUpdateWidget(ScrambleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Re-setup if length changes (should not happen in normal gameplay, but just in case)
    if (oldWidget.originalWord.length != widget.originalWord.length) {
      for (var controller in _controllers) {
        controller.dispose();
      }
      _setupControllers();
    }

    if (widget.isScrambled && !oldWidget.isScrambled) {
      _playScrambleAnimation();
    } else if (!widget.isScrambled && oldWidget.isScrambled) {
      _playScrambleAnimation();
    }
  }
  
  void _playScrambleAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) {
          _controllers[i].forward(from: 0.0);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wordToDisplay = widget.isScrambled ? widget.scrambledWord : widget.originalWord;
    final previousWord = widget.isScrambled ? widget.originalWord : widget.scrambledWord;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 12,
      children: List.generate(wordToDisplay.length, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            final value = _controllers[index].value;
            
            // Switch letter at exactly 50% of the animation
            final currentLetter = value < 0.5 ? previousWord[index] : wordToDisplay[index];
            
            // Scale goes 1 -> 0 -> 1
            final scale = value < 0.5 
                ? 1.0 - (value * 2) 
                : (value - 0.5) * 2;
                
            // Rotate 0 to 180 degrees (pi)
            final rotation = value * math.pi;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateY(rotation)
                ..scale(scale),
              child: Opacity(
                opacity: (scale < 0.2) ? 0.0 : 1.0, // Slight fade in the middle
                child: Container(
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
                      currentLetter,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
