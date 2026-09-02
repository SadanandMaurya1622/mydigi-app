import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/warranty_provider.dart';
import 'screens/login_screen.dart';
import 'utils/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }
  runApp(const MyDigiApp());
}

class MyDigiApp extends StatelessWidget {
  const MyDigiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WarrantyProvider()),
      ],
      child: Consumer<WarrantyProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'MyDigi',
            debugShowCheckedModeBanner: false,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
