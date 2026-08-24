import 'package:flutter/material.dart';
import 'package:jumbli/core/theme/app_colors.dart';

import '../../../../core/network/game_client.dart';
import 'player_two_screen.dart';

class ClientWaitingScreen extends StatefulWidget {
  final GameClient client;
  final String playerName;
  final VoidCallback onCancel;

  const ClientWaitingScreen({
    super.key,
    required this.client,
    required this.playerName,
    required this.onCancel,
  });

  @override
  State<ClientWaitingScreen> createState() => _ClientWaitingScreenState();
}

class _ClientWaitingScreenState extends State<ClientWaitingScreen> {
  @override
  void initState() {
    super.initState();
    
    // Listen for the Host to start the game
    widget.client.onGameStarted = (data) {
      if (!mounted) return;
      
      final originalWord = data['original_word'];
      final scrambledWord = data['scrambled_word'];
      final isTimeBound = data['is_time_bound'] ?? true;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PlayerTwoScreen(
            originalWord: originalWord,
            scrambledWord: scrambledWord,
            isTimeBound: isTimeBound,
            client: widget.client,
            playerName: widget.playerName,
          ),
        ),
      );
    };
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
              AppColors.secondary.withOpacity(0.15),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.secondary, size: 64),
              const SizedBox(height: 24),
              Text(
                'CONNECTED!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Waiting for the Host to blast the puzzle...',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 48),
              OutlinedButton(
                onPressed: widget.onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('DISCONNECT', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
