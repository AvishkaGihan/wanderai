import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/destination_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/currency_formatter.dart';
import '../../models/destination.dart';
import 'destination_detail_screen.dart';

class DestinationSearchScreen extends ConsumerStatefulWidget {
  const DestinationSearchScreen({super.key});

  @override
  ConsumerState<DestinationSearchScreen> createState() =>
      _DestinationSearchScreenState();
}

class _DestinationSearchScreenState
    extends ConsumerState<DestinationSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinationsAsync = ref.watch(destinationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search destinations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(destinationSearchQueryProvider.notifier)
                              .updateQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref
                    .read(destinationSearchQueryProvider.notifier)
                    .updateQuery(value);
              },
            ),
          ),
          Expanded(
            child: destinationsAsync.when(
              data: (destinations) {
                if (destinations.isEmpty) {
                  return const Center(child: Text('No destinations found'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    final destination = destinations[index];
                    return _DestinationCard(destination: destination);
                  },
                );
              },
              loading: () => const LoadingIndicator(message: 'Searching...'),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final Destination destination;

  const _DestinationCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DestinationDetailScreen(destination: destination),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        destination.imageUrl ??
                        'https://source.unsplash.com/400x300/?${destination.name}',
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[300]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (destination.country != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      destination.country!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (destination.budget != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${CurrencyFormatter.format(destination.budget!)}/day',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
