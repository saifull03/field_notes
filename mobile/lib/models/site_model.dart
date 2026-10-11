class SiteModel {
  final String id;
  final String customerId;
  final String? customerName;
  final String name;
  final String? address;
  final int noteCount;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  SiteModel({
    required this.id,
    required this.customerId,
    this.customerName,
    required this.name,
    this.address,
    this.noteCount = 0,
    this.deleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = true,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory SiteModel.fromJson(Map<String, dynamic> json, {bool isSynced = true}) {
    return SiteModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String?,
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
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
      'customerId': customerId,
      'customerName': customerName,
      'name': name,
      'address': address,
      'noteCount': noteCount,
      'deleted': deleted,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'name': name,
      'address': address,
      'noteCount': noteCount,
      'deleted': deleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isSynced': isSynced,
    };
  }

  factory SiteModel.fromMap(Map<dynamic, dynamic> map) {
    return SiteModel(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String?,
      name: map['name'] as String? ?? '',
      address: map['address'] as String?,
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

  SiteModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? name,
    String? address,
    int? noteCount,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return SiteModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      name: name ?? this.name,
      address: address ?? this.address,
      noteCount: noteCount ?? this.noteCount,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

