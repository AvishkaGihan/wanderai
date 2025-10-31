import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/error_handler.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: userProfileAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user.displayName?.substring(0, 1).toUpperCase() ??
                        user.email.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.displayName ?? 'Traveler',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 32),
                _buildMenuSection(context),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () => _signOut(context, ref),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading profile...'),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/profile/edit');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Saved Destinations'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/destinations/saved');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Trip History'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/trips');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/profile/preferences');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/help');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authServiceProvider).signOut();
        if (context.mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (context.mounted) {
          ErrorHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }
}
