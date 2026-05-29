import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/metrics_repository.dart';

/// Modal bottom sheet for logging a body metric entry (FR-008).
///
/// Fields:
/// - Metric type selector (Weight / Measurements / Flexibility)
/// - Optional subtype chips (waist / hip / shoulder) for measurements
/// - Numeric value input
/// - Unit auto-set by type: kg | cm | degrees
/// - Date picker (defaults to today)
/// - Save button (offline-safe: writes to Drift + CommandBus)
class LogMetricSheet extends ConsumerStatefulWidget {
  const LogMetricSheet({
    super.key,
    required this.studentId,
  });

  final String studentId;

  @override
  ConsumerState<LogMetricSheet> createState() => _LogMetricSheetState();
}

class _LogMetricSheetState extends ConsumerState<LogMetricSheet> {
  String _metricType = 'weight';
  String? _metricSubtype;
  final _valueController = TextEditingController();
  DateTime _loggedAt = DateTime.now();
  bool _saving = false;
  String? _errorText;

  static const _subtypes = ['waist', 'hip', 'shoulder'];

  String get _unit => switch (_metricType) {
        'weight' => 'kg',
        'measurement' => 'cm',
        'flexibility' => 'degrees',
        _ => 'kg',
      };

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _loggedAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _loggedAt = picked);
    }
  }

  Future<void> _save() async {
    final raw = _valueController.text.trim();
    final value = double.tryParse(raw);
    if (value == null || value <= 0) {
      setState(() => _errorText = 'Enter a valid positive number');
      return;
    }
    if (_metricType == 'measurement' && _metricSubtype == null) {
      setState(() => _errorText = 'Select a measurement subtype');
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await ref.read(metricsRepositoryProvider).logMetric(
            studentId: widget.studentId,
            metricType: _metricType,
            metricSubtype: _metricType == 'measurement' ? _metricSubtype : null,
            value: value,
            unit: _unit,
            loggedAt: _loggedAt,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _errorText = 'Failed to save. Please try again.';
        });
      }
    }
  }

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Log Today\'s Metrics',
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Metric type selector
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'weight', label: Text('Weight')),
              ButtonSegment(value: 'measurement', label: Text('Measurement')),
              ButtonSegment(value: 'flexibility', label: Text('Flexibility')),
            ],
            selected: {_metricType},
            onSelectionChanged: (set) => setState(() {
              _metricType = set.first;
              _metricSubtype = null;
            }),
          ),
          const SizedBox(height: 16),

          // Subtype chips — only for measurement
          if (_metricType == 'measurement') ...[
            Wrap(
              spacing: 8,
              children: _subtypes.map((sub) {
                final selected = _metricSubtype == sub;
                return FilterChip(
                  label: Text(
                      '${sub[0].toUpperCase()}${sub.substring(1)}'),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _metricSubtype = selected ? null : sub),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Value input + unit
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _valueController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Value',
                    errorText: _errorText,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 72,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _unit,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date picker row
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(_loggedAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
