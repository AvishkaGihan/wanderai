import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/trip_provider.dart';
import '../../utils/error_handler.dart';
import '../../utils/validators.dart';
import '../../utils/date_formatter.dart'; // Needed for displaying dates

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  // --- Date Picker Logic ---

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 2),
      ), // Two years out
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      // End date must start on or after the start date
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  // --- Create Trip Logic ---

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation for date range
    final dateError = Validators.dateRange(_startDate, _endDate);
    if (dateError != null) {
      ErrorHandler.showErrorSnackBar(context, dateError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call the Riverpod Notifier to execute the API call
      final trip = await ref
          .read(tripActionsProvider.notifier)
          .createTrip(
            title: _titleController.text.trim(),
            destination: _destinationController.text.trim(),
            startDate: _startDate,
            endDate: _endDate,
            budget: double.tryParse(_budgetController.text),
          );

      if (mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'Trip created successfully!');
        // Navigate to the newly created trip's detail screen
        context.go('/trips/${trip.id}');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Trip'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.pop(), // Go back to the previous screen (Trip List)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Trip Title',
                  hintText: 'e.g., Summer in Europe',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) =>
                    Validators.required(value, fieldName: 'Title'),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  hintText: 'e.g., Paris, France',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) =>
                    Validators.required(value, fieldName: 'Destination'),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              // Start Date Picker Field
              InkWell(
                onTap: _isLoading ? null : _selectStartDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _startDate != null
                        ? DateFormatter.formatDate(_startDate!)
                        : 'Select start date',
                    style: _startDate == null
                        ? TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // End Date Picker Field
              InkWell(
                onTap: _isLoading ? null : _selectEndDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _endDate != null
                        ? DateFormatter.formatDate(_endDate!)
                        : 'Select end date',
                    style: _endDate == null
                        ? TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget (USD)',
                  hintText: 'e.g., 2000',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: Validators.positiveNumber,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 32),
              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _createTrip,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create Trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
