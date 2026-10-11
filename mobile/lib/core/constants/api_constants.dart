import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080';
      }
    } catch (_) {}
    return 'http://localhost:8080';
  }

  static const String keyBaseUrl = 'pref_base_url';
  static const String keyToken = 'pref_auth_token';
  static const String keyUser = 'pref_user_data';
  static const String keyDefaultNoteStatus = 'pref_default_note_status';
  static const String keyLastSyncTime = 'pref_last_sync_time';

  // API endpoints
  static const String endpointRegister = '/api/auth/register';
  static const String endpointLogin = '/api/auth/login';
  static const String endpointMe = '/api/auth/me';

  static const String endpointCustomers = '/api/customers';
  static const String endpointSites = '/api/sites';
  static const String endpointNotes = '/api/notes';
  static const String endpointUploadPhoto = '/api/notes/upload-photo';

  static const String endpointSyncPull = '/api/sync/pull';
  static const String endpointSyncPush = '/api/sync/push';
}

