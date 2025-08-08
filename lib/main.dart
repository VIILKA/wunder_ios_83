import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'src/core/models/game_session.dart';
import 'src/core/services/notification_service.dart';
import 'src/features/sessions/providers/session_provider.dart';
import 'src/features/sessions/ui/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Hive.initFlutter();
  Hive.registerAdapter(GameMoodAdapter());
  Hive.registerAdapter(GameSessionAdapter());
  await Hive.openBox<GameSession>(HiveBoxes.sessions);

  await NotificationService.instance.initialize(
    const AndroidInitializationSettings('@mipmap/ic_launcher'),
    const DarwinInitializationSettings(),
  );

  runApp(const WunderApp());
}

class WunderApp extends StatelessWidget {
  const WunderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2CC9FF),
      brightness: Brightness.dark,
    );

    final textTheme = GoogleFonts.montserratTextTheme(
      ThemeData.dark().textTheme,
    );

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SessionProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Wunder',
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: colorScheme,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0F2239),
          cardTheme: const CardThemeData(
            color: Color(0xFF162B49),
            elevation: 2,
            margin: EdgeInsets.zero,
          ),
          textTheme: textTheme,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFF162B49),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF0F2239).withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.secondary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
