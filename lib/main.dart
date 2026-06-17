import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/coin_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CoinProvider()),
      ],
      child: MaterialApp(
        title: 'Crypto Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
          
          // Theme configurations
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6366F1), // Indigo 500
            secondary: Color(0xFF818CF8), // Indigo 400
            surface: Color(0xFF1E293B), // Slate 800
            error: Color(0xFFF43F5E), // Rose 500
          ),
          
          // App Bar Theme
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF0F172A),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          // Text Theme
          textTheme: GoogleFonts.outfitTextTheme(
            ThemeData.dark().textTheme,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
