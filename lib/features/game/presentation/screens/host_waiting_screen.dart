import 'package:flutter/material.dart';
import 'package:jumbli/core/theme/app_colors.dart';
import '../../../../core/network/game_server.dart';
import 'results_screen.dart';
import 'host_lobby_screen.dart';

class HostWaitingScreen extends StatefulWidget {
  final GameServer server;
  final String originalWord;

  const HostWaitingScreen({
    super.key,
    required this.server,
    required this.originalWord,
  });

  @override
  State<HostWaitingScreen> createState() => _HostWaitingScreenState();
}

class _HostWaitingScreenState extends State<HostWaitingScreen> {
  @override
  void initState() {
    super.initState();
    
    // Listen for someone to win
    widget.server.onPlayerWon = (data) {
      if (!mounted) return;
      final winnerName = data['name'] as String? ?? 'A Player';
      
      // Go to results screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            result: GameResult.correct,
            originalWord: widget.originalWord,
            playerGuess: winnerName,
            isHostView: true,
            onNextRound: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HostLobbyScreen())
            ),
            onExit: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ),
      );
    };
  }

  @override
  void dispose() {
    widget.server.stopServer(); // Close server when leaving this screen
    super.dispose();
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 32),
              Text(
                'GAME IN PROGRESS',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Waiting for a player to solve the puzzle...',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 48),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  side: const BorderSide(color: AppColors.secondary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('CANCEL GAME', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
