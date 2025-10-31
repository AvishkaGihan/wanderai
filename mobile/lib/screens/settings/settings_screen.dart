import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../widgets/custom_app_bar.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _language = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark themes'),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(_language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
          const Divider(),
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text(
              'Receive notifications about trips and updates',
            ),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveSetting('notifications_enabled', value);
            },
          ),
          const Divider(),
          _buildSectionHeader('About'),
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () async {
              final url = Uri.parse(AppConfig.privacyPolicyUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open privacy policy'),
                  ),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () async {
              final url = Uri.parse(AppConfig.termsOfServiceUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open terms of service'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: Icon(
                _language == 'English'
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: _language == 'English'
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onTap: () {
                setState(() => _language = 'English');
                _saveSetting('language', 'English');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Spanish'),
              leading: Icon(
                _language == 'Spanish'
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: _language == 'Spanish'
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onTap: () {
                setState(() => _language = 'Spanish');
                _saveSetting('language', 'Spanish');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
