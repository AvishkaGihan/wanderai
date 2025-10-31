import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Travel preferences
  String _budgetPreference = 'moderate';
  List<String> _interests = [];
  String _travelStyle = 'balanced';
  bool _notificationsForDeals = true;

  final List<String> _availableInterests = [
    'Adventure',
    'Culture',
    'Food',
    'Nature',
    'History',
    'Shopping',
    'Relaxation',
    'Nightlife',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider).value;
    if (user != null && user.preferences != null) {
      _loadPreferences(user.preferences!);
    }
  }

  void _loadPreferences(Map<String, dynamic> preferences) {
    setState(() {
      _budgetPreference = preferences['budget_preference'] ?? 'moderate';
      _interests = List<String>.from(preferences['interests'] ?? []);
      _travelStyle = preferences['travel_style'] ?? 'balanced';
      _notificationsForDeals = preferences['notifications_for_deals'] ?? true;
    });
  }

  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(userProfileProvider).value;
      if (user == null) return;

      final updatedPreferences = {
        ...?user.preferences,
        'budget_preference': _budgetPreference,
        'interests': _interests,
        'travel_style': _travelStyle,
        'notifications_for_deals': _notificationsForDeals,
      };

      final authService = ref.read(authServiceProvider);
      await authService.updateProfile(preferences: updatedPreferences);

      // Refresh user profile
      ref.invalidate(userProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving preferences: $e')));
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
        title: 'Travel Preferences',
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePreferences,
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
        data: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Budget Preference'),
                DropdownButtonFormField<String>(
                  initialValue: _budgetPreference,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'budget',
                      child: Text('Budget Friendly'),
                    ),
                    DropdownMenuItem(
                      value: 'moderate',
                      child: Text('Moderate'),
                    ),
                    DropdownMenuItem(value: 'luxury', child: Text('Luxury')),
                  ],
                  onChanged: (value) {
                    setState(() => _budgetPreference = value!);
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Travel Interests'),
                Wrap(
                  spacing: 8,
                  children: _availableInterests.map((interest) {
                    final isSelected = _interests.contains(interest);
                    return FilterChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _interests.add(interest);
                          } else {
                            _interests.remove(interest);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Travel Style'),
                DropdownButtonFormField<String>(
                  initialValue: _travelStyle,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'relaxed',
                      child: Text('Relaxed & Leisurely'),
                    ),
                    DropdownMenuItem(
                      value: 'balanced',
                      child: Text('Balanced Pace'),
                    ),
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('Active & Adventurous'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _travelStyle = value!);
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Notifications'),
                SwitchListTile(
                  title: const Text('Deal Notifications'),
                  subtitle: const Text(
                    'Get notified about travel deals and offers',
                  ),
                  value: _notificationsForDeals,
                  onChanged: (value) {
                    setState(() => _notificationsForDeals = value);
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _savePreferences,
                    child: _isLoading
                        ? const LoadingIndicator(message: 'Saving...')
                        : const Text('Save Preferences'),
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () =>
            const LoadingIndicator(message: 'Loading preferences...'),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
