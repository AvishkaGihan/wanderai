import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

// Expense service provider
final expenseServiceProvider = Provider((ref) => ExpenseService());

// Trip expenses provider (fetches list of expenses for a specific tripId)
final expensesProvider = FutureProvider.family<List<Expense>, String>((
  ref,
  tripId,
) async {
  final service = ref.watch(expenseServiceProvider);
  return await service.getExpenses(tripId);
});

// Expense summary provider (fetches total spent, budget status, etc.)
final expenseSummaryProvider = FutureProvider.family<ExpenseSummary, String>((
  ref,
  tripId,
) async {
  final service = ref.watch(expenseServiceProvider);
  return await service.getExpenseSummary(tripId);
});

// Expense actions notifier (for C.R.U.D. operations and refreshing data)
class ExpenseActionsNotifier extends Notifier<AsyncValue<void>> {
  late final ExpenseService _expenseService;

  @override
  AsyncValue<void> build() {
    _expenseService = ref.watch(expenseServiceProvider);
    return const AsyncValue.data(null);
  }

  Future<void> addExpense({
    required String tripId,
    required String category,
    required double amount,
    required DateTime date,
    String currency = 'USD',
    String? description,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _expenseService.addExpense(
        tripId: tripId,
        category: category,
        amount: amount,
        date: date,
        currency: currency,
        description: description,
      );
      state = const AsyncValue.data(null);
      // Invalidate the relevant data providers to force UI refresh
      ref.invalidate(expensesProvider(tripId));
      ref.invalidate(expenseSummaryProvider(tripId));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteExpense(String tripId, String expenseId) async {
    state = const AsyncValue.loading();
    try {
      await _expenseService.deleteExpense(tripId, expenseId);
      state = const AsyncValue.data(null);
      // Invalidate providers
      ref.invalidate(expensesProvider(tripId));
      ref.invalidate(expenseSummaryProvider(tripId));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final expenseActionsProvider =
    NotifierProvider<ExpenseActionsNotifier, AsyncValue<void>>(
      () => ExpenseActionsNotifier(),
    );
