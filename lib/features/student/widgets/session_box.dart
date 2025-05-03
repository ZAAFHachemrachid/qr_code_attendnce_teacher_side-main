import 'package:flutter/material.dart';

class SessionBox extends StatelessWidget {
  final bool isAttended;
  final DateTime sessionDate;
  final String sessionType;

  const SessionBox({
    super.key,
    required this.isAttended,
    required this.sessionDate,
    required this.sessionType,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          '${sessionType} - ${_formatDate(sessionDate)}\n${isAttended ? 'Attended' : 'Missed'}',
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isAttended ? Colors.green.shade100 : Colors.red.shade100,
          border: Border.all(
            color: isAttended ? Colors.green : Colors.red,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class SessionLegend extends StatelessWidget {
  const SessionLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendItem(context, true, 'Attended'),
        const SizedBox(width: 16),
        _buildLegendItem(context, false, 'Missed'),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, bool isAttended, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isAttended ? Colors.green.shade100 : Colors.red.shade100,
            border: Border.all(
              color: isAttended ? Colors.green : Colors.red,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
