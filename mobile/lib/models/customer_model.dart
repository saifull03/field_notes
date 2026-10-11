class CustomerModel {
  final String id;
  final String name;
  final String? contactInformation;
  final int siteCount;
  final int noteCount;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  CustomerModel({
    required this.id,
    required this.name,
    this.contactInformation,
    this.siteCount = 0,
    this.noteCount = 0,
    this.deleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CustomerModel.fromJson(Map<String, dynamic> json, {bool isSynced = true}) {
    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      contactInformation: json['contactInformation'] as String?,
      siteCount: (json['siteCount'] as num?)?.toInt() ?? 0,
      noteCount: (json['noteCount'] as num?)?.toInt() ?? 0,
      deleted: json['deleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      isSynced: isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactInformation': contactInformation,
      'siteCount': siteCount,
      'noteCount': noteCount,
      'deleted': deleted,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contactInformation': contactInformation,
      'siteCount': siteCount,
      'noteCount': noteCount,
      'deleted': deleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isSynced': isSynced,
    };
  }

  factory CustomerModel.fromMap(Map<dynamic, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      contactInformation: map['contactInformation'] as String?,
      siteCount: (map['siteCount'] as num?)?.toInt() ?? 0,
      noteCount: (map['noteCount'] as num?)?.toInt() ?? 0,
      deleted: map['deleted'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : DateTime.now(),
      isSynced: map['isSynced'] as bool? ?? false,
    );
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? contactInformation,
    int? siteCount,
    int? noteCount,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contactInformation: contactInformation ?? this.contactInformation,
      siteCount: siteCount ?? this.siteCount,
      noteCount: noteCount ?? this.noteCount,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
