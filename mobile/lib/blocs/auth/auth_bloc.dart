import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/services/storage_service.dart';
import '../../models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiClient apiClient;
  final StorageService storageService;

  AuthBloc({
    required this.apiClient,
    required this.storageService,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<ContinueOfflineEvent>(_onContinueOffline);
    on<LogoutEvent>(_onLogout);
  }

  void _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) {
    final token = storageService.getToken();
    final user = storageService.getUser();

    if (token != null && token.isNotEmpty && user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onContinueOffline(
      ContinueOfflineEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final username = (event.username != null && event.username!.trim().isNotEmpty)
        ? event.username!.trim()
        : 'field_inspector';
    final fullName = (event.fullName != null && event.fullName!.trim().isNotEmpty)
        ? event.fullName!.trim()
        : 'Field Inspector';
    final user = UserModel(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      email: '$username@fieldnotes.local',
      fullName: fullName,
      token: 'local-offline-token',
    );
    await storageService.saveToken('local-offline-token');
    await storageService.saveUser(user);
    await storageService.saveLocalUserCredential(
      id: user.id.toString(),
      username: username,
      email: user.email,
      fullName: fullName,
      password: '',
    );
    emit(Authenticated(user));
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await apiClient.post(
        ApiConstants.endpointLogin,
        body: {
          'username': event.username.trim(),
          'password': event.password,
        },
        timeout: const Duration(seconds: 4),
      );

      if (response != null && response is Map<String, dynamic>) {
        final token = response['token'] as String;
        final userJson = response['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userJson, token: token);

        await storageService.saveToken(token);
        await storageService.saveUser(user);
        await storageService.saveLocalUserCredential(
          id: user.id.toString(),
          username: user.username,
          email: user.email,
          fullName: user.fullName,
          password: event.password,
        );

        emit(Authenticated(user));
        return;
      }
    } catch (_) {
      // Backend unreachable or offline. Check local offline credentials.
    }

    // 1. Check existing local offline credentials
    final localCred = storageService.findLocalUserCredential(event.username);
    if (localCred != null) {
      final storedPass = localCred['password'] as String? ?? '';
      if (storedPass.isEmpty || storedPass == event.password) {
        final user = UserModel(
          id: localCred['id'],
          username: localCred['username'] ?? event.username,
          email: localCred['email'] ?? '',
          fullName: localCred['fullName'],
          token: 'local-offline-token',
        );
        await storageService.saveToken('local-offline-token');
        await storageService.saveUser(user);
        emit(Authenticated(user));
        return;
      } else {
        emit(const AuthError('Incorrect password for local user profile.'));
        return;
      }
    }

    // 2. Allow standalone offline login with provided credentials
    final offlineUser = UserModel(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      username: event.username.trim(),
      email: event.username.contains('@')
          ? event.username.trim()
          : '${event.username.trim()}@fieldnotes.local',
      fullName: event.username.trim(),
      token: 'local-offline-token',
    );
    await storageService.saveToken('local-offline-token');
    await storageService.saveUser(offlineUser);
    await storageService.saveLocalUserCredential(
      id: offlineUser.id.toString(),
      username: event.username.trim(),
      email: offlineUser.email,
      fullName: offlineUser.fullName,
      password: event.password,
    );
    emit(Authenticated(offlineUser));
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await apiClient.post(
        ApiConstants.endpointRegister,
        body: {
          'username': event.username.trim(),
          'email': event.email.trim(),
          'password': event.password,
          if (event.fullName != null && event.fullName!.trim().isNotEmpty)
            'fullName': event.fullName!.trim(),
        },
        timeout: const Duration(seconds: 4),
      );

      if (response != null && response is Map<String, dynamic>) {
        final token = response['token'] as String;
        final userJson = response['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userJson, token: token);

        await storageService.saveToken(token);
        await storageService.saveUser(user);
        await storageService.saveLocalUserCredential(
          id: user.id.toString(),
          username: event.username.trim(),
          email: event.email.trim(),
          fullName: event.fullName?.trim(),
          password: event.password,
        );

        emit(Authenticated(user));
        return;
      }
    } catch (_) {
      // Backend unreachable or offline. Proceed with local offline registration!
    }

    // Offline registration in local Hive storage
    final localUser = UserModel(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      username: event.username.trim(),
      email: event.email.trim(),
      fullName: (event.fullName != null && event.fullName!.trim().isNotEmpty)
          ? event.fullName!.trim()
          : event.username.trim(),
      token: 'local-offline-token',
    );

    await storageService.saveToken('local-offline-token');
    await storageService.saveUser(localUser);
    await storageService.saveLocalUserCredential(
      id: localUser.id.toString(),
      username: event.username.trim(),
      email: event.email.trim(),
      fullName: localUser.fullName,
      password: event.password,
    );

    emit(Authenticated(localUser));
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await storageService.clearUserData();
    emit(Unauthenticated());
  }
}

