import 'package:flutter/foundation.dart';
import '../models/ai_message_model.dart';
import '../services/ai_service.dart';

class AiChatProvider extends ChangeNotifier {
  final List<AiMessageModel> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AiMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AiChatProvider() {
    _initWelcomeMessage();
  }

  void _initWelcomeMessage() {
    _messages.clear();
    _messages.add(
      AiMessageModel(
        role: 'assistant',
        content:
            "👋 Hello! I'm your AI Booking Concierge. How can I assist you today? You can ask about our available services, prices, durations, or ask for personalized recommendations based on your needs!",
      ),
    );
  }

  /// Send user message to AI assistant
  Future<void> sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    // Append user message immediately
    _messages.add(AiMessageModel(role: 'user', content: query));
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await AiService.chat(
        message: query,
        history: _messages,
      );

      _messages.add(
        AiMessageModel(
          role: 'assistant',
          content: response.reply,
          suggestedServices: response.suggestedServices,
        ),
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _messages.add(
        AiMessageModel(
          role: 'assistant',
          content: "Sorry, I couldn't connect to the AI service right now. Please make sure the backend is running.",
          isError: true,
        ),
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset conversation
  void clearChat() {
    _initWelcomeMessage();
    _errorMessage = null;
    notifyListeners();
  }
}
