import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../utils/error_handler.dart';
import '../../utils/date_formatter.dart';
import '../../models/chat_message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Helper to scroll the chat list to the bottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    try {
      // Call the notifier to send the message
      await ref.read(chatProvider.notifier).sendMessage(message);
      // Wait briefly then scroll to show the new message
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final isChatLoading = chatState.isLoading && chatState.messages.isEmpty;

    // Handle error display
    if (chatState.error != null) {
      // Display snackbar and clear the error state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ErrorHandler.showErrorSnackBar(context, chatState.error);
        ref.read(chatProvider.notifier).clearError();
      });
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Travel Assistant'),
      body: Column(
        children: [
          if (isChatLoading)
            const LinearProgressIndicator(), // Initial loading indicator
          Expanded(
            child: chatState.messages.isEmpty && !isChatLoading
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      return _buildMessageBubble(context, message);
                    },
                  ),
          ),
          if (chatState.isLoading && chatState.messages.isNotEmpty)
            _buildTypingIndicator(),
          _buildMessageInput(context, chatState.isLoading),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.travel_explore,
              size: 80,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Planning Your Trip',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything about destinations, budgets, or itineraries!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSuggestionChip('Best destinations for summer'),
                _buildSuggestionChip('Budget trip to Europe'),
                _buildSuggestionChip('Week in Tokyo'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          // User messages get the blue gradient
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                )
              : null,
          color: isUser
              ? null
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(color: isUser ? Colors.white : null),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isUser ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    // Simple animated dots to show the AI is responding
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    // Uses TweenAnimationBuilder for a simple bouncing/fading effect
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          // Calculates opacity based on index offset for sequential fading
          opacity: (value + index * 0.3) % 1.0,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(BuildContext context, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ask about your travel plans...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => isLoading ? null : _sendMessage(),
                enabled: !isLoading,
              ),
            ),
            const SizedBox(width: 8),
            // Send button is disabled when loading
            IconButton.filled(
              onPressed: isLoading ? null : _sendMessage,
              icon: const Icon(Icons.send),
              iconSize: 24,
            ),
          ],
        ),
      ),
    );
  }
}
