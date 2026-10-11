import 'package:equatable/equatable.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();
  @override
  List<Object?> get props => [];
}

class TriggerSyncEvent extends SyncEvent {}

class CheckSyncStatusEvent extends SyncEvent {}
