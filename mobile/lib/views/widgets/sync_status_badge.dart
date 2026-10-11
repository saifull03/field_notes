import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/sync/sync_bloc.dart';
import '../../blocs/sync/sync_event.dart';
import '../../blocs/sync/sync_state.dart';

class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        if (state is SyncInProgress) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 6),
                Text(
                  'Syncing...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          );
        }

        int unsynced = 0;
        DateTime? lastSync;
        if (state is SyncInitial) {
          unsynced = state.unsyncedCount;
          lastSync = state.lastSyncTime;
        } else if (state is SyncSuccess) {
          unsynced = state.unsyncedCount;
          lastSync = state.lastSyncTime;
        } else if (state is SyncFailure) {
          unsynced = state.unsyncedCount;
          lastSync = state.lastSyncTime;
        }

        final hasPending = unsynced > 0;
        final color = hasPending ? Colors.amber.shade700 : Colors.teal.shade700;
        final bgColor = hasPending ? Colors.amber.shade50 : Colors.teal.shade50;
        final icon = hasPending ? Icons.sync_problem_rounded : Icons.cloud_done_rounded;
        final label = hasPending ? '$unsynced Pending' : 'Synced';

        return InkWell(
          onTap: () => _showSyncSheet(context, lastSync, unsynced),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSyncSheet(BuildContext context, DateTime? lastSync, int unsynced) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sync_rounded, color: Color(0xFF0F766E), size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Synchronization Status',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history_rounded, color: Colors.grey),
                  title: const Text('Last Synchronized'),
                  subtitle: Text(
                    lastSync != null
                        ? DateFormat('MMM d, yyyy  h:mm a').format(lastSync.toLocal())
                        : 'Never synchronized yet',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    unsynced > 0 ? Icons.pending_actions_rounded : Icons.check_circle_rounded,
                    color: unsynced > 0 ? Colors.amber.shade700 : Colors.green,
                  ),
                  title: const Text('Pending Local Changes'),
                  subtitle: Text(
                    unsynced > 0
                        ? '$unsynced item(s) waiting to sync to backend'
                        : 'All offline records are synced with backend',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(bottomSheetContext);
                    context.read<SyncBloc>().add(TriggerSyncEvent());
                  },
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text('Sync Now With Backend'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
