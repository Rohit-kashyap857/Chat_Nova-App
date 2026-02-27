import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/models/message_model.dart';
import 'screens/models/chat_session_model.dart';
import 'screens/providers/chat_provider.dart';
import 'screens/chat_screen.dart';

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? true;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  await Hive.initFlutter();

  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(ChatSessionAdapter());

  await Hive.openBox<ChatSession>('chat_sessions');

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, currentMode, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            themeMode: currentMode, 

            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),

            home: const ChatScreen(),
          );
        },
      ),
    );
  }
}
