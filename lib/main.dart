import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/game/presentation/screens/player_one_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const JumbliApp());
}

class JumbliApp extends StatelessWidget {
  const JumbliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jumbli',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const PlayerOneScreen(),
    );
  }
}
