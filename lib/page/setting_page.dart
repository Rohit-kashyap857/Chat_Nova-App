import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../screens/providers/chat_provider.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Container(
          decoration: isDark
              ? const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1F1B24),
                Color(0xFF121212),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          )
              : BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text("Settings"),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ---------------- APP SETTINGS ----------------
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'App Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SwitchListTile(
                    title: const Text("Dark Theme"),
                    subtitle: Text(
                      isDark
                          ? "Dark mode enabled"
                          : "Light mode enabled",
                    ),
                    value: isDark,
                    onChanged: (value) async {
                      themeNotifier.value =
                      value ? ThemeMode.dark : ThemeMode.light;

                      final prefs =
                      await SharedPreferences.getInstance();
                      await prefs.setBool('dark_mode', value);
                    },
                  ),

                  const Divider(),

                  // ---------------- LANGUAGE ----------------
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Language',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Consumer<ChatProvider>(
                    builder: (context, provider, _) {
                      return SwitchListTile(
                        title: const Text("Hindi Language"),
                        subtitle: Text(
                          provider.selectedLanguage == "hi"
                              ? "Replies in Hindi"
                              : "Replies in English",
                        ),
                        value:
                        provider.selectedLanguage == "hi",
                        onChanged: (value) {
                          provider.changeLanguage(
                              value ? "hi" : "en");
                        },
                      );
                    },
                  ),

                  const Divider(),

                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Voice Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Consumer<ChatProvider>(
                    builder: (context, provider, _) {
                      return SwitchListTile(
                        title: const Text("Voice Reply"),
                        subtitle: Text(
                          provider.isVoiceEnabled
                              ? "AI will speak responses"
                              : "Voice reply disabled",
                        ),
                        value: provider.isVoiceEnabled,
                        onChanged: (value) {
                          provider.changeVoiceSetting(value);
                        },
                      );
                    },
                  ),

                  const Divider(),

                  // ---------------- ABOUT ----------------
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'About',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.info),
                    trailing:
                    const Icon(Icons.arrow_forward_ios, size: 16),
                    title: const Text('About Info'),
                    onTap: () {},
                  ),

                  ListTile(
                    leading:
                    const Icon(Icons.safety_check_sharp),
                    trailing:
                    const Icon(Icons.arrow_forward_ios, size: 16),
                    title:
                    const Text('Privacy Policy'),
                    onTap: () {},
                  ),

                  ListTile(
                    leading:
                    const Icon(Icons.contact_page_rounded),
                    trailing:
                    const Icon(Icons.arrow_forward_ios, size: 16),
                    title:
                    const Text('Terms & Conditions'),
                    onTap: () {},
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
