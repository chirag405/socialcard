import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/saved_contact.dart';
import '../models/qr_preset.dart';
import '../models/qr_link_config.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Database? _database;
  SharedPreferences? _prefs;

  // Platform-aware database getter
  Future<Database?> get database async {
    if (kIsWeb) {
      return null; // Don't use SQLite on web
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Platform-aware preferences getter
  Future<SharedPreferences> get preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web platform');
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'socialcard.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE saved_contacts(
        id TEXT PRIMARY KEY,
        profile_data TEXT NOT NULL,
        scanned_at INTEGER NOT NULL,
        last_updated INTEGER,
        has_updates INTEGER NOT NULL DEFAULT 0,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE qr_presets(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        selected_link_ids TEXT NOT NULL,
        qr_customization TEXT NOT NULL,
        expiry_settings TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE qr_configs(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        link_slug TEXT NOT NULL,
        description TEXT,
        selected_link_ids TEXT NOT NULL,
        qr_customization TEXT NOT NULL,
        expiry_settings TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        scan_count INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE qr_presets(
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          selected_link_ids TEXT NOT NULL,
          qr_customization TEXT NOT NULL,
          expiry_settings TEXT NOT NULL,
          is_default INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE qr_configs(
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          link_slug TEXT NOT NULL,
          description TEXT,
          selected_link_ids TEXT NOT NULL,
          qr_customization TEXT NOT NULL,
          expiry_settings TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          scan_count INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
    }
  }

  // Platform-aware saved contacts methods
  Future<void> saveScanedContact(SavedContact contact) async {
    if (kIsWeb) {
      await _saveContactToPrefs(contact);
    } else {
      await _saveContactToDb(contact);
    }
  }

  Future<List<SavedContact>> getAllSavedContacts() async {
    if (kIsWeb) {
      return await _getContactsFromPrefs();
    } else {
      return await _getContactsFromDb();
    }
  }

  Future<SavedContact?> getSavedContact(String contactId) async {
    if (kIsWeb) {
      return await _getContactFromPrefs(contactId);
    } else {
      return await _getContactFromDb(contactId);
    }
  }

  Future<void> updateSavedContact(SavedContact contact) async {
    if (kIsWeb) {
      await _updateContactInPrefs(contact);
    } else {
      await _updateContactInDb(contact);
    }
  }

  Future<void> deleteSavedContact(String contactId) async {
    if (kIsWeb) {
      await _deleteContactFromPrefs(contactId);
    } else {
      await _deleteContactFromDb(contactId);
    }
  }

  Future<void> markContactAsUpdated(String contactId, bool hasUpdates) async {
    if (kIsWeb) {
      await _markContactUpdatedInPrefs(contactId, hasUpdates);
    } else {
      await _markContactUpdatedInDb(contactId, hasUpdates);
    }
  }

  Future<bool> isContactSaved(String profileId) async {
    if (kIsWeb) {
      return await _isContactSavedInPrefs(profileId);
    } else {
      return await _isContactSavedInDb(profileId);
    }
  }

  // SQLite implementations (mobile)
  Future<void> _saveContactToDb(SavedContact contact) async {
    final db = await database;
    if (db == null) return;

    await db.insert('saved_contacts', {
      'id': contact.id,
      'profile_data': jsonEncode(contact.profile.toMap()),
      'scanned_at': contact.scannedAt.millisecondsSinceEpoch,
      'last_updated': contact.lastUpdated?.millisecondsSinceEpoch,
      'has_updates': contact.hasUpdates ? 1 : 0,
      'notes': contact.notes,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SavedContact>> _getContactsFromDb() async {
    final db = await database;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'saved_contacts',
      orderBy: 'scanned_at DESC',
    );

    return maps.map((map) => _mapToSavedContact(map)).toList();
  }

  Future<SavedContact?> _getContactFromDb(String contactId) async {
    final db = await database;
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      'saved_contacts',
      where: 'id = ?',
      whereArgs: [contactId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _mapToSavedContact(maps.first);
    }
    return null;
  }

  Future<void> _updateContactInDb(SavedContact contact) async {
    final db = await database;
    if (db == null) return;

    await db.update(
      'saved_contacts',
      {
        'profile_data': jsonEncode(contact.profile.toMap()),
        'last_updated': contact.lastUpdated?.millisecondsSinceEpoch,
        'has_updates': contact.hasUpdates ? 1 : 0,
        'notes': contact.notes,
      },
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<void> _deleteContactFromDb(String contactId) async {
    final db = await database;
    if (db == null) return;

    await db.delete('saved_contacts', where: 'id = ?', whereArgs: [contactId]);
  }

  Future<void> _markContactUpdatedInDb(
    String contactId,
    bool hasUpdates,
  ) async {
    final db = await database;
    if (db == null) return;

    await db.update(
      'saved_contacts',
      {'has_updates': hasUpdates ? 1 : 0},
      where: 'id = ?',
      whereArgs: [contactId],
    );
  }

  Future<bool> _isContactSavedInDb(String profileId) async {
    final db = await database;
    if (db == null) return false;

    final List<Map<String, dynamic>> maps = await db.query(
      'saved_contacts',
      where: 'id = ?',
      whereArgs: [profileId],
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  // SharedPreferences implementations (web)
  Future<void> _saveContactToPrefs(SavedContact contact) async {
    final prefs = await preferences;
    final contacts = await _getContactsFromPrefs();

    // Remove existing contact with same ID
    contacts.removeWhere((c) => c.id == contact.id);
    contacts.add(contact);

    final contactsJson = contacts.map((c) => c.toMap()).toList();
    await prefs.setString('saved_contacts', jsonEncode(contactsJson));
  }

  Future<List<SavedContact>> _getContactsFromPrefs() async {
    final prefs = await preferences;
    final contactsJson = prefs.getString('saved_contacts');

    if (contactsJson == null) return [];

    final List<dynamic> contactsList = jsonDecode(contactsJson);
    return contactsList.map((c) => SavedContact.fromMap(c)).toList();
  }

  Future<SavedContact?> _getContactFromPrefs(String contactId) async {
    final contacts = await _getContactsFromPrefs();
    try {
      return contacts.firstWhere((c) => c.id == contactId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateContactInPrefs(SavedContact contact) async {
    await _saveContactToPrefs(contact); // Same as save for SharedPreferences
  }

  Future<void> _deleteContactFromPrefs(String contactId) async {
    final prefs = await preferences;
    final contacts = await _getContactsFromPrefs();

    contacts.removeWhere((c) => c.id == contactId);

    final contactsJson = contacts.map((c) => c.toMap()).toList();
    await prefs.setString('saved_contacts', jsonEncode(contactsJson));
  }

  Future<void> _markContactUpdatedInPrefs(
    String contactId,
    bool hasUpdates,
  ) async {
    final contacts = await _getContactsFromPrefs();
    final contactIndex = contacts.indexWhere((c) => c.id == contactId);

    if (contactIndex != -1) {
      contacts[contactIndex] = contacts[contactIndex].copyWith(
        hasUpdates: hasUpdates,
      );

      final prefs = await preferences;
      final contactsJson = contacts.map((c) => c.toMap()).toList();
      await prefs.setString('saved_contacts', jsonEncode(contactsJson));
    }
  }

  Future<bool> _isContactSavedInPrefs(String profileId) async {
    final contacts = await _getContactsFromPrefs();
    return contacts.any((c) => c.id == profileId);
  }

  SavedContact _mapToSavedContact(Map<String, dynamic> map) {
    return SavedContact.fromMap({
      'id': map['id'],
      'profile': jsonDecode(map['profile_data']),
      'scannedAt': map['scanned_at'],
      'lastUpdated': map['last_updated'],
      'hasUpdates': map['has_updates'] == 1,
      'notes': map['notes'],
    });
  }

  // QR Presets methods (platform-aware)
  Future<void> saveQrPreset(QrPreset preset) async {
    if (kIsWeb) {
      await _savePresetToPrefs(preset);
    } else {
      await _savePresetToDb(preset);
    }
  }

  Future<List<QrPreset>> getAllQrPresets(String userId) async {
    if (kIsWeb) {
      return await _getPresetsFromPrefs(userId);
    } else {
      return await _getPresetsFromDb(userId);
    }
  }

  Future<QrPreset?> getQrPreset(String presetId) async {
    if (kIsWeb) {
      return await _getPresetFromPrefs(presetId);
    } else {
      return await _getPresetFromDb(presetId);
    }
  }

  Future<void> updateQrPreset(QrPreset preset) async {
    if (kIsWeb) {
      await _updatePresetInPrefs(preset);
    } else {
      await _updatePresetInDb(preset);
    }
  }

  Future<void> deleteQrPreset(String presetId) async {
    if (kIsWeb) {
      await _deletePresetFromPrefs(presetId);
    } else {
      await _deletePresetFromDb(presetId);
    }
  }

  // QR Presets SQLite implementations
  Future<void> _savePresetToDb(QrPreset preset) async {
    final db = await database;
    if (db == null) return;

    await db.insert('qr_presets', {
      'id': preset.id,
      'user_id': preset.userId,
      'name': preset.name,
      'description': preset.description,
      'selected_link_ids': jsonEncode(preset.selectedLinkIds),
      'qr_customization': jsonEncode(preset.qrCustomization.toMap()),
      'expiry_settings': jsonEncode(preset.expirySettings.toMap()),
      'is_default': preset.isDefault ? 1 : 0,
      'created_at': preset.createdAt.millisecondsSinceEpoch,
      'updated_at': preset.updatedAt.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<QrPreset>> _getPresetsFromDb(String userId) async {
    final db = await database;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'qr_presets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _mapToQrPreset(map)).toList();
  }

  Future<QrPreset?> _getPresetFromDb(String presetId) async {
    final db = await database;
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      'qr_presets',
      where: 'id = ?',
      whereArgs: [presetId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _mapToQrPreset(maps.first);
    }
    return null;
  }

  Future<void> _updatePresetInDb(QrPreset preset) async {
    final db = await database;
    if (db == null) return;

    await db.update(
      'qr_presets',
      {
        'name': preset.name,
        'description': preset.description,
        'selected_link_ids': jsonEncode(preset.selectedLinkIds),
        'qr_customization': jsonEncode(preset.qrCustomization.toMap()),
        'expiry_settings': jsonEncode(preset.expirySettings.toMap()),
        'is_default': preset.isDefault ? 1 : 0,
        'updated_at': preset.updatedAt.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [preset.id],
    );
  }

  Future<void> _deletePresetFromDb(String presetId) async {
    final db = await database;
    if (db == null) return;

    await db.delete('qr_presets', where: 'id = ?', whereArgs: [presetId]);
  }

  // QR Presets SharedPreferences implementations
  Future<void> _savePresetToPrefs(QrPreset preset) async {
    final prefs = await preferences;
    final presets = await _getAllPresetsFromPrefs();

    // Remove existing preset with same ID
    presets.removeWhere((p) => p.id == preset.id);
    presets.add(preset);

    final presetsJson = presets.map((p) => p.toMap()).toList();
    await prefs.setString('qr_presets', jsonEncode(presetsJson));
  }

  Future<List<QrPreset>> _getPresetsFromPrefs(String userId) async {
    final allPresets = await _getAllPresetsFromPrefs();
    return allPresets.where((p) => p.userId == userId).toList();
  }

  Future<List<QrPreset>> _getAllPresetsFromPrefs() async {
    final prefs = await preferences;
    final presetsJson = prefs.getString('qr_presets');

    if (presetsJson == null) return [];

    final List<dynamic> presetsList = jsonDecode(presetsJson);
    return presetsList.map((p) => QrPreset.fromMap(p)).toList();
  }

  Future<QrPreset?> _getPresetFromPrefs(String presetId) async {
    final presets = await _getAllPresetsFromPrefs();
    try {
      return presets.firstWhere((p) => p.id == presetId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _updatePresetInPrefs(QrPreset preset) async {
    await _savePresetToPrefs(preset); // Same as save for SharedPreferences
  }

  Future<void> _deletePresetFromPrefs(String presetId) async {
    final prefs = await preferences;
    final presets = await _getAllPresetsFromPrefs();

    presets.removeWhere((p) => p.id == presetId);

    final presetsJson = presets.map((p) => p.toMap()).toList();
    await prefs.setString('qr_presets', jsonEncode(presetsJson));
  }

  QrPreset _mapToQrPreset(Map<String, dynamic> map) {
    return QrPreset(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      description: map['description'] ?? '',
      selectedLinkIds: List<String>.from(jsonDecode(map['selected_link_ids'])),
      qrCustomization: QrCustomization.fromMap(
        jsonDecode(map['qr_customization']),
      ),
      expirySettings: ExpirySettings.fromMap(
        jsonDecode(map['expiry_settings']),
      ),
      isDefault: map['is_default'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  // QR Configs methods (platform-aware)
  Future<void> saveQrConfig(QrLinkConfig config) async {
    if (kIsWeb) {
      await _saveConfigToPrefs(config);
    } else {
      await _saveConfigToDb(config);
    }
  }

  Future<List<QrLinkConfig>> getAllQrConfigs(String userId) async {
    if (kIsWeb) {
      return await _getConfigsFromPrefs(userId);
    } else {
      return await _getConfigsFromDb(userId);
    }
  }

  Future<void> deleteQrConfig(String configId) async {
    if (kIsWeb) {
      await _deleteConfigFromPrefs(configId);
    } else {
      await _deleteConfigFromDb(configId);
    }
  }

  // QR Configs SQLite implementations
  Future<void> _saveConfigToDb(QrLinkConfig config) async {
    final db = await database;
    if (db == null) return;

    await db.insert('qr_configs', {
      'id': config.id,
      'user_id': config.userId,
      'link_slug': config.linkSlug,
      'description': config.description,
      'selected_link_ids': jsonEncode(config.selectedLinkIds),
      'qr_customization': jsonEncode(config.qrCustomization.toMap()),
      'expiry_settings': jsonEncode(config.expirySettings.toMap()),
      'is_active': config.isActive ? 1 : 0,
      'scan_count': config.scanCount,
      'created_at': config.createdAt.millisecondsSinceEpoch,
      'updated_at': config.updatedAt.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<QrLinkConfig>> _getConfigsFromDb(String userId) async {
    final db = await database;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'qr_configs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => _mapToQrConfig(map)).toList();
  }

  Future<void> _deleteConfigFromDb(String configId) async {
    final db = await database;
    if (db == null) return;

    await db.delete('qr_configs', where: 'id = ?', whereArgs: [configId]);
  }

  // QR Configs SharedPreferences implementations
  Future<void> _saveConfigToPrefs(QrLinkConfig config) async {
    final prefs = await preferences;
    final configs = await _getAllConfigsFromPrefs();

    // Remove existing config with same ID
    configs.removeWhere((c) => c.id == config.id);
    configs.add(config);

    final configsJson = configs.map((c) => c.toMap()).toList();
    await prefs.setString('qr_configs', jsonEncode(configsJson));
  }

  Future<List<QrLinkConfig>> _getConfigsFromPrefs(String userId) async {
    final allConfigs = await _getAllConfigsFromPrefs();
    return allConfigs.where((c) => c.userId == userId).toList();
  }

  Future<List<QrLinkConfig>> _getAllConfigsFromPrefs() async {
    final prefs = await preferences;
    final configsJson = prefs.getString('qr_configs');

    if (configsJson == null) return [];

    final List<dynamic> configsList = jsonDecode(configsJson);
    return configsList.map((c) => QrLinkConfig.fromMap(c)).toList();
  }

  Future<void> _deleteConfigFromPrefs(String configId) async {
    final prefs = await preferences;
    final configs = await _getAllConfigsFromPrefs();

    configs.removeWhere((c) => c.id == configId);

    final configsJson = configs.map((c) => c.toMap()).toList();
    await prefs.setString('qr_configs', jsonEncode(configsJson));
  }

  QrLinkConfig _mapToQrConfig(Map<String, dynamic> map) {
    return QrLinkConfig(
      id: map['id'],
      userId: map['user_id'],
      linkSlug: map['link_slug'],
      description: map['description'] ?? '',
      selectedLinkIds: List<String>.from(jsonDecode(map['selected_link_ids'])),
      qrCustomization: QrCustomization.fromMap(
        jsonDecode(map['qr_customization']),
      ),
      expirySettings: ExpirySettings.fromMap(
        jsonDecode(map['expiry_settings']),
      ),
      isActive: map['is_active'] == 1,
      scanCount: map['scan_count'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }
}
