import 'package:hive_flutter/hive_flutter.dart';
import '../constants/api_constants.dart';
import '../../models/customer_model.dart';
import '../../models/site_model.dart';
import '../../models/field_note_model.dart';
import '../../models/user_model.dart';

class StorageService {
  static const String boxCustomers = 'customers_box';
  static const String boxSites = 'sites_box';
  static const String boxNotes = 'notes_box';
  static const String boxSettings = 'settings_box';

  late Box _customersBox;
  late Box _sitesBox;
  late Box _notesBox;
  late Box _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _customersBox = await Hive.openBox(boxCustomers);
    _sitesBox = await Hive.openBox(boxSites);
    _notesBox = await Hive.openBox(boxNotes);
    _settingsBox = await Hive.openBox(boxSettings);
  }

  // --- Auth & Settings Storage ---

  String getBaseUrl() {
    return _settingsBox.get(ApiConstants.keyBaseUrl, defaultValue: ApiConstants.defaultBaseUrl) as String;
  }

  Future<void> saveBaseUrl(String url) async {
    await _settingsBox.put(ApiConstants.keyBaseUrl, url);
  }

  String? getToken() {
    return _settingsBox.get(ApiConstants.keyToken) as String?;
  }

  Future<void> saveToken(String token) async {
    await _settingsBox.put(ApiConstants.keyToken, token);
  }

  Future<void> removeToken() async {
    await _settingsBox.delete(ApiConstants.keyToken);
  }

  UserModel? getUser() {
    final map = _settingsBox.get(ApiConstants.keyUser);
    if (map is Map) {
      return UserModel.fromJson(Map<String, dynamic>.from(map));
    }
    return null;
  }

  Future<void> saveUser(UserModel user) async {
    await _settingsBox.put(ApiConstants.keyUser, user.toJson());
  }

  Future<void> removeUser() async {
    await _settingsBox.delete(ApiConstants.keyUser);
  }

  String getDefaultNoteStatus() {
    return _settingsBox.get(ApiConstants.keyDefaultNoteStatus, defaultValue: 'Draft') as String;
  }

  Future<void> saveDefaultNoteStatus(String status) async {
    await _settingsBox.put(ApiConstants.keyDefaultNoteStatus, status);
  }

  DateTime? getLastSyncTime() {
    final millis = _settingsBox.get(ApiConstants.keyLastSyncTime);
    if (millis is int) {
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
    return null;
  }

  Future<void> saveLastSyncTime(DateTime time) async {
    await _settingsBox.put(ApiConstants.keyLastSyncTime, time.millisecondsSinceEpoch);
  }

  // --- Customers Storage ---

  List<CustomerModel> getAllCustomers() {
    return _customersBox.values
        .whereType<Map>()
        .map((m) => CustomerModel.fromMap(m))
        .where((c) => !c.deleted)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  CustomerModel? getCustomerById(String id) {
    final map = _customersBox.get(id);
    if (map is Map) {
      return CustomerModel.fromMap(map);
    }
    return null;
  }

  Future<void> saveCustomer(CustomerModel customer) async {
    await _customersBox.put(customer.id, customer.toMap());
  }

  Future<void> saveCustomers(List<CustomerModel> customers) async {
    final entries = {for (var c in customers) c.id: c.toMap()};
    await _customersBox.putAll(entries);
  }

  Future<void> deleteCustomer(String id) async {
    final existing = getCustomerById(id);
    if (existing != null) {
      final updated = existing.copyWith(
        deleted: true,
        isSynced: false,
        updatedAt: DateTime.now(),
      );
      await _customersBox.put(id, updated.toMap());

      // Cascade soft delete to sites and notes
      final sites = getSitesByCustomerId(id);
      for (var s in sites) {
        await deleteSite(s.id);
      }
    }
  }

  List<CustomerModel> getUnsyncedCustomers() {
    return _customersBox.values
        .whereType<Map>()
        .map((m) => CustomerModel.fromMap(m))
        .where((c) => !c.isSynced)
        .toList();
  }

  // --- Sites Storage ---

  List<SiteModel> getAllSites() {
    return _sitesBox.values
        .whereType<Map>()
        .map((m) => SiteModel.fromMap(m))
        .where((s) => !s.deleted)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  List<SiteModel> getSitesByCustomerId(String customerId) {
    return getAllSites().where((s) => s.customerId == customerId).toList();
  }

  SiteModel? getSiteById(String id) {
    final map = _sitesBox.get(id);
    if (map is Map) {
      return SiteModel.fromMap(map);
    }
    return null;
  }

  Future<void> saveSite(SiteModel site) async {
    await _sitesBox.put(site.id, site.toMap());
  }

  Future<void> saveSites(List<SiteModel> sites) async {
    final entries = {for (var s in sites) s.id: s.toMap()};
    await _sitesBox.putAll(entries);
  }

  Future<void> deleteSite(String id) async {
    final existing = getSiteById(id);
    if (existing != null) {
      final updated = existing.copyWith(
        deleted: true,
        isSynced: false,
        updatedAt: DateTime.now(),
      );
      await _sitesBox.put(id, updated.toMap());

      // Cascade soft delete to notes
      final notes = getNotesBySiteId(id);
      for (var n in notes) {
        await deleteNote(n.id);
      }
    }
  }

  List<SiteModel> getUnsyncedSites() {
    return _sitesBox.values
        .whereType<Map>()
        .map((m) => SiteModel.fromMap(m))
        .where((s) => !s.isSynced)
        .toList();
  }

  // --- Field Notes Storage ---

  List<FieldNoteModel> getAllNotes() {
    return _notesBox.values
        .whereType<Map>()
        .map((m) => FieldNoteModel.fromMap(m))
        .where((n) => !n.deleted)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  List<FieldNoteModel> getNotesBySiteId(String siteId) {
    return getAllNotes().where((n) => n.siteId == siteId).toList();
  }

  FieldNoteModel? getNoteById(String id) {
    final map = _notesBox.get(id);
    if (map is Map) {
      return FieldNoteModel.fromMap(map);
    }
    return null;
  }

  Future<void> saveNote(FieldNoteModel note) async {
    await _notesBox.put(note.id, note.toMap());
  }

  Future<void> saveNotes(List<FieldNoteModel> notes) async {
    final entries = {for (var n in notes) n.id: n.toMap()};
    await _notesBox.putAll(entries);
  }

  Future<void> deleteNote(String id) async {
    final existing = getNoteById(id);
    if (existing != null) {
      final updated = existing.copyWith(
        deleted: true,
        isSynced: false,
        updatedAt: DateTime.now(),
      );
      await _notesBox.put(id, updated.toMap());
    }
  }

  List<FieldNoteModel> getUnsyncedNotes() {
    return _notesBox.values
        .whereType<Map>()
        .map((m) => FieldNoteModel.fromMap(m))
        .where((n) => !n.isSynced)
        .toList();
  }

  // --- Search & Filter Notes Locally (for offline use) ---

  List<FieldNoteModel> searchAndFilterNotes({
    String? query,
    String? status,
    String? siteId,
    String? customerId,
  }) {
    var notes = getAllNotes();

    if (siteId != null && siteId.isNotEmpty) {
      notes = notes.where((n) => n.siteId == siteId).toList();
    }

    if (customerId != null && customerId.isNotEmpty) {
      final customerSites = getSitesByCustomerId(customerId).map((s) => s.id).toSet();
      notes = notes.where((n) => customerSites.contains(n.siteId)).toList();
    }

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      notes = notes.where((n) => n.status.toLowerCase() == status.toLowerCase()).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      notes = notes.where((n) {
        final titleMatch = n.title.toLowerCase().contains(q);
        final descMatch = n.description?.toLowerCase().contains(q) ?? false;
        final siteMatch = n.siteName?.toLowerCase().contains(q) ?? false;
        final custMatch = n.customerName?.toLowerCase().contains(q) ?? false;
        return titleMatch || descMatch || siteMatch || custMatch;
      }).toList();
    }

    return notes;
  }

  // --- Clear all data on logout ---

  Future<void> clearUserData() async {
    await _customersBox.clear();
    await _sitesBox.clear();
    await _notesBox.clear();
    await _settingsBox.delete(ApiConstants.keyLastSyncTime);
    await _settingsBox.delete(ApiConstants.keyUser);
    await _settingsBox.delete(ApiConstants.keyToken);
  }
}
