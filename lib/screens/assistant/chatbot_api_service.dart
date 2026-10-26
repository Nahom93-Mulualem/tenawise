import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'srh_knowledge_engine.dart';

class ChatbotResult {
  final String text;
  final String category;
  final List<String> followUpQuestions;
  final bool isUrgent;
  final String source;

  const ChatbotResult({
    required this.text,
    required this.category,
    required this.followUpQuestions,
    required this.isUrgent,
    required this.source,
  });
}

class ChatbotApiService {
  // Configurable base URL. For local dev:
  // - Web: http://localhost:8000
  // - Android emulator: http://10.0.2.2:8000
  // - iOS simulator or desktop: http://localhost:8000
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  static bool _backendAvailable = false;
  static bool _geminiConfigured = false;
  static DateTime? _lastChecked;

  static bool get isBackendAvailable => _backendAvailable;
  static bool get isGeminiConfigured => _geminiConfigured;

  /// Global notifier for reactive UI updates: 'gemini', 'local_server', 'offline'
  static final ValueNotifier<String> statusNotifier = ValueNotifier<String>('offline');

  /// Probes the backend server to see if it is running and if Gemini API key is configured.
  static Future<void> checkBackendStatus() async {
    try {
      final uri = Uri.parse('$baseUrl/');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 1200));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _backendAvailable = true;
        _geminiConfigured = data['gemini_configured'] == true;
        statusNotifier.value = _geminiConfigured ? 'gemini' : 'local_server';
        return;
      }
    } catch (_) {
      _backendAvailable = false;
      _geminiConfigured = false;
      statusNotifier.value = 'offline';
    }
  }

  /// Sends a message to the Python AI Chatbot backend.
  /// If the backend is unreachable (offline or not running), it automatically
  /// falls back to the local SrhKnowledgeEngine with zero disruption and instant speed.
  static Future<ChatbotResult> sendMessage({
    required String message,
    required bool isAmharic,
  }) async {
    // If backend was recently detected as offline (within 30 seconds),
    // skip network delay and return instant local response (0 ms delay)
    final now = DateTime.now();
    if (_lastChecked != null &&
        now.difference(_lastChecked!) < const Duration(seconds: 30) &&
        !_backendAvailable) {
      final localResponse = SrhKnowledgeEngine.getResponse(message, isAmharic);
      return ChatbotResult(
        text: localResponse.text,
        category: localResponse.category,
        followUpQuestions: localResponse.followUpQuestions,
        isUrgent: localResponse.isUrgent,
        source: isAmharic ? 'የተረጋገጠ መረጃ' : 'Verified Clinical Advice',
      );
    }

    try {
      final uri = Uri.parse('$baseUrl/api/chat');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': message,
              'language': isAmharic ? 'am' : 'en',
            }),
          )
          .timeout(const Duration(milliseconds: 2000));

      if (response.statusCode == 200) {
        _backendAvailable = true;
        _lastChecked = now;
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final reply = data['reply'] as String? ?? '';
        final category = data['category'] as String? ?? 'TenaWise AI';
        final isUrgent = data['is_urgent'] as bool? ?? false;
        final followUps = (data['follow_up_questions'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final source = data['source'] as String? ?? 'Python AI Server';

        if (reply.isNotEmpty) {
          return ChatbotResult(
            text: reply,
            category: category,
            followUpQuestions: followUps,
            isUrgent: isUrgent,
            source: source,
          );
        }
      }
    } catch (_) {
      // Backend not running or offline; mark unavailable to avoid delay on next messages
      _backendAvailable = false;
      _lastChecked = now;
    }

    // Zero-failure fallback to local engine
    final localResponse = SrhKnowledgeEngine.getResponse(message, isAmharic);
    return ChatbotResult(
      text: localResponse.text,
      category: localResponse.category,
      followUpQuestions: localResponse.followUpQuestions,
      isUrgent: localResponse.isUrgent,
      source: isAmharic ? 'የተረጋገጠ መረጃ' : 'Verified Clinical Advice',
    );
  }
}
