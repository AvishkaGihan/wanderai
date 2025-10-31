import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../utils/date_formatter.dart';

class ChatSessionSelectionDialog extends ConsumerWidget {
  final Function(String) onSessionSelected;

  const ChatSessionSelectionDialog({
    super.key,
    required this.onSessionSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatSessionsAsync = ref.watch(chatSessionsProvider);

    return AlertDialog(
      title: const Text('Select Chat Session'),
      content: SizedBox(
        width: double.maxFinite,
        child: chatSessionsAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) {
              return const Center(
                child: Text(
                  'No chat sessions found. Start a conversation first.',
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final sessionId = session['session_id'] as String;
                final lastActivity = DateTime.parse(session['last_activity']);

                return ListTile(
                  leading: const Icon(Icons.chat),
                  title: Text('Chat Session ${index + 1}'),
                  subtitle: Text(
                    'Last activity: ${DateFormatter.formatRelative(lastActivity)}',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSessionSelected(sessionId);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Error loading chat sessions: $error')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
