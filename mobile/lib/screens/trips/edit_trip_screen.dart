import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/trip_provider.dart';
import '../../utils/error_handler.dart';
import '../../utils/validators.dart';
import '../../utils/date_formatter.dart';
import '../../models/trip.dart';

class EditTripScreen extends ConsumerStatefulWidget {
  final Trip trip;

  const EditTripScreen({super.key, required this.trip});

  @override
  ConsumerState<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends ConsumerState<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _destinationController;
  late final TextEditingController _budgetController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.trip.title);
    _destinationController = TextEditingController(
      text: widget.trip.destination ?? '',
    );
    _budgetController = TextEditingController(
      text: widget.trip.budget?.toString() ?? '',
    );
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _updateTrip() async {
    if (!_formKey.currentState!.validate()) return;

    final dateError = Validators.dateRange(_startDate, _endDate);
    if (dateError != null) {
      ErrorHandler.showErrorSnackBar(context, dateError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'title': _titleController.text.trim(),
        'destination': _destinationController.text.trim().isEmpty
            ? null
            : _destinationController.text.trim(),
        'start_date': _startDate?.toIso8601String(),
        'end_date': _endDate?.toIso8601String(),
        'budget': double.tryParse(_budgetController.text),
      };

      await ref
          .read(tripActionsProvider.notifier)
          .updateTrip(widget.trip.id, data);

      if (mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'Trip updated successfully!');
        context.pop(); // Go back to detail screen
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
        title: const Text('Edit Trip'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
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
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
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
              ElevatedButton(
                onPressed: _isLoading ? null : _updateTrip,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Update Trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
