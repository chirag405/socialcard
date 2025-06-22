import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../services/supabase_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final SupabaseService _supabaseService;
  final Uuid _uuid = const Uuid();

  ProfileBloc({required SupabaseService supabaseService})
    : _supabaseService = supabaseService,
      super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileImageUpdateRequested>(_onProfileImageUpdateRequested);
    on<CustomLinkAdded>(_onCustomLinkAdded);
    on<CustomLinkUpdated>(_onCustomLinkUpdated);
    on<CustomLinkRemoved>(_onCustomLinkRemoved);
    on<CustomLinksReordered>(_onCustomLinksReordered);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    print('🔥 ProfileBloc: Loading profile for userId: ${event.userId}');
    emit(ProfileLoading());
    try {
      final profile = await _supabaseService.getUserProfile(event.userId);
      print(
        '🔥 ProfileBloc: Profile loaded: ${profile?.name}, ${profile?.email}',
      );
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        print('🔥 ProfileBloc: Profile not found, creating default profile');
        // Create a basic profile if none exists
        final currentUser = _supabaseService.currentUser;
        if (currentUser != null) {
          await _supabaseService.createOrUpdateUserProfile(currentUser);
          // Try loading again after creation
          final newProfile = await _supabaseService.getUserProfile(
            event.userId,
          );
          if (newProfile != null) {
            emit(ProfileLoaded(newProfile));
          } else {
            emit(const ProfileError('Failed to create profile'));
          }
        } else {
          emit(const ProfileError('User not authenticated'));
        }
      }
    } catch (e) {
      print('🔥 ProfileBloc: Error loading profile: $e');
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      emit(ProfileUpdating(event.profile));
    }

    try {
      await _supabaseService.updateUserProfile(event.profile);
      emit(ProfileUpdated(event.profile));
      emit(ProfileLoaded(event.profile));
    } catch (e) {
      emit(
        ProfileError('Failed to update profile: $e', profile: event.profile),
      );
    }
  }

  Future<void> _onProfileImageUpdateRequested(
    ProfileImageUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;

    final currentProfile = (state as ProfileLoaded).profile;
    emit(ProfileUpdating(currentProfile));

    try {
      // TODO: Implement image upload to Supabase Storage
      // For now, we'll just update with the local path
      final updatedProfile = currentProfile.copyWith(
        profileImageUrl: event.imagePath,
        updatedAt: DateTime.now(),
      );

      await _supabaseService.updateUserProfile(updatedProfile);
      emit(ProfileUpdated(updatedProfile));
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(
        ProfileError(
          'Failed to update profile image: $e',
          profile: currentProfile,
        ),
      );
    }
  }

  Future<void> _onCustomLinkAdded(
    CustomLinkAdded event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;

    final currentProfile = (state as ProfileLoaded).profile;
    final newLink = event.link.copyWith(
      id: _uuid.v4(),
      order: currentProfile.customLinks.length,
    );

    final updatedLinks = [...currentProfile.customLinks, newLink];
    final updatedProfile = currentProfile.copyWith(
      customLinks: updatedLinks,
      updatedAt: DateTime.now(),
    );

    emit(ProfileUpdating(updatedProfile));

    try {
      await _supabaseService.updateUserProfile(updatedProfile);
      emit(ProfileUpdated(updatedProfile));
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(
        ProfileError('Failed to add custom link: $e', profile: currentProfile),
      );
    }
  }

  Future<void> _onCustomLinkUpdated(
    CustomLinkUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;

    final currentProfile = (state as ProfileLoaded).profile;
    final updatedLinks =
        currentProfile.customLinks.map((link) {
          return link.id == event.link.id ? event.link : link;
        }).toList();

    final updatedProfile = currentProfile.copyWith(
      customLinks: updatedLinks,
      updatedAt: DateTime.now(),
    );

    emit(ProfileUpdating(updatedProfile));

    try {
      await _supabaseService.updateUserProfile(updatedProfile);
      emit(ProfileUpdated(updatedProfile));
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(
        ProfileError(
          'Failed to update custom link: $e',
          profile: currentProfile,
        ),
      );
    }
  }

  Future<void> _onCustomLinkRemoved(
    CustomLinkRemoved event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;

    final currentProfile = (state as ProfileLoaded).profile;
    final updatedLinks =
        currentProfile.customLinks
            .where((link) => link.id != event.linkId)
            .toList();

    // Reorder the remaining links
    final reorderedLinks =
        updatedLinks.asMap().entries.map((entry) {
          return entry.value.copyWith(order: entry.key);
        }).toList();

    final updatedProfile = currentProfile.copyWith(
      customLinks: reorderedLinks,
      updatedAt: DateTime.now(),
    );

    emit(ProfileUpdating(updatedProfile));

    try {
      await _supabaseService.updateUserProfile(updatedProfile);
      emit(ProfileUpdated(updatedProfile));
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(
        ProfileError(
          'Failed to remove custom link: $e',
          profile: currentProfile,
        ),
      );
    }
  }

  Future<void> _onCustomLinksReordered(
    CustomLinksReordered event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;

    final currentProfile = (state as ProfileLoaded).profile;
    final reorderedLinks =
        event.reorderedLinks.asMap().entries.map((entry) {
          return entry.value.copyWith(order: entry.key);
        }).toList();

    final updatedProfile = currentProfile.copyWith(
      customLinks: reorderedLinks,
      updatedAt: DateTime.now(),
    );

    emit(ProfileUpdating(updatedProfile));

    try {
      await _supabaseService.updateUserProfile(updatedProfile);
      emit(ProfileUpdated(updatedProfile));
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(
        ProfileError(
          'Failed to reorder custom links: $e',
          profile: currentProfile,
        ),
      );
    }
  }
}
