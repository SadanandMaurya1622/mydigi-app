import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/warranty_provider.dart';
import 'screens/login_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
