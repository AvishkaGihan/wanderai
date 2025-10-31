import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/activity_provider.dart';

class ActivityEditDialog extends ConsumerStatefulWidget {
  final String tripId;
  final Map<String, dynamic>?
  activity; // null for create, existing activity for edit
  final String dayId;

  const ActivityEditDialog({
    super.key,
    required this.tripId,
    this.activity,
    required this.dayId,
  });

  @override
  ConsumerState<ActivityEditDialog> createState() => _ActivityEditDialogState();
}

class _ActivityEditDialogState extends ConsumerState<ActivityEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _timeController;
  late final TextEditingController _durationController;
  late final TextEditingController _costController;
  late final TextEditingController _locationController;
  String? _selectedCategory;

  final List<String> _categories = [
    'sightseeing',
    'food',
    'transport',
    'accommodation',
    'shopping',
    'entertainment',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.activity?['title'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.activity?['description'] ?? '',
    );
    _timeController = TextEditingController(
      text: widget.activity?['time'] ?? '',
    );
    _durationController = TextEditingController(
      text: widget.activity?['duration']?.toString() ?? '',
    );
    _costController = TextEditingController(
      text: widget.activity?['cost']?.toString() ?? '',
    );
    _locationController = TextEditingController(
      text: widget.activity?['location'] ?? '',
    );
    _selectedCategory = widget.activity?['category'] ?? 'sightseeing';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _costController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final activityActions = ref.read(activityActionsProvider.notifier);

      if (widget.activity == null) {
        // Create new activity
        await activityActions.createActivity(
          tripId: widget.tripId,
          dayId: widget.dayId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          time: _timeController.text.isNotEmpty
              ? _timeController.text.trim()
              : null,
          duration: _durationController.text.isNotEmpty
              ? int.parse(_durationController.text)
              : null,
          cost: _costController.text.isNotEmpty
              ? double.parse(_costController.text)
              : null,
          category: _selectedCategory,
          location: _locationController.text.isNotEmpty
              ? _locationController.text.trim()
              : null,
        );
      } else {
        // Update existing activity
        await activityActions.updateActivity(
          tripId: widget.tripId,
          activityId: widget.activity!['id'],
          title: _titleController.text.trim(),
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          time: _timeController.text.isNotEmpty
              ? _timeController.text.trim()
              : null,
          duration: _durationController.text.isNotEmpty
              ? int.parse(_durationController.text)
              : null,
          cost: _costController.text.isNotEmpty
              ? double.parse(_costController.text)
              : null,
          category: _selectedCategory,
          location: _locationController.text.isNotEmpty
              ? _locationController.text.trim()
              : null,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.activity == null
                  ? 'Activity created successfully!'
                  : 'Activity updated successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save activity: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(activityActionsProvider).isLoading;

    return AlertDialog(
      title: Text(
        widget.activity == null ? 'Create Activity' : 'Edit Activity',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Activity title',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Activity description (optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category[0].toUpperCase() + category.substring(1),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  hintText: 'HH:MM (optional)',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  hintText: 'Duration in minutes (optional)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Cost',
                  hintText: 'Cost in your currency (optional)',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Location or address (optional)',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _saveActivity,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.activity == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}
