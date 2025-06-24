import 'package:equatable/equatable.dart';
import '../../models/qr_link_config.dart';
import '../../models/qr_preset.dart';

abstract class QrLinkState extends Equatable {
  const QrLinkState();

  @override
  List<Object?> get props => [];
}

class QrLinkInitial extends QrLinkState {}

class QrLinkLoading extends QrLinkState {}

class QrLinkLoaded extends QrLinkState {
  final List<QrLinkConfig> configs;
  final QrLinkConfig? activeConfig;
  final List<QrLinkConfig>? qrConfigs;

  const QrLinkLoaded(this.configs, {this.activeConfig, this.qrConfigs});

  @override
  List<Object?> get props => [configs, activeConfig, qrConfigs];
}

class QrLinkEditing extends QrLinkState {
  final QrLinkConfig config;
  final QrCustomization? customization;
  final ExpirySettings? expirySettings;

  const QrLinkEditing(this.config, {this.customization, this.expirySettings});

  QrLinkEditing copyWith({
    QrLinkConfig? config,
    QrCustomization? customization,
    ExpirySettings? expirySettings,
  }) {
    return QrLinkEditing(
      config ?? this.config,
      customization: customization ?? this.customization,
      expirySettings: expirySettings ?? this.expirySettings,
    );
  }

  @override
  List<Object?> get props => [config, customization, expirySettings];
}

class QrLinkCreated extends QrLinkState {
  final QrLinkConfig config;

  const QrLinkCreated(this.config);

  @override
  List<Object> get props => [config];
}

class QrLinkUpdated extends QrLinkState {
  final QrLinkConfig config;

  const QrLinkUpdated(this.config);

  @override
  List<Object> get props => [config];
}

class QrLinkDeleted extends QrLinkState {
  final String configId;

  const QrLinkDeleted(this.configId);

  @override
  List<Object> get props => [configId];
}

class SlugAvailabilityResult extends QrLinkState {
  final String slug;
  final bool isAvailable;

  const SlugAvailabilityResult(this.slug, this.isAvailable);

  @override
  List<Object> get props => [slug, isAvailable];
}

class QrLinkSharing extends QrLinkState {
  final QrLinkConfig config;

  const QrLinkSharing(this.config);

  @override
  List<Object> get props => [config];
}

class QrLinkShared extends QrLinkState {
  final QrLinkConfig config;
  final String shareData;

  const QrLinkShared(this.config, this.shareData);

  @override
  List<Object> get props => [config, shareData];
}

class QrLinkError extends QrLinkState {
  final String message;
  final List<QrLinkConfig>? configs;

  const QrLinkError(this.message, {this.configs});

  @override
  List<Object?> get props => [message, configs];
}
