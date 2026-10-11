class FieldNoteModel {
  final String id;
  final String siteId;
  final String? siteName;
  final String? customerId;
  final String? customerName;
  final String title;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final DateTime dateTime;
  final String status;
  final String? photoUrl;
  final String? localPhotoPath;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  FieldNoteModel({
    required this.id,
    required this.siteId,
    this.siteName,
    this.customerId,
    this.customerName,
    required this.title,
    this.description,
    this.latitude,
    this.longitude,
    this.locationName,
    DateTime? dateTime,
    this.status = 'Draft',
    this.photoUrl,
    this.localPhotoPath,
    this.deleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = true,
  })  : dateTime = dateTime ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory FieldNoteModel.fromJson(Map<String, dynamic> json, {bool isSynced = true}) {
    return FieldNoteModel(
      id: json['id'] as String,
      siteId: json['siteId'] as String,
      siteName: json['siteName'] as String?,
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime']) : DateTime.now(),
      status: json['status'] as String? ?? 'Draft',
      photoUrl: json['photoUrl'] as String?,
      deleted: json['deleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      isSynced: isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteId': siteId,
      'siteName': siteName,
      'customerId': customerId,
      'customerName': customerName,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'dateTime': dateTime.toUtc().toIso8601String(),
      'status': status,
      'photoUrl': photoUrl,
      'deleted': deleted,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'siteId': siteId,
      'siteName': siteName,
      'customerId': customerId,
      'customerName': customerName,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'status': status,
      'photoUrl': photoUrl,
      'localPhotoPath': localPhotoPath,
      'deleted': deleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isSynced': isSynced,
    };
  }

  factory FieldNoteModel.fromMap(Map<dynamic, dynamic> map) {
    return FieldNoteModel(
      id: map['id'] as String,
      siteId: map['siteId'] as String,
      siteName: map['siteName'] as String?,
      customerId: map['customerId'] as String?,
      customerName: map['customerName'] as String?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      locationName: map['locationName'] as String?,
      dateTime: map['dateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int)
          : DateTime.now(),
      status: map['status'] as String? ?? 'Draft',
      photoUrl: map['photoUrl'] as String?,
      localPhotoPath: map['localPhotoPath'] as String?,
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

  FieldNoteModel copyWith({
    String? id,
    String? siteId,
    String? siteName,
    String? customerId,
    String? customerName,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? locationName,
    DateTime? dateTime,
    String? status,
    String? photoUrl,
    String? localPhotoPath,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return FieldNoteModel(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
