import 'customer_model.dart';
import 'site_model.dart';
import 'field_note_model.dart';

class SyncPullData {
  final DateTime serverTime;
  final List<CustomerModel> customers;
  final List<SiteModel> sites;
  final List<FieldNoteModel> notes;

  SyncPullData({
    required this.serverTime,
    required this.customers,
    required this.sites,
    required this.notes,
  });

  factory SyncPullData.fromJson(Map<String, dynamic> json) {
    return SyncPullData(
      serverTime: json['serverTime'] != null
          ? DateTime.parse(json['serverTime'])
          : DateTime.now(),
      customers: (json['customers'] as List<dynamic>? ?? [])
          .map((c) => CustomerModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      sites: (json['sites'] as List<dynamic>? ?? [])
          .map((s) => SiteModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as List<dynamic>? ?? [])
          .map((n) => FieldNoteModel.fromJson(n as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SyncPushResult {
  final DateTime serverTime;
  final bool success;
  final List<String> syncedCustomerIds;
  final List<String> syncedSiteIds;
  final List<String> syncedNoteIds;

  SyncPushResult({
    required this.serverTime,
    required this.success,
    required this.syncedCustomerIds,
    required this.syncedSiteIds,
    required this.syncedNoteIds,
  });

  factory SyncPushResult.fromJson(Map<String, dynamic> json) {
    return SyncPushResult(
      serverTime: json['serverTime'] != null
          ? DateTime.parse(json['serverTime'])
          : DateTime.now(),
      success: json['success'] as bool? ?? false,
      syncedCustomerIds: (json['syncedCustomerIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      syncedSiteIds: (json['syncedSiteIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      syncedNoteIds: (json['syncedNoteIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
