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
    await _server.startServer();
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
            child: SingleChildScrollView( // Allow scrolling if keyboard blocks view
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Network Instructions
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TELL YOUR FRIENDS TO JOIN:',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.textSecondaryLight,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _ipAddress,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

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
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: _isTimeBound ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Text(
                                '10 SECONDS',
                                style: TextStyle(
                                  color: _isTimeBound ? Colors.white : AppColors.textSecondaryLight,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isTimeBound = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: !_isTimeBound ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Text(
                                '3 ATTEMPTS',
                                style: TextStyle(
                                  color: !_isTimeBound ? Colors.white : AppColors.textSecondaryLight,
                                  fontWeight: FontWeight.w800,
                                ),
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
                        TextFormField(
                          controller: _wordController,
                          style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 2),
                          textAlign: TextAlign.center,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                          ],
                          decoration: InputDecoration(
                            hintText: 'ENTER SECRET WORD',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: Validators.validateWord,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _startGame,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: AppColors.accent,
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
    );
  }
}
