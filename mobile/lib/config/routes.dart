import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/trips/trip_list_screen.dart';
import '../screens/trips/trip_detail_screen.dart';
import '../screens/trips/create_trip_screen.dart';
import '../screens/trips/edit_trip_screen.dart';
import '../models/trip.dart';
import '../screens/itinerary/itinerary_screen.dart';
import '../screens/budget/budget_tracker_screen.dart';
import '../screens/destinations/destination_search_screen.dart';
import '../screens/destinations/destination_detail_screen.dart';
import '../models/destination.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/destinations/saved_destinations_screen.dart';
import '../screens/profile/preferences_screen.dart';
import '../screens/help/help_screen.dart';
import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    // The redirect logic is the core of authentication routing
    redirect: (context, state) {
      // Handle authentication state properly with AsyncValue
      final isLoggedIn = authState.maybeWhen(
        data: (user) =>
            user != null, // User is logged in if we have data and it's not null
        orElse: () =>
            false, // During loading/error, assume not logged in to prevent premature redirects
      );

      final isLoading = authState.isLoading;
      final isGoingToAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      // If we are still on the splash screen, let it load
      if (state.matchedLocation == '/splash') {
        return null;
      }

      // If auth state is still loading, stay on current screen (don't redirect)
      if (isLoading) {
        return null;
      }

      // If not logged in and going to a protected route, redirect to login
      if (!isLoggedIn && !isGoingToAuth) {
        return '/login';
      }

      // If logged in and going to a login/signup route, redirect to home
      if (isLoggedIn && isGoingToAuth) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      GoRoute(
        path: '/trips',
        builder: (context, state) => const TripListScreen(),
      ),
      GoRoute(
        path: '/trips/create',
        builder: (context, state) => const CreateTripScreen(),
      ),
      GoRoute(
        path: '/trips/:id',
        builder: (context, state) {
          final tripId = state.pathParameters['id']!;
          return TripDetailScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/trips/:id/edit',
        builder: (context, state) {
          final trip = state.extra as Trip;
          return EditTripScreen(trip: trip);
        },
      ),
      GoRoute(
        path: '/trips/:id/itinerary',
        builder: (context, state) {
          final tripId = state.pathParameters['id']!;
          return ItineraryScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/trips/:id/budget',
        builder: (context, state) {
          final tripId = state.pathParameters['id']!;
          return BudgetTrackerScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/destinations',
        builder: (context, state) => const DestinationSearchScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/destinations/saved',
        builder: (context, state) => const SavedDestinationsScreen(),
      ),
      GoRoute(
        path: '/destinations/:id',
        builder: (context, state) {
          final destination = state.extra as Destination;
          return DestinationDetailScreen(destination: destination);
        },
      ),
      GoRoute(
        path: '/profile/preferences',
        builder: (context, state) => const PreferencesScreen(),
      ),
      GoRoute(path: '/help', builder: (context, state) => const HelpScreen()),
    ],
  );
});
