import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../models/qr_preset.dart';
import '../../services/supabase_service.dart';
import '../../services/local_storage_service.dart';
import 'preset_event.dart';
import 'preset_state.dart';

class PresetBloc extends Bloc<PresetEvent, PresetState> {
  final SupabaseService _supabaseService;
  final LocalStorageService _localStorageService;
  final Uuid _uuid = const Uuid();

  PresetBloc({
    required SupabaseService supabaseService,
    required LocalStorageService localStorageService,
  }) : _supabaseService = supabaseService,
       _localStorageService = localStorageService,
       super(PresetInitial()) {
    on<PresetLoadRequested>(_onLoadRequested);
    on<PresetSaveRequested>(_onSaveRequested);
    on<PresetUpdateRequested>(_onUpdateRequested);
    on<PresetDeleteRequested>(_onDeleteRequested);
    on<PresetDuplicateRequested>(_onDuplicateRequested);
    on<PresetSetAsDefaultRequested>(_onSetAsDefaultRequested);
  }

  Future<void> _onLoadRequested(
    PresetLoadRequested event,
    Emitter<PresetState> emit,
  ) async {
    emit(PresetLoading());
    try {
      final presets = await _localStorageService.getAllQrPresets(event.userId);

      // Find default preset
      final defaultPreset =
          presets.isNotEmpty
              ? presets.firstWhere(
                (preset) => preset.isDefault,
                orElse: () => presets.first,
              )
              : null;

      emit(PresetLoaded(presets: presets, defaultPreset: defaultPreset));
    } catch (e) {
      emit(PresetError('Failed to load presets: $e'));
    }
  }

  Future<void> _onSaveRequested(
    PresetSaveRequested event,
    Emitter<PresetState> emit,
  ) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) {
        emit(const PresetError('User not authenticated'));
        return;
      }

      final now = DateTime.now();
      final preset = QrPreset(
        id: _uuid.v4(),
        userId: userId,
        name: event.name,
        description: event.description,
        qrCustomization: event.config.qrCustomization,
        expirySettings: event.config.expirySettings,
        selectedLinkIds: event.config.selectedLinkIds,
        createdAt: now,
        updatedAt: now,
      );

      emit(PresetSaving(preset));
      await _localStorageService.saveQrPreset(preset);
      emit(PresetSaved(preset));

      // Reload presets to get updated list
      add(PresetLoadRequested(userId));
    } catch (e) {
      emit(PresetError('Failed to save preset: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    PresetUpdateRequested event,
    Emitter<PresetState> emit,
  ) async {
    try {
      emit(PresetUpdating(event.preset));

      final updatedPreset = event.preset.copyWith(updatedAt: DateTime.now());

      await _localStorageService.updateQrPreset(updatedPreset);
      emit(PresetUpdated(updatedPreset));

      // Reload presets to get updated list
      if (_supabaseService.currentUserId != null) {
        add(PresetLoadRequested(_supabaseService.currentUserId!));
      }
    } catch (e) {
      emit(PresetError('Failed to update preset: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    PresetDeleteRequested event,
    Emitter<PresetState> emit,
  ) async {
    try {
      emit(PresetDeleting(event.presetId));
      await _localStorageService.deleteQrPreset(event.presetId);
      emit(PresetDeleted(event.presetId));

      // Reload presets to get updated list
      if (_supabaseService.currentUserId != null) {
        add(PresetLoadRequested(_supabaseService.currentUserId!));
      }
    } catch (e) {
      emit(PresetError('Failed to delete preset: $e'));
    }
  }

  Future<void> _onDuplicateRequested(
    PresetDuplicateRequested event,
    Emitter<PresetState> emit,
  ) async {
    try {
      emit(PresetDuplicating(event.preset));

      final now = DateTime.now();
      final duplicatedPreset = event.preset.copyWith(
        id: _uuid.v4(),
        name: event.newName,
        isDefault: false, // Duplicated presets are never default
        createdAt: now,
        updatedAt: now,
      );

      await _localStorageService.saveQrPreset(duplicatedPreset);
      emit(PresetDuplicated(duplicatedPreset));

      // Reload presets to get updated list
      if (_supabaseService.currentUserId != null) {
        add(PresetLoadRequested(_supabaseService.currentUserId!));
      }
    } catch (e) {
      emit(PresetError('Failed to duplicate preset: $e'));
    }
  }

  Future<void> _onSetAsDefaultRequested(
    PresetSetAsDefaultRequested event,
    Emitter<PresetState> emit,
  ) async {
    try {
      // First, unset all other presets as default
      final allPresets = await _localStorageService.getAllQrPresets(
        event.userId,
      );

      for (final preset in allPresets) {
        if (preset.isDefault && preset.id != event.presetId) {
          final updatedPreset = preset.copyWith(
            isDefault: false,
            updatedAt: DateTime.now(),
          );
          await _localStorageService.updateQrPreset(updatedPreset);
        }
      }

      // Then set the target preset as default
      final targetPreset = allPresets.firstWhere(
        (preset) => preset.id == event.presetId,
      );

      final updatedTargetPreset = targetPreset.copyWith(
        isDefault: true,
        updatedAt: DateTime.now(),
      );

      await _localStorageService.updateQrPreset(updatedTargetPreset);

      // Reload presets to reflect changes
      add(PresetLoadRequested(event.userId));
    } catch (e) {
      emit(PresetError('Failed to set default preset: $e'));
    }
  }
}
