import 'package:equatable/equatable.dart';

abstract class SyncState extends Equatable {
  const SyncState();
  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {
  final DateTime? lastSyncTime;
  final int unsyncedCount;

  const SyncInitial({this.lastSyncTime, this.unsyncedCount = 0});

  @override
  List<Object?> get props => [lastSyncTime, unsyncedCount];
}

class SyncInProgress extends SyncState {}

class SyncSuccess extends SyncState {
  final String message;
  final int pushedCount;
  final int pulledCount;
  final DateTime lastSyncTime;
  final int unsyncedCount;

  const SyncSuccess({
    required this.message,
    required this.pushedCount,
    required this.pulledCount,
    required this.lastSyncTime,
    this.unsyncedCount = 0,
  });

  @override
  List<Object?> get props => [message, pushedCount, pulledCount, lastSyncTime, unsyncedCount];
}

class SyncFailure extends SyncState {
  final String message;
  final DateTime? lastSyncTime;
  final int unsyncedCount;

  const SyncFailure({
    required this.message,
    this.lastSyncTime,
    this.unsyncedCount = 0,
  });

  @override
  List<Object?> get props => [message, lastSyncTime, unsyncedCount];
}

