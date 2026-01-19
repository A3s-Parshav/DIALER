import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:call_log/call_log.dart';

// GLOBAL RAM CACHE
List<Contact> globalMemoryCache = [];
List<CallLogEntry> globalCallLogCache = [];

class ContactService {
  static const String _storageKey = 'cached_contacts';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load from local storage (Instant)
    List<String>? cachedList = prefs.getStringList(_storageKey);

    if (cachedList != null && cachedList.isNotEmpty) {
      globalMemoryCache = cachedList
          .map((s) => Contact.fromJson(jsonDecode(s)))
          .toList();
    }

    // 2. Background Sync
    if (await FlutterContacts.requestPermission(readonly: true)) {
      final freshContacts = await FlutterContacts.getContacts(
        withProperties: true,
      );
      globalMemoryCache = freshContacts;

      final jsonList = freshContacts
          .map((c) => jsonEncode(c.toJson()))
          .toList();
      await prefs.setStringList(_storageKey, jsonList);
    }
  }

  static Future<void> fetchCallLogs() async {
    // Permission check for logs
    Iterable<CallLogEntry> entries = await CallLog.get();
    globalCallLogCache = entries.toList();
  }

  static Future<void> updateDiskCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = globalMemoryCache
        .map((c) => jsonEncode(c.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, jsonList);
  }
}
