import 'package:uuid/uuid.dart';

class SyncStatus {
  final String syncId;
  final String entityType;
  final String entityId;
  final String operation; // 'CREATE', 'UPDATE', 'SOFT_DELETE'
  final String syncStatus; // 'PENDING', 'SYNCED'
  final String createdAt;

  SyncStatus({
    String? syncId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.syncStatus = 'PENDING',
    String? createdAt,
  }) : syncId = syncId ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'sync_id': syncId,
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation,
      'sync_status': syncStatus,
      'created_at': createdAt,
    };
  }

  factory SyncStatus.fromMap(Map<String, dynamic> map) {
    return SyncStatus(
      syncId: map['sync_id'],
      entityType: map['entity_type'],
      entityId: map['entity_id'],
      operation: map['operation'],
      syncStatus: map['sync_status'],
      createdAt: map['created_at'],
    );
  }
}
