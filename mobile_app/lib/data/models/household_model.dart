import 'package:uuid/uuid.dart';

class Household {
  final String householdId;
  final String ashaId;
  final String? houseNumber;
  final String? familySurname;
  final String headOfFamilyName;
  final String address;
  final String? rationCardType;
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
    this.rationCardType,
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
      'ration_card_type': rationCardType,
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
      rationCardType: map['ration_card_type'],
      totalMembers: map['total_members'],
      totalAdults: map['total_adults'],
      totalChildren: map['total_children'],
      lastModifiedAt: map['last_modified_at'],
      isDeleted: map['is_deleted'],
    );
  }
}
