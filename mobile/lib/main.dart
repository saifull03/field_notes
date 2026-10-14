import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/customer/customer_bloc.dart';
import 'blocs/note/note_bloc.dart';
import 'blocs/settings/settings_bloc.dart';
import 'blocs/settings/settings_event.dart';
import 'blocs/site/site_bloc.dart';
import 'blocs/sync/sync_bloc.dart';
import 'core/constants/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/services/storage_service.dart';
import 'core/services/sync_service.dart';
import 'core/services/connectivity_sync_listener.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final apiClient = ApiClient(storageService);
  final syncService = SyncService(apiClient, storageService);

  runApp(
    FieldNotesApp(
      storageService: storageService,
      apiClient: apiClient,
      syncService: syncService,
    ),
  );
}

class FieldNotesApp extends StatelessWidget {
  final StorageService storageService;
  final ApiClient apiClient;
  final SyncService syncService;

  const FieldNotesApp({
    super.key,
    required this.storageService,
    required this.apiClient,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: storageService),
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider.value(value: syncService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>(
            create: (_) =>
                SettingsBloc(storageService: storageService)
                  ..add(LoadSettingsEvent()),
          ),
          BlocProvider<AuthBloc>(
            create: (_) =>
                AuthBloc(apiClient: apiClient, storageService: storageService)
                  ..add(CheckAuthStatusEvent()),
          ),
          BlocProvider<SyncBloc>(
            create: (_) => SyncBloc(
              syncService: syncService,
              storageService: storageService,
            ),
          ),
          BlocProvider<CustomerBloc>(
            create: (_) => CustomerBloc(
              storageService: storageService,
              syncService: syncService,
            ),
          ),
          BlocProvider<SiteBloc>(
            create: (_) => SiteBloc(
              storageService: storageService,
              syncService: syncService,
            ),
          ),
          BlocProvider<NoteBloc>(
            create: (_) => NoteBloc(
              storageService: storageService,
              syncService: syncService,
            ),
          ),
        ],
        child: ConnectivitySyncListener(
          child: MaterialApp(
            title: 'Field Notes',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return const HomeDashboardScreen();
                } else if (state is Unauthenticated || state is AuthError) {
                  return const LoginScreen();
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
