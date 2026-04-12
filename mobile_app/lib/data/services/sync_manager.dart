import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sync_service.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final SyncService _syncService = SyncService();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isSyncing = false;

  /// Initializes the sync manager and starts listening for connectivity changes.
  void init() {
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        _performSync();
      }
    });
  }

  /// Manually triggers a sync.
  Future<void> manualSync() async {
    await _performSync();
  }

  Future<void> _performSync() async {
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      print('SyncManager: Starting background sync...');
      await _syncService.syncPendingRecords();
      print('SyncManager: Sync completed.');
    } catch (e) {
      print('SyncManager: Sync failed - $e');
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
