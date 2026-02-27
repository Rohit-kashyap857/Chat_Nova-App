import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';

import '../services/voice_service.dart';
import '../models/chat_session_model.dart';
import '../models/message_model.dart';
import '../services/ai_service.dart';

class ChatProvider extends ChangeNotifier {

  final VoiceService _voiceService = VoiceService();
  bool isVoiceEnabled = true;

 
  String _selectedLanguage = "en"; // default English
  String get selectedLanguage => _selectedLanguage;

  final _uuid = const Uuid();
  final Box<ChatSession> _box =
  Hive.box<ChatSession>('chat_sessions');

  final List<ChatSession> _sessions = [];
  ChatSession? _currentSession;

  bool _isTyping = false;

  String _explanationLevel = "beginner";
  bool _wantPlan = false;
  bool _wantQuestions = false;



  ChatProvider() {
    _loadSessions();
    _ensureSessionExists();
    _voiceService.init();
    _loadLanguage();
    _loadVoicePreference();
  }

  List<ChatSession> get sessions => _sessions;
  ChatSession? get currentSession => _currentSession;
  List<MessageModel> get messages =>
      _currentSession?.messages ?? [];
  bool get isTyping => _isTyping;


  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedLanguage = prefs.getString("app_language") ?? "en";
    notifyListeners();
  }

  Future<void> changeLanguage(String lang) async {
    _selectedLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("app_language", lang);
    notifyListeners();
  }

  Future<void> _loadVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    isVoiceEnabled = prefs.getBool("voice_enabled") ?? true;
    notifyListeners();
  }

  Future<void> changeVoiceSetting(bool value) async {
    isVoiceEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("voice_enabled", value);
    notifyListeners();
  }


  void _loadSessions() {
    _sessions
      ..clear()
      ..addAll(_box.values.toList());

    _sessions.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt));

    if (_sessions.isNotEmpty) {
      _currentSession = _sessions.first;
    }
  }

  void _ensureSessionExists() {
    if (_sessions.isEmpty) {
      startNewChat();
    }
  }

  void _saveSession(ChatSession session) {
    _box.put(session.sessionId, session);
  }

  void _reloadFromBox() {
    final values = _box.values.toList();

    _sessions
      ..clear()
      ..addAll(values);

    _sessions.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt));

    if (_sessions.isNotEmpty) {
      _currentSession ??= _sessions.first;
    }
  }


  void startNewChat() {
    final session = ChatSession(
      sessionId: _uuid.v4(),
      title: "New Chat",
      createdAt: DateTime.now(),
      messages: [],
      learningSummary: "",
      projectName: null,
    );

    _sessions.insert(0, session);
    _currentSession = session;

    _saveSession(session);
    notifyListeners();
  }

  void switchSession(String sessionId) {
    _currentSession =
        _sessions.firstWhere((s) => s.sessionId == sessionId);
    notifyListeners();
  }

  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.sessionId == sessionId);
    _box.delete(sessionId);

    if (_sessions.isEmpty) {
      startNewChat();
    } else {
      _currentSession = _sessions.first;
    }

    notifyListeners();
  }

  void clearAllChats() {
    _sessions.clear();
    _box.clear();
    startNewChat();
    notifyListeners();
  }



  void assignProject(String sessionId, String projectName) {
    final session =
    _sessions.firstWhere((s) => s.sessionId == sessionId);

    session.projectName = projectName;

    _box.put(session.sessionId, session);
    _reloadFromBox();
    notifyListeners();
  }

  void removeFromProject(String sessionId) {
    final session =
    _sessions.firstWhere((s) => s.sessionId == sessionId);

    session.projectName = null;

    _box.put(session.sessionId, session);
    _reloadFromBox();
    notifyListeners();
  }

  void createEmptyProject(String projectName) {
    final session = ChatSession(
      sessionId: _uuid.v4(),
      title: "New Chat",
      createdAt: DateTime.now(),
      messages: [],
      learningSummary: "",
      projectName: projectName,
    );

    _sessions.insert(0, session);
    _currentSession = session;

    _box.put(session.sessionId, session);
    notifyListeners();
  }


  Future<void> shareSession(ChatSession session) async {
    try {
      final buffer = StringBuffer();

      for (final msg in session.messages) {
        buffer.writeln(
            "${msg.isUser ? "You" : "AI"}: ${msg.text}\n");
      }

      await SharePlus.instance.share(
        ShareParams(text: buffer.toString()),
      );
    } catch (e) {
      debugPrint("Share Error: $e");
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final session = _currentSession ?? _createSession();

    final userMessage = MessageModel(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    session.messages.add(userMessage);

    if (session.messages.length == 1) {
      session.title = text.length > 40
          ? "${text.substring(0, 40)}..."
          : text;
    }

    _isTyping = true;
    _saveSession(session);
    notifyListeners();

    final reply = await AIService.getResponse(
      userMessage: _selectedLanguage == "hi"
          ? "Please reply in Hindi.\n$text"
          : text,
      sessionMemory: session.learningSummary,
      explanationLevel: _explanationLevel,
      wantPlan: _wantPlan,
      wantQuestions: _wantQuestions,
    );

    final aiMessage = MessageModel(
      id: _uuid.v4(),
      text: reply,
      isUser: false,
      timestamp: DateTime.now(),
    );

    session.messages.add(aiMessage);

    _updateLearningSummary(session, text, reply);

    if (isVoiceEnabled && reply.trim().isNotEmpty) {
      try {
        await _voiceService.stop();

        await _voiceService.speak(
          reply,
          language: _selectedLanguage == "hi"
              ? "hi-IN"
              : "en-US",
        );
      } catch (e) {
        debugPrint("Voice Error: $e");
      }
    }

    _isTyping = false;
    _saveSession(session);
    notifyListeners();
  }

  void _updateLearningSummary(
      ChatSession session,
      String userInput,
      String aiReply) {

    final updated = """
${session.learningSummary}
User: ${_shorten(userInput)}
AI: ${_shorten(aiReply)}
""";

    session.learningSummary =
    updated.length > 1500
        ? updated.substring(updated.length - 1500)
        : updated;
  }

  String _shorten(String text) {
    final cleaned =
    text.replaceAll('\n', ' ').trim();

    return cleaned.length > 150
        ? "${cleaned.substring(0, 150)}..."
        : cleaned;
  }

  ChatSession _createSession() {
    final session = ChatSession(
      sessionId: _uuid.v4(),
      title: "New Chat",
      createdAt: DateTime.now(),
      messages: [],
      learningSummary: "",
      projectName: null,
    );

    _sessions.insert(0, session);
    _currentSession = session;

    _saveSession(session);
    return session;
  }
}
