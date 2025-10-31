import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

// Chat service provider
final chatServiceProvider = Provider((ref) => ChatService());

// Current chat session ID (uses Uuid package)
final chatSessionProvider = Provider<String>((ref) => const Uuid().v4());

// Chat state data structure
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({this.messages = const [], this.isLoading = false, this.error});

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    // Note: setting error to null explicitly clears it
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Chat state notifier (handles business logic and state updates)
class ChatNotifier extends Notifier<ChatState> {
  late final ChatService _chatService;
  late final String sessionId;

  @override
  ChatState build() {
    _chatService = ref.watch(chatServiceProvider);
    sessionId = ref.watch(chatSessionProvider);
    Future.microtask(() => loadChatHistory());
    return ChatState(isLoading: true);
  }

  Future<void> loadChatHistory() async {
    try {
      state = state.copyWith(isLoading: true);
      final messages = await _chatService.getChatHistory(sessionId);
      if (ref.mounted) {
        state = state.copyWith(messages: messages, isLoading: false);
      }
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> sendMessage(String content) async {
    // 1. Add user message immediately for optimistic UI
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      // 2. Send to API
      final response = await _chatService.sendMessage(
        message: content,
        sessionId: sessionId,
      );

      // 3. Add AI response from the API result
      final aiMessage = ChatMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: response['response'],
        timestamp: DateTime.parse(response['timestamp']),
      );

      if (ref.mounted) {
        state = state.copyWith(
          messages: [...state.messages, aiMessage],
          isLoading: false,
        );
      }
    } catch (e) {
      // 4. Handle error and keep the user's message in history
      if (ref.mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Main chat provider
final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  () => ChatNotifier(),
);

// Chat sessions provider
final chatSessionsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final chatService = ref.watch(chatServiceProvider);
  return await chatService.getChatSessions();
});
