import 'package:uuid/uuid.dart';

class AshaWorker {
  final String ashaId;
  final String name;
  final String phone;
  final String village;
  final String phcName;
  final String? authToken;
  final String? sessionExpiry;
  final String lastModifiedAt;
  final int isDeleted;

  AshaWorker({
    String? ashaId,
    required this.name,
    required this.phone,
    required this.village,
    required this.phcName,
    this.authToken,
    this.sessionExpiry,
    required this.lastModifiedAt,
    this.isDeleted = 0,
  }) : ashaId = ashaId ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'asha_id': ashaId,
      'name': name,
      'phone': phone,
      'village': village,
      'phc_name': phcName,
      'auth_token': authToken,
      'session_expiry': sessionExpiry,
      'last_modified_at': lastModifiedAt,
      'is_deleted': isDeleted,
    };
  }

  factory AshaWorker.fromMap(Map<String, dynamic> map) {
    return AshaWorker(
      ashaId: map['asha_id'],
      name: map['name'],
      phone: map['phone'],
      village: map['village'],
      phcName: map['phc_name'],
      authToken: map['auth_token'],
      sessionExpiry: map['session_expiry'],
      lastModifiedAt: map['last_modified_at'],
      isDeleted: map['is_deleted'],
    );
  }
}
