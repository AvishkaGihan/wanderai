import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chat/chat_screen.dart';
import '../trips/trip_list_screen.dart';
import '../destinations/destination_search_screen.dart';
import '../profile/profile_screen.dart';

// Riverpod NotifierProvider to manage the selected tab index
class SelectedIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final selectedIndexProvider = NotifierProvider<SelectedIndexNotifier, int>(
  SelectedIndexNotifier.new,
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    // List of the main screens shown in the IndexedStack
    final screens = [
      const ChatScreen(),
      const TripListScreen(),
      const DestinationSearchScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // IndexedStack preserves the state of the tabs when switching
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          // Update the state provider when a new tab is selected
          ref.read(selectedIndexProvider.notifier).setIndex(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
