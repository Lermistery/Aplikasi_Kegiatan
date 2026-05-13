import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const KegiatanKuApp());
}

class KegiatanKuApp extends StatefulWidget {
  const KegiatanKuApp({super.key});

  @override
  State<KegiatanKuApp> createState() => _KegiatanKuAppState();
}

class _KegiatanKuAppState extends State<KegiatanKuApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KegiatanKu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const WelcomeScreen(),
    );
  }
}
