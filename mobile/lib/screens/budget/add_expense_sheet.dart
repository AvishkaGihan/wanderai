import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/expense_provider.dart';
import '../../utils/validators.dart';
import '../../utils/error_handler.dart';
import '../../utils/date_formatter.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  final String tripId;

  const AddExpenseSheet({super.key, required this.tripId});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Standard expense categories
  final _categories = [
    'Food',
    'Transport',
    'Accommodation',
    'Activities',
    'Shopping',
    'Other',
  ];
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Function to show the date picker
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    final notifier = ref.read(expenseActionsProvider.notifier);

    // Set loading state by watching the notifier's AsyncValue
    final isLoading = ref.watch(expenseActionsProvider).isLoading;
    if (isLoading) return;

    try {
      await notifier.addExpense(
        tripId: widget.tripId,
        category: _selectedCategory,
        amount: amount,
        date: _selectedDate,
        description: _descriptionController.text.trim(),
      );
      if (mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Expense added successfully!',
        );
        Navigator.pop(context); // Close the bottom sheet on success
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the loading state from the actions provider
    final isLoading = ref.watch(expenseActionsProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(
        // Adjust padding for keyboard visibility
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Expense',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                        setState(() => _selectedCategory = value!);
                      },
                validator: Validators.required,
                isExpanded: true,
              ),
              const SizedBox(height: 16),
              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: Validators.positiveNumber,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              // Description Input
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.note),
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              // Date Picker Field (InkWell makes the InputDecorator clickable)
              InkWell(
                onTap: isLoading ? null : _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormatter.formatDate(_selectedDate)),
                ),
              ),
              const SizedBox(height: 24),
              // Submit Button
              ElevatedButton(
                onPressed: isLoading ? null : _addExpense,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
