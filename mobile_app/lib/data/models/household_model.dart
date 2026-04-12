import 'package:uuid/uuid.dart';

class Household {
  final String householdId;
  final String ashaId;
  final String? houseNumber;
  final String? familySurname;
  final String headOfFamilyName;
  final String address;
  final String? landmark;
  final String? locality;
  final String? rationCardType;
  final String? houseType;
  final bool hasToilet;
  final int totalMembers;
  final int totalAdults;
  final int totalChildren;
  final String lastModifiedAt;
  final int isDeleted;

  Household({
    String? householdId,
    required this.ashaId,
    this.houseNumber,
    this.familySurname,
    required this.headOfFamilyName,
    required this.address,
    this.landmark,
    this.locality,
    this.rationCardType,
    this.houseType,
    this.hasToilet = false,
    this.totalMembers = 0,
    this.totalAdults = 0,
    this.totalChildren = 0,
    required this.lastModifiedAt,
    this.isDeleted = 0,
  }) : householdId = householdId ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'household_id': householdId,
      'asha_id': ashaId,
      'house_number': houseNumber,
      'family_surname': familySurname,
      'head_of_family_name': headOfFamilyName,
      'address': address,
      'landmark': landmark,
      'locality': locality,
      'ration_card_type': rationCardType,
      'house_type': houseType,
      'has_toilet': hasToilet ? 1 : 0,
      'total_members': totalMembers,
      'total_adults': totalAdults,
      'total_children': totalChildren,
      'last_modified_at': lastModifiedAt,
      'is_deleted': isDeleted,
    };
  }

  factory Household.fromMap(Map<String, dynamic> map) {
    return Household(
      householdId: map['household_id'],
      ashaId: map['asha_id'],
      houseNumber: map['house_number'],
      familySurname: map['family_surname'],
      headOfFamilyName: map['head_of_family_name'],
      address: map['address'],
      landmark: map['landmark'],
      locality: map['locality'],
      rationCardType: map['ration_card_type'],
      houseType: map['house_type'],
      hasToilet: (map['has_toilet'] ?? 0) == 1,
      totalMembers: map['total_members'] ?? 0,
      totalAdults: map['total_adults'] ?? 0,
      totalChildren: map['total_children'] ?? 0,
      lastModifiedAt: map['last_modified_at'],
      isDeleted: map['is_deleted'] ?? 0,
    );
  }
}
