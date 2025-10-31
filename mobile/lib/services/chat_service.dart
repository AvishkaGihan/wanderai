import '../models/chat_message.dart';
import '../models/destination.dart'; // Needed for getDestination method
import 'api_service.dart';

class ChatService {
  final ApiService _apiService = ApiService();

  // Send message and get AI response
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/chat/',
        data: {
          'message': message,
          if (sessionId != null) 'session_id': sessionId,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Get chat history
  Future<List<ChatMessage>> getChatHistory(String sessionId) async {
    try {
      final response = await _apiService.dio.get('/chat/history/$sessionId');
      // **CRITICAL FIX:** Mapping to ChatMessage, not Destination
      return (response.data as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get all chat sessions
  Future<List<Map<String, dynamic>>> getChatSessions() async {
    try {
      final response = await _apiService.dio.get('/chat/sessions');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // This method seems misplaced in ChatService but was in your prompt, so we include it:
  Future<Destination> getDestination(String destinationId) async {
    try {
      final response = await _apiService.dio.get(
        '/destinations/$destinationId',
      );
      return Destination.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
