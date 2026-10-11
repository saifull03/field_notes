import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/customer/customer_bloc.dart';
import '../../blocs/customer/customer_event.dart';
import '../../blocs/note/note_bloc.dart';
import '../../blocs/note/note_event.dart';
import '../../blocs/site/site_bloc.dart';
import '../../blocs/site/site_event.dart';
import '../../blocs/sync/sync_bloc.dart';
import '../../blocs/sync/sync_event.dart';
import '../customers/customer_list_screen.dart';
import '../notes/note_list_screen.dart';
import '../settings/settings_screen.dart';
import '../sites/site_list_screen.dart';
import '../widgets/sync_status_badge.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    NoteListScreen(),
    CustomerListScreen(),
    SiteListScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = const [
    'Field Notes',
    'Customers',
    'Inspection Sites',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    // Refresh all lists and check sync status on dashboard launch
    _refreshAll();
  }

  void _refreshAll() {
    context.read<NoteBloc>().add(const LoadNotesEvent());
    context.read<CustomerBloc>().add(LoadCustomersEvent());
    context.read<SiteBloc>().add(const LoadSitesEvent());
    context.read<SyncBloc>().add(CheckSyncStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          const Center(child: SyncStatusBadge()),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Synchronize Data',
            onPressed: () {
              context.read<SyncBloc>().add(TriggerSyncEvent());
              _refreshAll();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() => _currentIndex = idx);
          if (idx == 0) {
            context.read<NoteBloc>().add(const LoadNotesEvent());
          } else if (idx == 1) {
            context.read<CustomerBloc>().add(LoadCustomersEvent());
          } else if (idx == 2) {
            context.read<SiteBloc>().add(const LoadSitesEvent());
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.note_alt_outlined),
            selectedIcon: Icon(Icons.note_alt_rounded),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business_rounded),
            label: 'Customers',
          ),
          NavigationDestination(
            icon: Icon(Icons.place_outlined),
            selectedIcon: Icon(Icons.place_rounded),
            label: 'Sites',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

