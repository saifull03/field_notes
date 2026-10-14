import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/sync/sync_bloc.dart';
import '../../blocs/sync/sync_event.dart';

class ConnectivitySyncListener extends StatefulWidget {
  final Widget child;

  const ConnectivitySyncListener({super.key, required this.child});

  @override
  State<ConnectivitySyncListener> createState() =>
      _ConnectivitySyncListenerState();
}

class _ConnectivitySyncListenerState extends State<ConnectivitySyncListener> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkConnectionAndSync();
      }
    });
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (results.any((result) => result != ConnectivityResult.none)) {
      _triggerSync();
    }
  }

  Future<void> _checkConnectionAndSync() async {
    final results = await Connectivity().checkConnectivity();
    if (results.any((result) => result != ConnectivityResult.none)) {
      _triggerSync();
    }
  }

  void _triggerSync() {
    if (mounted) {
      context.read<SyncBloc>().add(TriggerSyncEvent());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
