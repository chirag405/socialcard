import 'package:equatable/equatable.dart';
import 'qr_link_config.dart';

class QrPreset extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String description;
  final List<String> selectedLinkIds; // IDs of custom links to include
  final QrCustomization qrCustomization;
  final ExpirySettings expirySettings;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QrPreset({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.selectedLinkIds,
    required this.qrCustomization,
    required this.expirySettings,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  QrPreset copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<String>? selectedLinkIds,
    QrCustomization? qrCustomization,
    ExpirySettings? expirySettings,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QrPreset(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      selectedLinkIds: selectedLinkIds ?? this.selectedLinkIds,
      qrCustomization: qrCustomization ?? this.qrCustomization,
      expirySettings: expirySettings ?? this.expirySettings,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'selectedLinkIds': selectedLinkIds,
      'qrCustomization': qrCustomization.toMap(),
      'expirySettings': expirySettings.toMap(),
      'isDefault': isDefault,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory QrPreset.fromMap(Map<String, dynamic> map) {
    return QrPreset(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      selectedLinkIds: List<String>.from(map['selectedLinkIds'] ?? []),
      qrCustomization: QrCustomization.fromMap(map['qrCustomization'] ?? {}),
      expirySettings: ExpirySettings.fromMap(map['expirySettings'] ?? {}),
      isDefault: map['isDefault'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    description,
    selectedLinkIds,
    qrCustomization,
    expirySettings,
    isDefault,
    createdAt,
    updatedAt,
  ];
}
