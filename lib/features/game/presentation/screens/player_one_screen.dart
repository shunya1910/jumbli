import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jumbli/core/theme/app_colors.dart';
import 'package:jumbli/core/utils/validators.dart';
import '../../domain/game_engine.dart';

import 'player_two_screen.dart';

class PlayerOneScreen extends StatefulWidget {
  const PlayerOneScreen({super.key});

  @override
  State<PlayerOneScreen> createState() => _PlayerOneScreenState();
}

class _PlayerOneScreenState extends State<PlayerOneScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _focusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isTimeBound = true;



  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    // Auto-focus after a short delay for smooth entry
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _wordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitWord() {
    if (_formKey.currentState?.validate() ?? false) {
      final word = _wordController.text.trim().toUpperCase();
      // Remove focus to hide keyboard
      _focusNode.unfocus();

      final scrambledWord = GameEngine.scrambleWord(word);
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => PlayerTwoScreen(
            originalWord: word,
            scrambledWord: scrambledWord,
            isTimeBound: _isTimeBound,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
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
              AppColors.primaryLight.withOpacity(0.15),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Text(
                        'PLAYER 1',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter a word for your friend to guess',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Premium Custom Game Mode Toggle
                      Center(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _isTimeBound = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: _isTimeBound ? AppColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Row(
                                    children: [
                                      TweenAnimationBuilder<Color?>(
                                        duration: const Duration(milliseconds: 250),
                                        tween: ColorTween(end: _isTimeBound ? Colors.white : AppColors.textSecondaryLight),
                                        builder: (context, color, child) {
                                          return Icon(
                                            Icons.timer_outlined,
                                            size: 20,
                                            color: color,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 250),
                                        style: TextStyle(
                                          color: _isTimeBound ? Colors.white : AppColors.textSecondaryLight,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                        child: const Text('10 SECONDS'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _isTimeBound = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: !_isTimeBound ? AppColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Row(
                                    children: [
                                      TweenAnimationBuilder<Color?>(
                                        duration: const Duration(milliseconds: 250),
                                        tween: ColorTween(end: !_isTimeBound ? Colors.white : AppColors.textSecondaryLight),
                                        builder: (context, color, child) {
                                          return Icon(
                                            Icons.favorite_outline_rounded,
                                            size: 20,
                                            color: color,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 250),
                                        style: TextStyle(
                                          color: !_isTimeBound ? Colors.white : AppColors.textSecondaryLight,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                        child: const Text('3 ATTEMPTS'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                              child: TextFormField(
                                controller: _wordController,
                                focusNode: _focusNode,
                                style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 2),
                                textAlign: TextAlign.start,
                                textCapitalization: TextCapitalization.characters,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                                ],
                                decoration: const InputDecoration(
                                  hintText: 'ENTER YOUR WORD',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                ),
                                validator: Validators.validateWord,
                                onFieldSubmitted: (_) => _submitWord(),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Submit Button
                            ElevatedButton(
                              onPressed: _submitWord,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                elevation: 8,
                                shadowColor: AppColors.primary.withOpacity(0.5),
                              ),
                              child: Text(
                                'SHOW',
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


                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
