import '../models/expense.dart';
import 'api_service.dart';

class ExpenseService {
  final ApiService _apiService = ApiService();

  // Get trip expenses
  Future<List<Expense>> getExpenses(String tripId) async {
    try {
      // Corrected the endpoint prefix based on backend router setup
      final response = await _apiService.dio.get('/expenses/$tripId/expenses');
      return (response.data as List)
          .map((json) => Expense.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Add expense
  Future<Expense> addExpense({
    required String tripId,
    required String category,
    required double amount,
    required DateTime date,
    String currency = 'USD',
    String? description,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/expenses/$tripId/expenses',
        data: {
          'category': category,
          'amount': amount,
          'currency': currency,
          // Convert DateTime to ISO string (date only) for backend
          'date': date.toIso8601String().substring(0, 10),
          if (description != null) 'description': description,
        },
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Delete expense
  Future<void> deleteExpense(String tripId, String expenseId) async {
    try {
      await _apiService.dio.delete('/expenses/$tripId/expenses/$expenseId');
    } catch (e) {
      rethrow;
    }
  }

  // Get expense summary
  Future<ExpenseSummary> getExpenseSummary(String tripId) async {
    try {
      final response = await _apiService.dio.get(
        '/expenses/$tripId/expenses/summary',
      );
      return ExpenseSummary.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
