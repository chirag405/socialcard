import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_profile.dart';
import '../models/saved_contact.dart';
import 'supabase_service.dart';

class ContactsService {
  static final ContactsService _instance = ContactsService._internal();
  factory ContactsService() => _instance;
  ContactsService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final SupabaseService _supabaseService = SupabaseService();

  // Request contact permission
  Future<bool> requestContactPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  // Check if contact permission is granted
  Future<bool> hasContactPermission() async {
    final status = await Permission.contacts.status;
    return status.isGranted;
  }

  // Import phone contacts
  Future<List<Contact>> importPhoneContacts() async {
    // Skip contact import on web
    if (kIsWeb) {
      return [];
    }

    if (!await hasContactPermission()) {
      final granted = await requestContactPermission();
      if (!granted) {
        throw Exception('Contact permission denied');
      }
    }

    try {
      final phoneContacts = await FlutterContacts.getContacts(
        withProperties: true,
      );
      return phoneContacts;
    } catch (e) {
      throw Exception('Failed to import contacts: $e');
    }
  }

  // Normalize phone number (remove spaces, special chars, country codes)
  String normalizePhoneNumber(String phone) {
    // Remove all non-digit characters
    String normalized = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Remove country code (assuming starts with 1 for US, 91 for India, etc)
    if (normalized.length > 10) {
      // Keep last 10 digits
      normalized = normalized.substring(normalized.length - 10);
    }

    return normalized;
  }

  // Match contacts with app users
  Future<List<MatchedContact>> matchContactsWithAppUsers(
    List<Contact> phoneContacts,
  ) async {
    List<MatchedContact> matchedContacts = [];

    // Extract all phone numbers from contacts
    Set<String> allPhoneNumbers = {};
    Map<String, Contact> phoneToContactMap = {};

    for (var contact in phoneContacts) {
      for (var phone in contact.phones) {
        String normalized = normalizePhoneNumber(phone.number);
        allPhoneNumbers.add(normalized);
        phoneToContactMap[normalized] = contact;
      }
    }

    // Query in batches (Supabase supports larger batches than Firestore)
    List<String> phoneList = allPhoneNumbers.toList();
    for (int i = 0; i < phoneList.length; i += 100) {
      int end = (i + 100 < phoneList.length) ? i + 100 : phoneList.length;
      List<String> batch = phoneList.sublist(i, end);

      try {
        // Query for users with matching normalized phone numbers who are discoverable
        final response = await _supabase
            .from('users')
            .select()
            .inFilter('normalized_phone', batch)
            .eq('is_discoverable', true);

        for (var userData in response) {
          final userProfile = UserProfile(
            id: userData['id'],
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            phone: userData['phone'],
            profileImageUrl: userData['profile_image_url'],
            bio: userData['bio'],
            customLinks: const [], // Will be loaded separately if needed
            isDiscoverable: userData['is_discoverable'] ?? true,
            createdAt: DateTime.parse(userData['created_at']),
            updatedAt: DateTime.parse(userData['updated_at']),
          );

          String? userPhone = userProfile.phone;

          if (userPhone != null) {
            String normalizedUserPhone = normalizePhoneNumber(userPhone);
            Contact? phoneContact = phoneToContactMap[normalizedUserPhone];

            if (phoneContact != null) {
              matchedContacts.add(
                MatchedContact(
                  phoneContact: phoneContact,
                  appUserProfile: userProfile,
                ),
              );
            }
          }
        }
      } catch (e) {
        print('Error matching batch: $e');
      }
    }

    return matchedContacts;
  }

  // Get all app users from contacts
  Future<List<UserProfile>> getAppUsersFromContacts() async {
    try {
      // Import phone contacts
      final phoneContacts = await importPhoneContacts();

      // Match with app users
      final matchedContacts = await matchContactsWithAppUsers(phoneContacts);

      // Extract user profiles
      return matchedContacts.map((match) => match.appUserProfile).toList();
    } catch (e) {
      throw Exception('Failed to get app users from contacts: $e');
    }
  }

  // Save contact when QR is scanned
  Future<void> saveScannedContact(String scannedUserId, {String? notes}) async {
    try {
      final currentUserId = _supabaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get the user profile of the scanned user
      final scannedUserProfile = await _supabaseService.getUserProfile(
        scannedUserId,
      );
      if (scannedUserProfile == null) {
        throw Exception('Scanned user not found');
      }

      // Create SavedContact object
      final savedContact = SavedContact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        profile: scannedUserProfile,
        scannedAt: DateTime.now(),
        notes: notes,
      );

      // Save to Supabase database
      await _supabaseService.saveScanedContact(savedContact);
    } catch (e) {
      throw Exception('Failed to save scanned contact: $e');
    }
  }

  // Get all saved contacts from Supabase
  Future<List<UserProfile>> getSavedContacts() async {
    try {
      final currentUserId = _supabaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final savedContacts = await _supabaseService.getSavedContacts();

      // Convert to UserProfile objects
      return savedContacts.map((contact) => contact.profile).toList();
    } catch (e) {
      throw Exception('Failed to get saved contacts: $e');
    }
  }

  // Check if contact is already saved
  Future<bool> isContactSaved(String scannedUserId) async {
    try {
      final currentUserId = _supabaseService.currentUserId;
      if (currentUserId == null) return false;

      return await _supabaseService.isContactSaved(scannedUserId);
    } catch (e) {
      return false;
    }
  }

  // Delete saved contact
  Future<void> deleteSavedContact(String scannedUserId) async {
    try {
      final currentUserId = _supabaseService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _supabaseService.deleteSavedContact(scannedUserId);
    } catch (e) {
      throw Exception('Failed to delete saved contact: $e');
    }
  }
}

// Model for matched contact
class MatchedContact {
  final Contact phoneContact;
  final UserProfile appUserProfile;

  MatchedContact({required this.phoneContact, required this.appUserProfile});
}
