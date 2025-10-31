import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/error_handler.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider).value;
    if (user != null) {
      _displayNameController.text = user.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateProfile(
        displayName: _displayNameController.text.trim(),
      );

      // Refresh user profile
      ref.invalidate(userProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Profile',
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
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
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'Enter your display name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Display name is required';
                      }
                      if (value.length > 50) {
                        return 'Display name must be less than 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: user.email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false, // Email cannot be changed
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      child: _isLoading
                          ? const LoadingIndicator(message: 'Saving...')
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading profile...'),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
