import 'package:equatable/equatable.dart';
import '../../models/qr_link_config.dart';

abstract class QrLinkEvent extends Equatable {
  const QrLinkEvent();

  @override
  List<Object?> get props => [];
}

class QrLinkLoadRequested extends QrLinkEvent {
  final String userId;

  const QrLinkLoadRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class QrLinkLoadActiveRequested extends QrLinkEvent {
  final String userId;

  const QrLinkLoadActiveRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class QrLinkCreateRequested extends QrLinkEvent {
  final QrLinkConfig config;

  const QrLinkCreateRequested(this.config);

  @override
  List<Object> get props => [config];
}

class QrLinkUpdateRequested extends QrLinkEvent {
  final QrLinkConfig config;

  const QrLinkUpdateRequested(this.config);

  @override
  List<Object> get props => [config];
}

class QrLinkDeleteRequested extends QrLinkEvent {
  final String configId;

  const QrLinkDeleteRequested(this.configId);

  @override
  List<Object> get props => [configId];
}

class QrCustomizationUpdated extends QrLinkEvent {
  final QrCustomization customization;

  const QrCustomizationUpdated(this.customization);

  @override
  List<Object> get props => [customization];
}

class ExpirySettingsUpdated extends QrLinkEvent {
  final ExpirySettings settings;

  const ExpirySettingsUpdated(this.settings);

  @override
  List<Object> get props => [settings];
}

class SlugAvailabilityChecked extends QrLinkEvent {
  final String slug;

  const SlugAvailabilityChecked(this.slug);

  @override
  List<Object> get props => [slug];
}

class QrLinkShareRequested extends QrLinkEvent {
  final String configId;

  const QrLinkShareRequested(this.configId);

  @override
  List<Object> get props => [configId];
}

class QrLinkRegenerateRequested extends QrLinkEvent {
  final String configId;

  const QrLinkRegenerateRequested(this.configId);

  @override
  List<Object> get props => [configId];
}

class LoadQrConfigs extends QrLinkEvent {}

class DeleteQrConfig extends QrLinkEvent {
  final String configId;

  const DeleteQrConfig(this.configId);

  @override
  List<Object> get props => [configId];
}
