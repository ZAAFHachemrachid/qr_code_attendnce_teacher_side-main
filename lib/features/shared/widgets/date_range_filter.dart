import 'package:flutter/material.dart';

class DateRangeFilter extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onDateRangeChanged;

  const DateRangeFilter({
    super.key,
    this.startDate,
    this.endDate,
    required this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row with title and clear button
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filter by Date',
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                if (startDate != null || endDate != null)
                  TextButton(
                    onPressed: () => onDateRangeChanged(null, null),
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Date selectors row
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildDateSelector(
                      context,
                      label: 'Start Date',
                      value: startDate,
                      onSelect: (date) => onDateRangeChanged(date, endDate),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateSelector(
                      context,
                      label: 'End Date',
                      value: endDate,
                      onSelect: (date) => onDateRangeChanged(startDate, date),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required Function(DateTime?) onSelect,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onSelect(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value != null
                  ? '${value.day}/${value.month}/${value.year}'
                  : 'Select Date',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
