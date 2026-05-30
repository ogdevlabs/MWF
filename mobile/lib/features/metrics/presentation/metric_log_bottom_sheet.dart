import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/metric_providers.dart';

/// Bottom sheet for logging a single metric entry.
/// Per D-03: logs ONE metric type at a time; "Log another" resets form inline.
/// Per D-04: date defaults to today, editable via date picker.
///
/// Uses metricRepositoryProvider (canonical Plan-02 repository).
/// studentId is injected by the repository via Supabase auth.
class MetricLogBottomSheet extends ConsumerStatefulWidget {
  const MetricLogBottomSheet({super.key});

  @override
  ConsumerState<MetricLogBottomSheet> createState() =>
      _MetricLogBottomSheetState();
}

class _MetricLogBottomSheetState extends ConsumerState<MetricLogBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();

  // Metric type selector state
  String _selectedType = 'weight';
  String? _selectedSubtype;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  bool _showSuccess = false;

  // Metric type options per D-10, D-11, D-12
  static const _metricTypes = ['weight', 'measurement', 'flexibility'];
  static const _measurementSubtypes = ['waist', 'hip', 'chest', 'thigh', 'arm'];
  static const _flexibilitySubtypes = [
    'forward_bend',
    'shoulder',
    'hip_flexor',
  ];

  // Unit per type: kg for weight, cm for measurement, degrees for flexibility
  String get _unit => switch (_selectedType) {
        'weight' => 'kg',
        'measurement' => 'cm',
        'flexibility' => 'degrees',
        _ => 'kg',
      };

  List<String>? get _subtypes => switch (_selectedType) {
        'measurement' => _measurementSubtypes,
        'flexibility' => _flexibilitySubtypes,
        _ => null,
      };

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(metricRepositoryProvider);
      await repo.logMetric(
        metricType: _selectedType,
        metricSubtype: _selectedSubtype,
        value: double.parse(_valueController.text.trim()),
        unit: _unit,
        loggedAt: _selectedDate,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _showSuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// "Log another" — resets form inline (D-03, Pitfall 6 avoided).
  /// Does NOT pop and re-show the sheet.
  void _logAnother() {
    _formKey.currentState!.reset();
    _valueController.clear();
    setState(() {
      _selectedSubtype = null;
      _selectedDate = DateTime.now();
      _showSuccess = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}'
      '-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text('Log Metric', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),

          if (_showSuccess) ...[
            // Success state: "Log another" or "Done"
            Icon(
              Icons.check_circle_outline,
              color: theme.colorScheme.primary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Metric logged!',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _logAnother,
                  child: const Text('Log another'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ] else ...[
            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metric type selector (DropdownButtonFormField)
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Metric type',
                      border: OutlineInputBorder(),
                    ),
                    items: _metricTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              '${t[0].toUpperCase()}${t.substring(1)}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                          _selectedSubtype = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Optional subtype dropdown for measurement/flexibility
                  if (_subtypes != null) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSubtype,
                      decoration: const InputDecoration(
                        labelText: 'Subtype',
                        border: OutlineInputBorder(),
                      ),
                      items: _subtypes!
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                '${s[0].toUpperCase()}${s.substring(1).replaceAll('_', ' ')}',
                              ),
                            ),
                          )
                          .toList(),
                      validator: (_) => null,
                      onChanged: (value) =>
                          setState(() => _selectedSubtype = value),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Value input (TextFormField)
                  TextFormField(
                    controller: _valueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Value ($_unit)',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter a value';
                      }
                      final n = double.tryParse(v.trim());
                      if (n == null || n <= 0) {
                        return 'Enter a valid positive number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Date row — defaults today, editable
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(_selectedDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _pickDate,
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Log'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
