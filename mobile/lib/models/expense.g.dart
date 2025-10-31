// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: json['id'] as String,
  tripId: json['trip_id'] as String,
  category: json['category'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  date: DateTime.parse(json['date'] as String),
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'trip_id': instance.tripId,
  'category': instance.category,
  'amount': instance.amount,
  'currency': instance.currency,
  'date': instance.date.toIso8601String(),
  'description': instance.description,
  'created_at': instance.createdAt.toIso8601String(),
};

ExpenseSummary _$ExpenseSummaryFromJson(Map<String, dynamic> json) =>
    ExpenseSummary(
      tripId: json['trip_id'] as String,
      budget: (json['budget'] as num).toDouble(),
      totalSpent: (json['total_spent'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      percentageUsed: (json['percentage_used'] as num).toDouble(),
      byCategory: (json['by_category'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$ExpenseSummaryToJson(ExpenseSummary instance) =>
    <String, dynamic>{
      'trip_id': instance.tripId,
      'budget': instance.budget,
      'total_spent': instance.totalSpent,
      'remaining': instance.remaining,
      'percentage_used': instance.percentageUsed,
      'by_category': instance.byCategory,
    };
