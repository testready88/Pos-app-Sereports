import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sereports/repository/invoice_create_repo.dart';

/// Service to listen for connectivity changes and auto-sync pending invoices
class ConnectivityListener {
  final Connectivity _connectivity;
  final InvoiceRepository _invoiceRepository;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isSyncing = false;

  ConnectivityListener({
    required Connectivity connectivity,
    required InvoiceRepository invoiceRepository,
  })  : _connectivity = connectivity,
        _invoiceRepository = invoiceRepository;

  /// Start listening for connectivity changes
  void startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        // Check if we have any connection (wifi, mobile, ethernet, etc.)
        final hasConnection = results.any(
          (result) => result != ConnectivityResult.none,
        );

        if (hasConnection && !_isSyncing) {
          print('Connection restored, starting auto-sync...');
          await _syncPendingInvoices();
        }
      },
    );
  }

  /// Stop listening for connectivity changes
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Sync pending invoices
  Future<void> _syncPendingInvoices() async {
    if (_isSyncing) {
      print('Sync already in progress, skipping...');
      return;
    }

    try {
      _isSyncing = true;
      final result = await _invoiceRepository.syncPendingInvoices();
      print('Auto-sync completed - Synced: ${result['synced']}, Failed: ${result['failed']}');
    } catch (e) {
      print('Error during auto-sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Manually trigger sync (can be called from UI)
  Future<Map<String, dynamic>> manualSync() async {
    if (_isSyncing) {
      return {'synced': 0, 'failed': 0, 'message': 'Sync already in progress'};
    }

    try {
      _isSyncing = true;
      final result = await _invoiceRepository.syncPendingInvoices();
      return result;
    } catch (e) {
      print('Error during manual sync: $e');
      return {'synced': 0, 'failed': 0, 'message': e.toString()};
    } finally {
      _isSyncing = false;
    }
  }

  /// Dispose resources
  void dispose() {
    stopListening();
  }
}

