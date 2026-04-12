import 'package:uuid/uuid.dart';

class CampEvent {
  final String campId;
  final String ashaId;
  final String campType;
  final String campDate;
  final String location;
  final String lastModifiedAt;
  final int isDeleted;

  CampEvent({
    String? campId,
    required this.ashaId,
    required this.campType,
    required this.campDate,
    required this.location,
    required this.lastModifiedAt,
    this.isDeleted = 0,
  }) : campId = campId ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'camp_id': campId,
      'asha_id': ashaId,
      'camp_type': campType,
      'camp_date': campDate,
      'location': location,
      'last_modified_at': lastModifiedAt,
      'is_deleted': isDeleted,
    };
  }

  factory CampEvent.fromMap(Map<String, dynamic> map) {
    return CampEvent(
      campId: map['camp_id'],
      ashaId: map['asha_id'],
      campType: map['camp_type'],
      campDate: map['camp_date'],
      location: map['location'],
      lastModifiedAt: map['last_modified_at'],
      isDeleted: map['is_deleted'],
    );
  }
}
