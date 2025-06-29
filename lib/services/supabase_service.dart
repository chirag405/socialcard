import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_profile.dart';
import '../models/qr_link_config.dart';
import '../models/saved_contact.dart';
import '../supabase_config.dart';
import 'dart:math';

// Custom exception for slug collisions
class SlugCollisionException implements Exception {
  final String message;
  SlugCollisionException(this.message);

  @override
  String toString() => 'SlugCollisionException: $message';
}

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // Configure GoogleSignIn with client ID for web
  // TODO: Replace with your actual Google OAuth Client ID from Google Cloud Console
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? SupabaseConfig.googleClientIdWeb : null,
    // For mobile, credentials come from GoogleService-Info.plist (iOS) and google-services.json (Android)
  );

  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => _client.auth.currentUser?.id;

  // Initialize Supabase
  static Future<void> initialize() async {
    // Validate configuration before initializing
    SupabaseConfig.initialize();

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  // Authentication Methods
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        print('🔗 SupabaseService: Starting web OAuth with Google');
        print(
          '🔗 SupabaseService: Redirect URL: ${SupabaseConfig.redirectUrl}',
        );

        // For web, use Supabase's built-in Google OAuth with correct redirect
        final success = await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: SupabaseConfig.redirectUrl,
        );

        print('🔗 SupabaseService: OAuth initiation success: $success');
        return null; // OAuth redirect doesn't return AuthResponse directly
      }

      // For mobile platforms, use google_sign_in for better UX
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        await _createOrUpdateUserProfile(response.user!);
      }

      return response;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  Future<AuthResponse?> signInWithPhoneNumber(String phoneNumber) async {
    try {
      await _client.auth.signInWithOtp(phone: phoneNumber);
      return null; // OTP sends SMS, doesn't return user immediately
    } catch (e) {
      throw Exception('Phone sign-in failed: $e');
    }
  }

  Future<AuthResponse?> verifyPhoneOTP(String phoneNumber, String token) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phoneNumber,
        token: token,
        type: OtpType.sms,
      );

      if (response.user != null) {
        await _createOrUpdateUserProfile(response.user!);
      }

      return response;
    } catch (e) {
      throw Exception('Phone verification failed: $e');
    }
  }

  Future<void> signOut() async {
    await Future.wait([_client.auth.signOut(), _googleSignIn.signOut()]);
  }

  // User Profile Methods
  Future<void> createOrUpdateUserProfile(User user) async {
    try {
      print(
        '🔗 SupabaseService: Creating/updating profile for user: ${user.id}',
      );

      // Check if user profile exists
      final existingProfile =
          await _client.from('users').select().eq('id', user.id).maybeSingle();

      final now = DateTime.now();
      final profileData = {
        'id': user.id,
        'name':
            user.userMetadata?['full_name'] ?? user.email?.split('@')[0] ?? '',
        'email': user.email ?? '',
        'phone': user.phone,
        'profile_image_url': user.userMetadata?['avatar_url'],
        'bio': null,
        'is_discoverable': true,
        'updated_at': now.toIso8601String(),
      };

      // Add normalized phone for queries
      if (user.phone != null && user.phone!.isNotEmpty) {
        String normalized = user.phone!.replaceAll(RegExp(r'[^\d]'), '');
        if (normalized.length > 10) {
          normalized = normalized.substring(normalized.length - 10);
        }
        profileData['normalized_phone'] = normalized;
      }

      if (existingProfile == null) {
        print('🔗 SupabaseService: Creating new user profile');
        profileData['created_at'] = now.toIso8601String();
        await _client.from('users').insert(profileData);
        print('🔗 SupabaseService: New user profile created successfully');
      } else {
        print('🔗 SupabaseService: Updating existing user profile');
        await _client
            .from('users')
            .update({
              'name':
                  user.userMetadata?['full_name'] ??
                  existingProfile['name'] ??
                  '',
              'email': user.email ?? existingProfile['email'] ?? '',
              'phone': user.phone ?? existingProfile['phone'],
              'profile_image_url':
                  user.userMetadata?['avatar_url'] ??
                  existingProfile['profile_image_url'],
              'updated_at': now.toIso8601String(),
            })
            .eq('id', user.id);
        print('🔗 SupabaseService: User profile updated successfully');
      }
    } catch (e) {
      print('🔗 SupabaseService: Error creating/updating user profile: $e');
      throw Exception('Failed to create/update user profile: $e');
    }
  }

  Future<void> _createOrUpdateUserProfile(User user) async {
    return createOrUpdateUserProfile(user);
  }

  Future<bool> isNewUser(String userId) async {
    try {
      final profile =
          await _client.from('users').select().eq('id', userId).maybeSingle();
      return profile == null;
    } catch (e) {
      print('🔗 SupabaseService: Error checking if user is new: $e');
      return false;
    }
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      print('🔗 SupabaseService: Getting user profile for userId: $userId');

      final data =
          await _client
              .from('users')
              .select('*, custom_links(*)')
              .eq('id', userId)
              .maybeSingle();

      if (data != null) {
        try {
          // Convert Supabase data to UserProfile
          final customLinks =
              (data['custom_links'] as List<dynamic>?)
                  ?.map(
                    (link) => CustomLink.fromMap({
                      'id': link['id'],
                      'url': link['url'],
                      'displayName': link['display_name'],
                      'iconName': link['icon_name'],
                      'order': link['order_index'],
                    }),
                  )
                  .toList() ??
              [];

          final profile = UserProfile(
            id: data['id'],
            name: data['name'] ?? '',
            email: data['email'] ?? '',
            phone: data['phone'],
            profileImageUrl: data['profile_image_url'],
            bio: data['bio'],
            customLinks: customLinks,
            isDiscoverable: data['is_discoverable'] ?? true,
            createdAt: DateTime.parse(data['created_at']),
            updatedAt: DateTime.parse(data['updated_at']),
          );

          print(
            '🔗 SupabaseService: Profile parsed successfully: ${profile.name}, ${profile.email}',
          );
          return profile;
        } catch (parseError) {
          print('🔗 SupabaseService: Error parsing profile data: $parseError');
          print('🔗 SupabaseService: Raw data: $data');
          throw Exception('Failed to parse profile data: $parseError');
        }
      }

      print('🔗 SupabaseService: No profile found for userId: $userId');
      return null;
    } catch (e) {
      print('🔗 SupabaseService: Error getting user profile: $e');
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      if (currentUserId == null || currentUserId != profile.id) {
        throw Exception('Unauthorized: Cannot update another user\'s profile');
      }

      // Update user profile
      final profileData = {
        'name': profile.name,
        'email': profile.email,
        'phone': profile.phone,
        'profile_image_url': profile.profileImageUrl,
        'bio': profile.bio,
        'is_discoverable': profile.isDiscoverable,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add normalized phone for queries
      if (profile.phone != null && profile.phone!.isNotEmpty) {
        String normalized = profile.phone!.replaceAll(RegExp(r'[^\d]'), '');
        if (normalized.length > 10) {
          normalized = normalized.substring(normalized.length - 10);
        }
        profileData['normalized_phone'] = normalized;
      } else {
        profileData['normalized_phone'] = null;
      }

      await _client.from('users').update(profileData).eq('id', profile.id);

      // Update custom links
      // First, delete existing custom links
      await _client.from('custom_links').delete().eq('user_id', profile.id);

      // Then, insert new custom links
      if (profile.customLinks.isNotEmpty) {
        final customLinksData =
            profile.customLinks
                .map(
                  (link) => {
                    'id': link.id,
                    'user_id': profile.id,
                    'url': link.url,
                    'display_name': link.displayName,
                    'icon_name': link.iconName,
                    'order_index': link.order,
                    'created_at': DateTime.now().toIso8601String(),
                    'updated_at': DateTime.now().toIso8601String(),
                  },
                )
                .toList();

        await _client.from('custom_links').insert(customLinksData);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Stream<UserProfile?> getUserProfileStream(String userId) {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) {
          if (data.isNotEmpty) {
            final userData = data.first;
            return UserProfile(
              id: userData['id'],
              name: userData['name'] ?? '',
              email: userData['email'] ?? '',
              phone: userData['phone'],
              profileImageUrl: userData['profile_image_url'],
              bio: userData['bio'],
              customLinks:
                  const [], // Custom links need separate query for stream
              isDiscoverable: userData['is_discoverable'] ?? true,
              createdAt: DateTime.parse(userData['created_at']),
              updatedAt: DateTime.parse(userData['updated_at']),
            );
          }
          return null;
        });
  }

  // QR Link Config Methods
  Future<void> createQrLinkConfig(QrLinkConfig config) async {
    try {
      if (currentUserId == null || currentUserId != config.userId) {
        throw Exception('Unauthorized: Cannot create config for another user');
      }

      final configData = {
        'id': config.id,
        'user_id': config.userId,
        'link_slug': config.linkSlug,
        'description': config.description,
        'selected_link_ids': config.selectedLinkIds,
        'qr_customization': config.qrCustomization.toMap(),
        'expiry_settings': config.expirySettings.toMap(),
        'is_active': config.isActive,
        'scan_count': config.scanCount,
        'created_at': config.createdAt.toIso8601String(),
        'updated_at': config.updatedAt.toIso8601String(),
      };

      await _client.from('qr_configs').insert(configData);
    } catch (e) {
      throw Exception('Failed to create QR config: $e');
    }
  }

  Future<void> updateQrLinkConfig(QrLinkConfig config) async {
    try {
      if (currentUserId == null || currentUserId != config.userId) {
        throw Exception('Unauthorized: Cannot update another user\'s config');
      }

      final configData = {
        'description': config.description,
        'selected_link_ids': config.selectedLinkIds,
        'qr_customization': config.qrCustomization.toMap(),
        'expiry_settings': config.expirySettings.toMap(),
        'is_active': config.isActive,
        'scan_count': config.scanCount,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('qr_configs').update(configData).eq('id', config.id);
    } catch (e) {
      throw Exception('Failed to update QR config: $e');
    }
  }

  Future<QrLinkConfig?> getQrLinkConfig(String configId) async {
    try {
      final data =
          await _client
              .from('qr_configs')
              .select()
              .eq('id', configId)
              .maybeSingle();

      if (data != null) {
        return QrLinkConfig.fromMap({
          'id': data['id'],
          'userId': data['user_id'],
          'linkSlug': data['link_slug'],
          'description': data['description'],
          'selectedLinkIds': List<String>.from(data['selected_link_ids'] ?? []),
          'qrCustomization': data['qr_customization'],
          'expirySettings': data['expiry_settings'],
          'isActive': data['is_active'],
          'scanCount': data['scan_count'],
          'createdAt':
              DateTime.parse(data['created_at']).millisecondsSinceEpoch,
          'updatedAt':
              DateTime.parse(data['updated_at']).millisecondsSinceEpoch,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get QR config: $e');
    }
  }

  Future<QrLinkConfig?> getQrLinkConfigBySlug(String slug) async {
    try {
      final data =
          await _client
              .from('qr_configs')
              .select()
              .eq('link_slug', slug)
              .eq('is_active', true)
              .maybeSingle();

      if (data != null) {
        final config = QrLinkConfig.fromMap({
          'id': data['id'],
          'userId': data['user_id'],
          'linkSlug': data['link_slug'],
          'description': data['description'],
          'selectedLinkIds': List<String>.from(data['selected_link_ids'] ?? []),
          'qrCustomization': data['qr_customization'],
          'expirySettings': data['expiry_settings'],
          'isActive': data['is_active'],
          'scanCount': data['scan_count'],
          'createdAt':
              DateTime.parse(data['created_at']).millisecondsSinceEpoch,
          'updatedAt':
              DateTime.parse(data['updated_at']).millisecondsSinceEpoch,
        });

        // Check if expired
        if (config.isExpired) {
          // Deactivate expired config
          await _client
              .from('qr_configs')
              .update({'is_active': false})
              .eq('id', config.id);
          return null;
        }

        return config;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get QR config by slug: $e');
    }
  }

  Future<void> incrementScanCount(String configId) async {
    try {
      // Get current scan count
      final currentData =
          await _client
              .from('qr_configs')
              .select('scan_count')
              .eq('id', configId)
              .single();

      final currentCount = currentData['scan_count'] ?? 0;

      await _client
          .from('qr_configs')
          .update({'scan_count': currentCount + 1})
          .eq('id', configId);
    } catch (e) {
      throw Exception('Failed to increment scan count: $e');
    }
  }

  Stream<List<QrLinkConfig>> getUserQrConfigs(String userId) {
    return _client
        .from('qr_configs')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map(
          (data) =>
              data
                  .map(
                    (item) => QrLinkConfig.fromMap({
                      'id': item['id'],
                      'userId': item['user_id'],
                      'linkSlug': item['link_slug'],
                      'description': item['description'],
                      'selectedLinkIds': List<String>.from(
                        item['selected_link_ids'] ?? [],
                      ),
                      'qrCustomization': item['qr_customization'],
                      'expirySettings': item['expiry_settings'],
                      'isActive': item['is_active'],
                      'scanCount': item['scan_count'],
                      'createdAt':
                          DateTime.parse(
                            item['created_at'],
                          ).millisecondsSinceEpoch,
                      'updatedAt':
                          DateTime.parse(
                            item['updated_at'],
                          ).millisecondsSinceEpoch,
                    }),
                  )
                  .toList(),
        );
  }

  Future<void> deleteQrLinkConfig(String configId) async {
    try {
      final config = await getQrLinkConfig(configId);
      if (config == null) return;

      if (currentUserId == null || currentUserId != config.userId) {
        throw Exception('Unauthorized: Cannot delete another user\'s config');
      }

      await _client.from('qr_configs').delete().eq('id', configId);
    } catch (e) {
      throw Exception('Failed to delete QR config: $e');
    }
  }

  // Check if slug is available
  Future<bool> isSlugAvailable(String slug) async {
    try {
      final data =
          await _client
              .from('qr_configs')
              .select('id')
              .eq('link_slug', slug)
              .eq('is_active', true)
              .maybeSingle();

      return data == null;
    } catch (e) {
      return false;
    }
  }

  // Visit tracking
  Future<void> trackQrVisit(
    String configId,
    String? userAgent,
    String? ipAddress,
  ) async {
    try {
      await _client.from('qr_visits').insert({
        'config_id': configId,
        'user_agent': userAgent,
        'ip_address': ipAddress,
        'visited_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to track visit: $e');
      // Don't throw error for visit tracking failures
    }
  }

  // Missing method: createQrLinkConfigWithRetry
  Future<QrLinkConfig> createQrLinkConfigWithRetry(QrLinkConfig config) async {
    int maxRetries = 5;
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        await createQrLinkConfig(config);
        return config; // Return the config after successful creation
      } catch (e) {
        if (e.toString().contains('slug collision') ||
            e is SlugCollisionException) {
          if (attempt == maxRetries - 1) {
            throw SlugCollisionException(
              'Unable to generate unique slug after $maxRetries attempts',
            );
          }
          // Generate a new slug and retry
          config = config.copyWith(linkSlug: _generateRandomSlug());
          continue;
        }
        rethrow;
      }
    }
    throw Exception('Max retries exceeded');
  }

  // Missing method: getQrConfigBySlug (alias for getQrLinkConfigBySlug)
  Future<QrLinkConfig?> getQrConfigBySlug(String slug) async {
    return await getQrLinkConfigBySlug(slug);
  }

  // Missing method: saveScanedContact
  Future<void> saveScanedContact(SavedContact contact) async {
    try {
      await _client.from('saved_contacts').insert({
        'user_id': currentUserId,
        'profile': contact.profile.toMap(),
        'scanned_at': contact.scannedAt.toIso8601String(),
        'last_updated': contact.lastUpdated?.toIso8601String(),
        'has_updates': contact.hasUpdates,
        'notes': contact.notes,
      });
    } catch (e) {
      throw Exception('Failed to save contact: $e');
    }
  }

  // Missing method: getSavedContacts
  Future<List<SavedContact>> getSavedContacts() async {
    try {
      final data = await _client
          .from('saved_contacts')
          .select()
          .eq('user_id', currentUserId!)
          .order('saved_at', ascending: false);

      return data.map((item) => SavedContact.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Failed to get saved contacts: $e');
    }
  }

  // Missing method: isContactSaved
  Future<bool> isContactSaved(String qrConfigId) async {
    try {
      final data =
          await _client
              .from('saved_contacts')
              .select('id')
              .eq('user_id', currentUserId!)
              .eq('qr_config_id', qrConfigId)
              .maybeSingle();

      return data != null;
    } catch (e) {
      return false;
    }
  }

  // Missing method: deleteSavedContact
  Future<void> deleteSavedContact(String contactId) async {
    try {
      await _client
          .from('saved_contacts')
          .delete()
          .eq('id', contactId)
          .eq('user_id', currentUserId!);
    } catch (e) {
      throw Exception('Failed to delete contact: $e');
    }
  }

  // Helper method: generate random slug
  String _generateRandomSlug() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        8,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
