// ignore_for_file: avoid_print, unnecessary_import, multiple_combinators

import 'dart:convert';
import 'package:big_decimal/big_decimal.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
// Conditional import: sqflite only on mobile/desktop
import 'local_invoice_db_stub.dart'
    if (dart.library.io) 'package:sqflite/sqflite.dart'
    if (dart.library.html) 'local_invoice_db_stub.dart';

// ==================== LOCAL DATABASE ====================

class LocalInvoiceDatabase {
  static const String tableName = 'invoices';
  static const String _webStorageKey = 'local_invoices';
  Database? _database;
  bool _isInitialized = false;
  SharedPreferences? _prefs;

  Future<void> initializeDatabase() async {
    if (_isInitialized) return;

    // Use shared_preferences for web, sqflite for mobile/desktop
    if (kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      print('Web storage initialized successfully');
      return;
    }

    // Mobile/Desktop: Use sqflite
    // Only execute this code on non-web platforms
    if (!kIsWeb) {
      final databasesPath = await getDatabasesPath();
      // Use string concatenation for path (mobile platforms use '/' separator)
      // This avoids conditional import issues with path.join
      final path = '$databasesPath/invoice_database.db';

      _database = await openDatabase(
        path,
        version: 5, // Incremented to force migration for existing databases
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE $tableName (
              id TEXT PRIMARY KEY,
              clientId TEXT NOT NULL,
              customerCode TEXT NOT NULL,
              customerName TEXT NOT NULL,
              locaCode TEXT NOT NULL,
              unitNo TEXT NOT NULL,
              compId TEXT NOT NULL,
              invType TEXT NOT NULL,
              items TEXT NOT NULL,
              grandTotal REAL NOT NULL,
              createdAt TEXT NOT NULL,
              syncStatus TEXT NOT NULL,
              syncError TEXT,
              invoiceNo TEXT,
              serialNo TEXT,
              paymentType TEXT,
              cashPaid REAL,
              cardPaid REAL,
              creditPaid REAL,
              bankTransferPaid REAL,
              holdStatus TEXT NOT NULL DEFAULT 'NONE'
            )
          ''');
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          if (oldVersion < 2) {
            await db.execute('''
              ALTER TABLE $tableName ADD COLUMN paymentType TEXT;
            ''');
            await db.execute('''
              ALTER TABLE $tableName ADD COLUMN cashPaid REAL;
            ''');
            await db.execute('''
              ALTER TABLE $tableName ADD COLUMN cardPaid REAL;
            ''');
            await db.execute('''
              ALTER TABLE $tableName ADD COLUMN creditPaid REAL;
            ''');
            await db.execute('''
              ALTER TABLE $tableName ADD COLUMN bankTransferPaid REAL;
            ''');
          }
          if (oldVersion < 3) {
            // Add clientId column for merge tracking
            try {
              await db.execute('''
                ALTER TABLE $tableName ADD COLUMN clientId TEXT;
              ''');
              // Update existing records with generated clientId
              final allInvoices = await db.query(tableName);
              for (var invoice in allInvoices) {
                final clientId =
                    DateTime.now().millisecondsSinceEpoch.toString() +
                        (invoice['id'] as String? ?? '');
                await db.update(
                  tableName,
                  {'clientId': clientId},
                  where: 'id = ?',
                  whereArgs: [invoice['id']],
                );
              }
            } catch (e) {
              // Column might already exist, ignore
              print('Note: clientId column may already exist: $e');
            }
          }
          if (oldVersion < 4) {
            // Add holdStatus column for invoice hold functionality
            try {
              await db.execute('''
                ALTER TABLE $tableName ADD COLUMN holdStatus TEXT DEFAULT 'NONE';
              ''');
              // Update existing records to have 'NONE' hold status
              await db.update(
                tableName,
                {'holdStatus': 'NONE'},
                where: 'holdStatus IS NULL',
              );
            } catch (e) {
              // Column might already exist, ignore
              print('Note: holdStatus column may already exist: $e');
            }
          }
          if (oldVersion < 5) {
            // Ensure holdStatus column exists (for databases created before version 4)
            try {
              await db.execute('''
                ALTER TABLE $tableName ADD COLUMN holdStatus TEXT DEFAULT 'NONE';
              ''');
              // Update existing records to have 'NONE' hold status
              await db.update(
                tableName,
                {'holdStatus': 'NONE'},
                where: 'holdStatus IS NULL',
              );
            } catch (e) {
              // Column might already exist, ignore
              print('Note: holdStatus column may already exist: $e');
            }
          }
        },
      );
      print('Database initialized successfully');
    }
    _isInitialized = true;
  }

  // Helper methods for web storage
  List<Map<String, dynamic>> _getWebInvoices() {
    if (_prefs == null) return [];
    final invoicesJson = _prefs!.getString(_webStorageKey);
    if (invoicesJson == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(invoicesJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error decoding web invoices: $e');
      return [];
    }
  }

  Future<void> _saveWebInvoices(List<Map<String, dynamic>> invoices) async {
    if (_prefs == null) return;
    await _prefs!.setString(_webStorageKey, jsonEncode(invoices));
  }

  Future<void> saveInvoice({
    required String id,
    required String clientId,
    required String customerCode,
    required String customerName,
    required String locaCode,
    required String unitNo,
    required String compId,
    required String invType,
    required List<dynamic> items,
    required BigDecimal grandTotal,
    required DateTime createdAt,
    required String syncStatus,
    String? syncError,
    String? invoiceNo,
    String? serialNo,
    String? paymentType,
    BigDecimal? cashPaid,
    BigDecimal? cardPaid,
    BigDecimal? creditPaid,
    BigDecimal? bankTransferPaid,
    String? holdStatus,
  }) async {
    await initializeDatabase();

    try {
      final invoiceData = {
        'id': id,
        'clientId': clientId,
        'customerCode': customerCode,
        'customerName': customerName,
        'locaCode': locaCode,
        'unitNo': unitNo,
        'compId': compId,
        'invType': invType,
        'items': jsonEncode(items),
        'grandTotal': grandTotal.toDouble(),
        'createdAt': createdAt.toIso8601String(),
        'syncStatus': syncStatus,
        'syncError': syncError,
        'invoiceNo': invoiceNo,
        'serialNo': serialNo,
        'paymentType': paymentType,
        'cashPaid': cashPaid?.toDouble(),
        'cardPaid': cardPaid?.toDouble(),
        'creditPaid': creditPaid?.toDouble(),
        'bankTransferPaid': bankTransferPaid?.toDouble(),
        'holdStatus': holdStatus ?? 'NONE',
      };

      if (kIsWeb) {
        // Web: Use shared_preferences
        final invoices = _getWebInvoices();
        // Remove existing invoice with same id if any
        invoices.removeWhere((inv) => inv['id'] == id);
        invoices.add(invoiceData);
        await _saveWebInvoices(invoices);
      } else {
        // Mobile/Desktop: Use sqflite
        await _database!.insert(
          tableName,
          invoiceData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      print('Invoice saved locally with ID: $id');
    } catch (e) {
      print('Error saving invoice: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllInvoices() async {
    await initializeDatabase();
    try {
      if (kIsWeb) {
        return _getWebInvoices();
      } else {
        return await _database!.query(tableName);
      }
    } catch (e) {
      print('Error fetching all invoices: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPendingInvoices() async {
    await initializeDatabase();
    try {
      if (kIsWeb) {
        final allInvoices = _getWebInvoices();
        final pending =
            allInvoices.where((inv) => inv['syncStatus'] == 'PENDING').toList();
        print('Found ${pending.length} pending invoices');
        return pending;
      } else {
        final maps = await _database!.query(
          tableName,
          where: 'syncStatus = ?',
          whereArgs: ['PENDING'],
        );
        print('Found ${maps.length} pending invoices');
        return maps;
      }
    } catch (e) {
      print('Error fetching pending invoices: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHeldInvoices() async {
    await initializeDatabase();
    try {
      if (kIsWeb) {
        final allInvoices = _getWebInvoices();
        final held =
            allInvoices.where((inv) => inv['holdStatus'] == 'HELD').toList();
        // Sort by createdAt descending
        held.sort((a, b) {
          final aDate = a['createdAt'] as String? ?? '';
          final bDate = b['createdAt'] as String? ?? '';
          return bDate.compareTo(aDate);
        });
        print('Found ${held.length} held invoices');
        return held;
      } else {
        final maps = await _database!.query(
          tableName,
          where: 'holdStatus = ?',
          whereArgs: ['HELD'],
          orderBy: 'createdAt DESC',
        );
        print('Found ${maps.length} held invoices');
        return maps;
      }
    } catch (e) {
      print('Error fetching held invoices: $e');
      return [];
    }
  }

  Future<void> updateHoldStatus(String invoiceId, String holdStatus) async {
    await initializeDatabase();
    try {
      if (kIsWeb) {
        final invoices = _getWebInvoices();
        final index = invoices.indexWhere((inv) => inv['id'] == invoiceId);
        if (index != -1) {
          invoices[index]['holdStatus'] = holdStatus;
          await _saveWebInvoices(invoices);
        }
      } else {
        await _database!.update(
          tableName,
          {'holdStatus': holdStatus},
          where: 'id = ?',
          whereArgs: [invoiceId],
        );
      }
      print('Updated hold status for invoice: $invoiceId to $holdStatus');
    } catch (e) {
      print('Error updating hold status: $e');
      rethrow;
    }
  }

  Future<void> updateInvoiceSyncStatus(
    String invoiceId,
    String status, {
    String? invoiceNo,
    String? serialNo,
    String? error,
  }) async {
    await initializeDatabase();
    try {
      if (kIsWeb) {
        final invoices = _getWebInvoices();
        final index = invoices.indexWhere((inv) => inv['id'] == invoiceId);
        if (index != -1) {
          invoices[index]['syncStatus'] = status;
          if (invoiceNo != null) invoices[index]['invoiceNo'] = invoiceNo;
          if (serialNo != null) invoices[index]['serialNo'] = serialNo;
          if (error != null) invoices[index]['syncError'] = error;
          await _saveWebInvoices(invoices);
        }
      } else {
        await _database!.update(
          tableName,
          {
            'syncStatus': status,
            'invoiceNo': invoiceNo,
            'serialNo': serialNo,
            'syncError': error,
          },
          where: 'id = ?',
          whereArgs: [invoiceId],
        );
      }
      print('Invoice sync status updated: $invoiceId -> $status');
    } catch (e) {
      print('Error updating invoice sync status: $e');
      rethrow;
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    await initializeDatabase();
    try {
      if (kIsWeb) {
        final invoices = _getWebInvoices();
        invoices.removeWhere((inv) => inv['id'] == invoiceId);
        await _saveWebInvoices(invoices);
      } else {
        await _database!.delete(
          tableName,
          where: 'id = ?',
          whereArgs: [invoiceId],
        );
      }
      print('Invoice deleted: $invoiceId');
    } catch (e) {
      print('Error deleting invoice: $e');
      rethrow;
    }
  }

  Future<void> deleteAllInvoices() async {
    await initializeDatabase();
    try {
      if (kIsWeb) {
        await _prefs!.remove(_webStorageKey);
      } else {
        await _database!.delete(tableName);
      }
      print('All invoices deleted');
    } catch (e) {
      print('Error deleting all invoices: $e');
      rethrow;
    }
  }

  Future<int> getInvoiceCount() async {
    await initializeDatabase();
    try {
      if (kIsWeb) {
        return _getWebInvoices().length;
      } else {
        final count = await _database!
            .rawQuery('SELECT COUNT(*) as count FROM $tableName');
        return (count.first['count'] as int?) ?? 0;
      }
    } catch (e) {
      print('Error getting invoice count: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>?> getInvoiceById(String id) async {
    await initializeDatabase();
    try {
      if (kIsWeb) {
        final invoices = _getWebInvoices();
        try {
          return invoices.firstWhere((inv) => inv['id'] == id);
        } catch (e) {
          return null;
        }
      } else {
        final maps = await _database!.query(
          tableName,
          where: 'id = ?',
          whereArgs: [id],
        );
        if (maps.isNotEmpty) {
          return maps.first;
        }
        return null;
      }
    } catch (e) {
      print('Error fetching invoice by ID: $e');
      return null;
    }
  }

  Future<void> closeDatabase() async {
    try {
      if (_isInitialized && !kIsWeb) {
        await _database?.close();
        _isInitialized = false;
        print('Database closed');
      }
    } catch (e) {
      print('Error closing database: $e');
    }
  }
}
