import 'package:flutter/material.dart';

import '../services/persistence_queue.dart';
import '../theme/ramp_theme.dart';

class OfflineSyncBanner extends StatelessWidget {
  const OfflineSyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PersistenceQueueState>(
      valueListenable: PersistenceQueue.instance,
      builder: (context, writes, _) {
        if (writes.pending.isEmpty && !writes.isSyncing) {
          return const SizedBox.shrink();
        }
        final hasFailure = writes.lastError != null;
        final pendingCount = writes.pending.length;
        final color = hasFailure ? RampColors.danger : RampColors.primary;
        final message = hasFailure
            ? writes.lastError!
            : writes.isSyncing
                ? 'Saving $pendingCount pending change(s)...'
                : '$pendingCount change(s) waiting to sync';

        return Material(
          color: color,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              child: Row(children: [
                Icon(
                    hasFailure
                        ? Icons.error_outline_rounded
                        : Icons.cloud_sync_rounded,
                    size: 16,
                    color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(message,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600))),
                if (!writes.isSyncing)
                  TextButton(
                    onPressed: () {
                      PersistenceQueue.instance.retry();
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 8)),
                    child: Text(hasFailure ? 'Retry' : 'Sync now'),
                  ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
