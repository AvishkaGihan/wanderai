import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../utils/error_handler.dart';
import '../../widgets/empty_state.dart';

class ExpensesList extends ConsumerWidget {
  // Note: The type is List<dynamic> as it comes from a list of data
  final List expenses;
  final String tripId;

  const ExpensesList({super.key, required this.expenses, required this.tripId});

  // Get the icon for the category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_bus;
      case 'accommodation':
        return Icons.hotel;
      case 'activities':
        return Icons.local_activity;
      default:
        return Icons.shopping_bag; // Default for 'Shopping', 'Other'
    }
  }

  // Handle expense deletion
  Future<void> _deleteExpense(
    BuildContext context,
    WidgetRef ref,
    String expenseId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text(
          'Are you sure you want to delete this expense? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(expenseActionsProvider.notifier)
            .deleteExpense(tripId, expenseId);
        if (context.mounted) {
          ErrorHandler.showSuccessSnackBar(context, 'Expense deleted.');
        }
      } catch (e) {
        if (context.mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            'Failed to delete expense: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (expenses.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long,
        title: 'No Expenses Logged',
        message: 'Tap the "+" button to add your first expense.',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        // Cast the item to the Expense model
        final expense = expenses[index] as Expense;

        return Dismissible(
          key: Key(expense.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) =>
              _deleteExpense(context, ref, expense.id), // Call delete function
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(
                  _getCategoryIcon(expense.category),
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              title: Text(
                expense.category,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (expense.description != null &&
                      expense.description!.isNotEmpty)
                    Text(
                      expense.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  Text(
                    DateFormatter.formatDate(expense.date),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              trailing: Text(
                CurrencyFormatter.format(expense.amount),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
