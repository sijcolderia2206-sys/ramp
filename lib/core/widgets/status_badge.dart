import 'package:flutter/material.dart';
import '../theme/ramp_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  factory StatusBadge.fromStatusString(String statusStr) {
    return StatusBadge(status: statusStr);
  }

  @override
  Widget build(BuildContext context) {
    return StatusPill(status: status);
  }
}
