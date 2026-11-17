import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/ai_message_model.dart';
import '../models/service_model.dart';

class AiServiceResponse {
  final String reply;
  final List<ServiceModel> suggestedServices;
  final String provider;

  AiServiceResponse({
    required this.reply,
    required this.suggestedServices,
    required this.provider,
  });
}

class AiService {
  /// Send chat query to AI Assistant
  static Future<AiServiceResponse> chat({
    required String message,
    List<AiMessageModel> history = const [],
  }) async {
    final historyPayload = history
        .where((m) => !m.isError)
        .map((m) => m.toApiHistoryJson())
        .toList();

    final response = await ApiClient.post(
      ApiEndpoints.aiChat,
      requiresAuth: false,
      body: {
        'message': message,
        'history': historyPayload,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    final reply = data['reply']?.toString() ?? 'I could not process your request at this moment.';
    final provider = data['provider']?.toString() ?? 'rule_engine';

    final rawServices = data['suggestedServices'] as List<dynamic>? ?? [];
    final suggested = rawServices
        .map((s) => ServiceModel.fromJson(s as Map<String, dynamic>))
        .toList();

    return AiServiceResponse(
      reply: reply,
      suggestedServices: suggested,
      provider: provider,
    );
  }

  /// Get targeted service recommendations
  static Future<AiServiceResponse> recommend({
    required String preferences,
    String? category,
    double? maxBudget,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.aiRecommend,
      requiresAuth: false,
      body: {
        'preferences': preferences,
        if (category != null && category != 'All') 'category': category,
        'maxBudget': ?maxBudget,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    final reply = data['reply']?.toString() ?? '';
    final provider = data['provider']?.toString() ?? 'rule_engine';

    final rawServices = data['suggestedServices'] as List<dynamic>? ?? [];
    final suggested = rawServices
        .map((s) => ServiceModel.fromJson(s as Map<String, dynamic>))
        .toList();

    return AiServiceResponse(
      reply: reply,
      suggestedServices: suggested,
      provider: provider,
    );
  }
}
