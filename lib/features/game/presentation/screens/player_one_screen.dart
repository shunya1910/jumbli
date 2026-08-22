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
        MaterialPageRoute(
          builder: (_) => PlayerTwoScreen(
            originalWord: word,
            scrambledWord: scrambledWord,
          ),
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
            child: SingleChildScrollView(
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
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(
                            0.7,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

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
                                textAlign: TextAlign.center,
                                textCapitalization: TextCapitalization.characters,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                                ],
                                decoration: const InputDecoration(
                                  hintText: 'ENTER YOUR WORD',
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
                                'LOCK IT IN',
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
        ),
      ),
    );
  }
}
