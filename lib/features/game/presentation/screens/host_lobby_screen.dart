import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jumbli/core/theme/app_colors.dart';
import 'package:jumbli/core/utils/validators.dart';
import '../../../../core/network/game_server.dart';
import '../../domain/game_engine.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'host_waiting_screen.dart';

class HostLobbyScreen extends StatefulWidget {
  const HostLobbyScreen({super.key});

  @override
  State<HostLobbyScreen> createState() => _HostLobbyScreenState();
}

class _HostLobbyScreenState extends State<HostLobbyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  
  bool _isTimeBound = true;
  String _ipAddress = 'Loading IP...';
  
  final GameServer _server = GameServer();

  @override
  void initState() {
    super.initState();
    _server.onPlayerJoined = (playerName) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$playerName joined the lobby!', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
    };
    _server.onError = (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Server error: $error', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    };
    _startServer();
  }

  Future<void> _startServer() async {
    // Get the device's local IP address
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    
    if (mounted) {
      setState(() {
        _ipAddress = wifiIP ?? 'Unknown IP (Are you on Wi-Fi?)';
      });
    }

    // Start listening for players
    try {
      await _server.startServer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server started! Waiting for players...', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start server: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    // Do not stop the server here if we are navigating forward to the waiting screen
    super.dispose();
  }

  void _startGame() {
    if (_formKey.currentState?.validate() ?? false) {
      final word = _wordController.text.trim().toUpperCase();
      final scrambledWord = GameEngine.scrambleWord(word);

      // 1. Broadcast the game start packet to all connected WebSockets
      final payload = jsonEncode({
        'action': 'start',
        'original_word': word,
        'scrambled_word': scrambledWord,
        'is_time_bound': _isTimeBound,
      });
      _server.broadcast(payload);

      // 2. Navigate the Host to the waiting screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HostWaitingScreen(
            server: _server,
            originalWord: word,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HOST A GAME'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            _server.stopServer(); // Stop server if they back out of hosting
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Network Instructions (Compact)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'HOST IP:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          _ipAddress,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Game Mode Toggle (Reused layout)
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
                            style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 2),
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                            ],
                            decoration: const InputDecoration(
                              hintText: 'ENTER SECRET WORD',
                              contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            ),
                            validator: Validators.validateWord,
                            onFieldSubmitted: (_) => _startGame(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _startGame,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: AppColors.primary,
                              elevation: 8,
                              shadowColor: AppColors.primary.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'BLAST TO PLAYERS',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
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
    );
  }
}
