import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/destination.dart';
import '../../utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';

class DestinationDetailScreen extends ConsumerStatefulWidget {
  final Destination destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  ConsumerState<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState
    extends ConsumerState<DestinationDetailScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  void _checkIfSaved() {
    final user = ref.read(userProfileProvider).value;
    if (user != null && user.preferences != null) {
      final savedIds =
          user.preferences?['saved_destinations'] as List<dynamic>? ?? [];
      setState(() {
        _isSaved = savedIds.contains(widget.destination.id);
      });
    }
  }

  Future<void> _toggleSaved() async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) return;

    final savedIds =
        user.preferences?['saved_destinations'] as List<dynamic>? ?? [];
    List<dynamic> updatedIds;

    if (_isSaved) {
      updatedIds = savedIds
          .where((id) => id.toString() != widget.destination.id)
          .toList();
    } else {
      updatedIds = [...savedIds, widget.destination.id];
    }

    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateProfile(
        preferences: {...?user.preferences, 'saved_destinations': updatedIds},
      );

      // Refresh user profile
      ref.invalidate(userProfileProvider);

      setState(() => _isSaved = !_isSaved);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isSaved
                  ? 'Destination saved!'
                  : 'Destination removed from saved',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating saved destinations: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.favorite : Icons.favorite_border,
                  color: _isSaved ? Colors.red : Colors.white,
                ),
                onPressed: _toggleSaved,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.destination.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        widget.destination.imageUrl ??
                        'https://source.unsplash.com/800x600/?${widget.destination.name}',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country
                  if (widget.destination.country != null) ...[
                    Text(
                      widget.destination.country!,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Budget
                  if (widget.destination.budget != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          '${CurrencyFormatter.format(widget.destination.budget!)}/day',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  if (widget.destination.description != null) ...[
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.destination.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Attractions
                  if (widget.destination.attractions.isNotEmpty) ...[
                    Text(
                      'Top Attractions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.destination.attractions.map(
                      (attraction) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.place,
                              size: 20,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                attraction,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
