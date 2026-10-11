import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';
import '../../blocs/sync/sync_bloc.dart';
import '../../blocs/sync/sync_event.dart';
import '../../blocs/sync/sync_state.dart';
import '../../core/constants/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const List<String> statusOptions = [
    'Draft',
    'In Progress',
    'Completed',
    'Pending',
  ];

  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    final settingsState = context.read<SettingsBloc>().state;
    final currentUrl = settingsState is SettingsLoaded ? settingsState.baseUrl : 'http://localhost:8080';
    _urlController = TextEditingController(text: currentUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text(
          'Logging out will clear local cached session data. Make sure to sync any pending offline changes first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthBloc>().add(LogoutEvent());
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final dateFormat = DateFormat('MMM d, yyyy  h:mm a');

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. User Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF0F766E).withValues(alpha: 0.15),
                    child: const Icon(Icons.person_rounded, size: 32, color: Color(0xFF0F766E)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? user?.username ?? 'Field Worker',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${user?.username ?? ""}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Note Settings Section (Required Feature!)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: Text(
              'FIELD NOTE PREFERENCES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
          ),
          Card(
            child: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                final currentStatus =
                    state is SettingsLoaded ? state.defaultNoteStatus : 'Draft';

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tune_rounded, color: Color(0xFF0F766E)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Default Note Status',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Automatically assigned when creating a new field note. Stored locally.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: statusOptions.map((st) {
                          final isSelected = currentStatus.toLowerCase() == st.toLowerCase();
                          final color = AppTheme.getStatusColor(st);

                          return ChoiceChip(
                            label: Text(st),
                            selected: isSelected,
                            selectedColor: color.withValues(alpha: 0.2),
                            checkmarkColor: color,
                            labelStyle: TextStyle(
                              color: isSelected ? color : const Color(0xFF475569),
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: isSelected ? color : const Color(0xFFCBD5E1),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                context
                                    .read<SettingsBloc>()
                                    .add(UpdateDefaultNoteStatusEvent(st));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Default Note Status set to: $st'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // 3. Synchronization Controls
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: Text(
              'CLOUD SYNCHRONIZATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
          ),
          Card(
            child: BlocConsumer<SyncBloc, SyncState>(
              listener: (context, state) {
                if (state is SyncSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Sync Complete: ${state.pushedCount} pushed, ${state.pulledCount} pulled',
                      ),
                      backgroundColor: Colors.teal.shade700,
                    ),
                  );
                } else if (state is SyncFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                }
              },
              builder: (context, syncState) {
                DateTime? lastSync;
                int unsynced = 0;
                bool isSyncing = syncState is SyncInProgress;

                if (syncState is SyncInitial) {
                  lastSync = syncState.lastSyncTime;
                  unsynced = syncState.unsyncedCount;
                } else if (syncState is SyncSuccess) {
                  lastSync = syncState.lastSyncTime;
                  unsynced = syncState.unsyncedCount;
                } else if (syncState is SyncFailure) {
                  lastSync = syncState.lastSyncTime;
                  unsynced = syncState.unsyncedCount;
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Last Synchronized:',
                            style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
                          ),
                          Text(
                            lastSync != null ? dateFormat.format(lastSync.toLocal()) : 'Never',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pending Local Changes:',
                            style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: unsynced > 0 ? Colors.amber.shade100 : Colors.teal.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$unsynced item(s)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: unsynced > 0 ? Colors.amber.shade900 : Colors.teal.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: isSyncing
                            ? null
                            : () => context.read<SyncBloc>().add(TriggerSyncEvent()),
                        icon: isSyncing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.sync_rounded),
                        label: Text(isSyncing ? 'Synchronizing...' : 'Sync Now'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // 4. Backend Server Config
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: Text(
              'NETWORK CONFIGURATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Backend REST API URL',
                      hintText: 'http://localhost:8080 or http://10.0.2.2:8080',
                      prefixIcon: Icon(Icons.dns_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      final url = _urlController.text.trim();
                      if (url.isNotEmpty) {
                        context.read<SettingsBloc>().add(UpdateBaseUrlEvent(url));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Server URL saved: $url')),
                        );
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Server URL'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 5. Logout Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Log Out'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
