import 'service_model.dart';

class AiMessageModel {
  final String role; // 'user' or 'assistant'
  final String content;
  final List<ServiceModel> suggestedServices;
  final DateTime timestamp;
  final bool isError;

  AiMessageModel({
    required this.role,
    required this.content,
    this.suggestedServices = const [],
    DateTime? timestamp,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  Map<String, dynamic> toApiHistoryJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}
