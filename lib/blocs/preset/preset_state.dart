import 'package:equatable/equatable.dart';
import '../../models/qr_preset.dart';

abstract class PresetState extends Equatable {
  const PresetState();

  @override
  List<Object?> get props => [];
}

class PresetInitial extends PresetState {}

class PresetLoading extends PresetState {}

class PresetLoaded extends PresetState {
  final List<QrPreset> presets;
  final QrPreset? defaultPreset;

  const PresetLoaded({required this.presets, this.defaultPreset});

  @override
  List<Object?> get props => [presets, defaultPreset];

  PresetLoaded copyWith({List<QrPreset>? presets, QrPreset? defaultPreset}) {
    return PresetLoaded(
      presets: presets ?? this.presets,
      defaultPreset: defaultPreset ?? this.defaultPreset,
    );
  }
}

class PresetSaving extends PresetState {
  final QrPreset preset;

  const PresetSaving(this.preset);

  @override
  List<Object> get props => [preset];
}

class PresetSaved extends PresetState {
  final QrPreset preset;

  const PresetSaved(this.preset);

  @override
  List<Object> get props => [preset];
}

class PresetDeleting extends PresetState {
  final String presetId;

  const PresetDeleting(this.presetId);

  @override
  List<Object> get props => [presetId];
}

class PresetDeleted extends PresetState {
  final String presetId;

  const PresetDeleted(this.presetId);

  @override
  List<Object> get props => [presetId];
}

class PresetDuplicating extends PresetState {
  final QrPreset originalPreset;

  const PresetDuplicating(this.originalPreset);

  @override
  List<Object> get props => [originalPreset];
}

class PresetDuplicated extends PresetState {
  final QrPreset newPreset;

  const PresetDuplicated(this.newPreset);

  @override
  List<Object> get props => [newPreset];
}

class PresetError extends PresetState {
  final String message;
  final List<QrPreset>? presets;

  const PresetError(this.message, {this.presets});

  @override
  List<Object?> get props => [message, presets];
}
