import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/main_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const WaddahApp());
}

class WaddahApp extends StatelessWidget {
  const WaddahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waddah',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'AE'), // Force Arabic RTL natively
      supportedLocales: const [
        Locale('ar', 'AE'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        fontFamily: GoogleFonts.cairo().fontFamily, // Modern arabic typeface
        useMaterial3: true,
        primaryColor: const Color(0xFF9000FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9000FF),
          primary: const Color(0xFF9000FF),
          secondary: const Color(0xFF00C853),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const MainDashboard();
        }

        return const LoginScreen();
      },
    );
  }
}
