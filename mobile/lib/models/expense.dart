import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Expense {
  final String id;
  final String tripId;
  final String category;
  final double amount;
  final String currency;
  final DateTime date;
  final String? description;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.tripId,
    required this.category,
    required this.amount,
    required this.currency,
    required this.date,
    this.description,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExpenseSummary {
  final String tripId;
  final double budget;
  final double totalSpent;
  final double remaining;
  final double percentageUsed;
  final Map<String, double> byCategory;

  ExpenseSummary({
    required this.tripId,
    required this.budget,
    required this.totalSpent,
    required this.remaining,
    required this.percentageUsed,
    required this.byCategory,
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) =>
      _$ExpenseSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseSummaryToJson(this);

  bool get isOverBudget => totalSpent > budget;
  bool get isNearBudget => percentageUsed >= 75 && percentageUsed < 100;
  bool get isWithinBudget => percentageUsed < 75;
}
