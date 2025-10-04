import 'package:flutter/material.dart';

class DateCard extends StatelessWidget {
  final int? day;
  final String label;
  final DateTime? date;
  final bool isActive;
  final IconData? icon;
  final bool isEnabled;

  const DateCard({
    super.key,
    required this.day,
    required this.label,
    required this.date,
    required this.isActive,
    this.icon,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseOpacity = isEnabled ? 1.0 : 0.5;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Opacity(
        opacity: baseOpacity,
        child: SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: icon != null
                    ? Icon(icon, size: 32)
                    : Text(
                        day != null ? day.toString() : '--',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: date == null
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.7,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 24,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _formatDate(date!),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 24,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Formats date as dd/MM/yyyy
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
