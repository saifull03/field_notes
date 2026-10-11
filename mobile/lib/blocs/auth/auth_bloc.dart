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

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await apiClient.post(
        ApiConstants.endpointLogin,
        body: {
          'username': event.username.trim(),
          'password': event.password,
        },
      );

      if (response != null && response is Map<String, dynamic>) {
        final token = response['token'] as String;
        final userJson = response['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userJson, token: token);

        await storageService.saveToken(token);
        await storageService.saveUser(user);

        emit(Authenticated(user));
      } else {
        emit(const AuthError('Invalid server response'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
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
      );

      if (response != null && response is Map<String, dynamic>) {
        final token = response['token'] as String;
        final userJson = response['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userJson, token: token);

        await storageService.saveToken(token);
        await storageService.saveUser(user);

        emit(Authenticated(user));
      } else {
        emit(const AuthError('Invalid server response'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await storageService.clearUserData();
    emit(Unauthenticated());
  }
}

