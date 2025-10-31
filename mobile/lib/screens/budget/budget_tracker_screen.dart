import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/error_handler.dart';
import '../../models/expense.dart';
import 'add_expense_sheet.dart'; // Import the bottom sheet
import 'expenses_list.dart'; // Import the list widget

class BudgetTrackerScreen extends ConsumerWidget {
  final String tripId;

  const BudgetTrackerScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch both the summary and the detailed list of expenses
    final summaryAsync = ref.watch(expenseSummaryProvider(tripId));
    final expensesAsync = ref.watch(expensesProvider(tripId));

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Tracker')),
      body: summaryAsync.when(
        data: (summary) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BudgetProgressCard(summary: summary),
              const SizedBox(height: 24),
              // Only show the chart if there is money spent
              if (summary.totalSpent > 0) ...[
                _CategoryBreakdownChart(summary: summary),
                const SizedBox(height: 24),
              ],
              Text(
                'Recent Expenses',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              // Display the list of expenses (handles its own loading state)
              expensesAsync.when(
                data: (expenses) =>
                    ExpensesList(expenses: expenses, tripId: tripId),
                loading: () => const LoadingIndicator(size: 50),
                error: (_, e) => Text(
                  'Error loading expenses: ${ErrorHandler.getErrorMessage(e)}',
                ),
              ),
            ],
          ),
        ),
        loading: () => const LoadingIndicator(message: 'Loading budget...'),
        error: (error, stack) => Center(
          child: Text('Error: ${ErrorHandler.getErrorMessage(error)}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddExpenseSheet(tripId: tripId),
    );
  }
}

// ============================================================================
// Budget Progress Card
// ============================================================================

class _BudgetProgressCard extends StatelessWidget {
  final ExpenseSummary summary;

  const _BudgetProgressCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final percentage = summary.percentageUsed.clamp(0.0, 100.0);
    Color progressColor;

    if (summary.isOverBudget) {
      progressColor = Colors.red;
    } else if (summary.isNearBudget) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(progressColor),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: progressColor,
                              ),
                        ),
                        Text(
                          'Used',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  context,
                  'Budget',
                  CurrencyFormatter.format(summary.budget),
                ),
                _buildStat(
                  context,
                  'Spent',
                  CurrencyFormatter.format(summary.totalSpent),
                ),
                _buildStat(
                  context,
                  'Remaining',
                  CurrencyFormatter.format(summary.remaining),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ============================================================================
// Category Breakdown Chart
// ============================================================================

class _CategoryBreakdownChart extends StatelessWidget {
  final ExpenseSummary summary;

  const _CategoryBreakdownChart({required this.summary});

  // Color pallet for pie chart sections
  static const List<Color> _chartColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    // Note: categories is Map<String, double>
    final categories = summary.byCategory;

    if (categories.isEmpty || summary.totalSpent == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(categories),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend list
            ..._buildLegend(context, categories),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> categories,
  ) {
    return categories.entries.map((entry) {
      final index = categories.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        value: entry.value,
        title: '',
        color: _chartColors[index % _chartColors.length],
        radius: 60,
      );
    }).toList();
  }

  List<Widget> _buildLegend(
    BuildContext context,
    Map<String, double> categories,
  ) {
    final totalSpent = categories.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    return categories.entries.map((entry) {
      final index = categories.keys.toList().indexOf(entry.key);
      final percentage = (entry.value / totalSpent) * 100;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Color indicator dot
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _chartColors[index % _chartColors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // Category Label
            Expanded(
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            // Amount and Percentage
            Text(
              '${CurrencyFormatter.format(entry.value)} (${percentage.toStringAsFixed(0)}%)',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }).toList();
  }
}
