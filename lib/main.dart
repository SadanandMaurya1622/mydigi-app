import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'providers/warranty_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

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
        ChangeNotifierProvider(create: (_) {
          final provider = WarrantyProvider();
          try {
            if (Firebase.apps.isNotEmpty) {
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                provider.login(
                  currentUser.displayName ?? 'MyDigi User',
                  currentUser.email ?? '',
                  currentUser.phoneNumber ?? '',
                  photoUrl: currentUser.photoURL,
                  uid: currentUser.uid,
                );
              }
            }
          } catch (e) {
            debugPrint('FirebaseAuth check error: $e');
          }
          return provider;
        }),
      ],
      child: Consumer<WarrantyProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'MyDigi',
            debugShowCheckedModeBanner: false,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
