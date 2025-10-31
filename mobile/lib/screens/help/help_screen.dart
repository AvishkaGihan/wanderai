import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/custom_app_bar.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Help & Support'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Getting Started',
            content:
                'Welcome to WanderAI! Plan your perfect trip with our AI-powered travel assistant. '
                'Start by exploring destinations, creating trips, and getting personalized recommendations.',
          ),
          _buildSection(
            title: 'Planning a Trip',
            content:
                '1. Browse destinations in the Discover tab\n'
                '2. Save destinations you\'re interested in\n'
                '3. Create a new trip and add destinations\n'
                '4. Use the itinerary feature to plan your daily activities\n'
                '5. Track your budget with the budget tracker',
          ),
          _buildSection(
            title: 'Using AI Chat',
            content:
                'Chat with our AI assistant to get travel recommendations, '
                'ask questions about destinations, and get help planning your trip. '
                'The chat is available 24/7 to assist you.',
          ),
          _buildSection(
            title: 'Managing Your Profile',
            content:
                'Update your profile information, set your travel preferences, '
                'and view your saved destinations. Your preferences help us provide '
                'better recommendations tailored to your interests.',
          ),
          const Divider(),
          _buildContactSection(context),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              subtitle: const Text('support@wanderai.com'),
              onTap: () async {
                final Uri emailUri = Uri.parse('mailto:support@wanderai.com');
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.web),
              title: const Text('Website'),
              subtitle: const Text('www.wanderai.com'),
              onTap: () async {
                final Uri websiteUri = Uri.parse('https://www.wanderai.com');
                if (await canLaunchUrl(websiteUri)) {
                  await launchUrl(websiteUri);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () async {
                final Uri privacyUri = Uri.parse(
                  'https://www.wanderai.com/privacy-policy',
                );
                if (await canLaunchUrl(privacyUri)) {
                  await launchUrl(privacyUri);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
