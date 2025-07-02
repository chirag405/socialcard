import 'package:equatable/equatable.dart';
import '../../models/qr_preset.dart';
import '../../models/qr_link_config.dart';

abstract class PresetEvent extends Equatable {
  const PresetEvent();

  @override
  List<Object?> get props => [];
}

class PresetLoadRequested extends PresetEvent {
  final String userId;

  const PresetLoadRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class PresetSaveRequested extends PresetEvent {
  final String name;
  final String description;
  final QrLinkConfig config;

  const PresetSaveRequested({
    required this.name,
    required this.description,
    required this.config,
  });

  @override
  List<Object> get props => [name, description, config];
}

class PresetDeleteRequested extends PresetEvent {
  final String presetId;

  const PresetDeleteRequested(this.presetId);

  @override
  List<Object> get props => [presetId];
}

class PresetDuplicateRequested extends PresetEvent {
  final QrPreset preset;
  final String newName;

  const PresetDuplicateRequested({required this.preset, required this.newName});

  @override
  List<Object> get props => [preset, newName];
}

class PresetSetAsDefaultRequested extends PresetEvent {
  final String presetId;
  final String userId;

  const PresetSetAsDefaultRequested({
    required this.presetId,
    required this.userId,
  });

  @override
  List<Object> get props => [presetId, userId];
}
