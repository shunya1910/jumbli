import 'package:flutter/material.dart';
import 'package:jumbli/core/theme/app_colors.dart';
import '../../../../core/network/game_client.dart';
import 'client_waiting_screen.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ipController = TextEditingController();
  
  final GameClient _client = GameClient();
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    
    _client.onConnected = () {
      if (!mounted) return;
      setState(() => _isConnecting = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully connected to Host!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ClientWaitingScreen(
            client: _client,
            playerName: _nameController.text.trim(),
            onCancel: () {
              _client.disconnect();
              Navigator.pop(context);
            },
          ),
        ),
      );
    };

    _client.onError = (error) {
      if (!mounted) return;
      setState(() => _isConnecting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $error', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    };

    _client.onDisconnected = () {
      if (!mounted) return;
      setState(() => _isConnecting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disconnected from Host', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
        ),
      );
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  void _connectToHost() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isConnecting = true;
      });
      // Start connection
      _client.connect(_ipController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('JOIN A GAME'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            _client.disconnect();
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        controller: _nameController,
                        style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 2),
                        textAlign: TextAlign.start,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'YOUR NICKNAME',
                          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter a name' : null,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                        controller: _ipController,
                        style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 2),
                        textAlign: TextAlign.start,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: 'HOST IP ADDRESS',
                          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter the Host IP' : null,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    if (_isConnecting)
                      const Column(
                        children: [
                          CircularProgressIndicator(color: AppColors.secondary),
                          SizedBox(height: 16),
                          Text('Waiting for Host to start...', style: TextStyle(color: AppColors.textSecondaryLight, fontWeight: FontWeight.bold)),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _connectToHost,
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
                            'CONNECT',
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
