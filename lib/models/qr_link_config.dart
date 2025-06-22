import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../utils/app_config.dart';

class QrLinkConfig extends Equatable {
  final String id;
  final String userId;
  final String linkSlug;
  final String description;
  final List<String> selectedLinkIds; // Which custom links to include
  final QrCustomization qrCustomization;
  final ExpirySettings expirySettings;
  final bool isActive;
  final int scanCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QrLinkConfig({
    required this.id,
    required this.userId,
    required this.linkSlug,
    required this.description,
    required this.selectedLinkIds,
    required this.qrCustomization,
    required this.expirySettings,
    this.isActive = true,
    this.scanCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isExpired {
    if (!isActive) return true;

    final now = DateTime.now();

    // Check date expiry
    if (expirySettings.expiryDate != null &&
        now.isAfter(expirySettings.expiryDate!)) {
      return true;
    }

    // Check scan count expiry
    if (expirySettings.maxScans != null &&
        scanCount >= expirySettings.maxScans!) {
      return true;
    }

    return false;
  }

  String get shareableLink {
    return AppConfig.generateProfileLink(linkSlug);
  }

  QrLinkConfig copyWith({
    String? id,
    String? userId,
    String? linkSlug,
    String? description,
    List<String>? selectedLinkIds,
    QrCustomization? qrCustomization,
    ExpirySettings? expirySettings,
    bool? isActive,
    int? scanCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QrLinkConfig(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      linkSlug: linkSlug ?? this.linkSlug,
      description: description ?? this.description,
      selectedLinkIds: selectedLinkIds ?? this.selectedLinkIds,
      qrCustomization: qrCustomization ?? this.qrCustomization,
      expirySettings: expirySettings ?? this.expirySettings,
      isActive: isActive ?? this.isActive,
      scanCount: scanCount ?? this.scanCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'linkSlug': linkSlug,
      'description': description,
      'selectedLinkIds': selectedLinkIds,
      'qrCustomization': qrCustomization.toMap(),
      'expirySettings': expirySettings.toMap(),
      'isActive': isActive,
      'scanCount': scanCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory QrLinkConfig.fromMap(Map<String, dynamic> map) {
    return QrLinkConfig(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      linkSlug: map['linkSlug'] ?? '',
      description: map['description'] ?? '',
      selectedLinkIds: List<String>.from(map['selectedLinkIds'] ?? []),
      qrCustomization: QrCustomization.fromMap(map['qrCustomization'] ?? {}),
      expirySettings: ExpirySettings.fromMap(map['expirySettings'] ?? {}),
      isActive: map['isActive'] ?? true,
      scanCount: map['scanCount'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    linkSlug,
    description,
    selectedLinkIds,
    qrCustomization,
    expirySettings,
    isActive,
    scanCount,
    createdAt,
    updatedAt,
  ];
}

class QrCustomization extends Equatable {
  final Color foregroundColor;
  final Color backgroundColor;
  final CustomQrEyeStyle eyeStyle;
  final CustomQrDataModuleStyle dataModuleStyle;
  final String? logoUrl;
  final double logoSize;
  final double padding;

  const QrCustomization({
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.eyeStyle = CustomQrEyeStyle.square,
    this.dataModuleStyle = CustomQrDataModuleStyle.square,
    this.logoUrl,
    this.logoSize = 0.2,
    this.padding = 10.0,
  });

  QrCustomization copyWith({
    Color? foregroundColor,
    Color? backgroundColor,
    CustomQrEyeStyle? eyeStyle,
    CustomQrDataModuleStyle? dataModuleStyle,
    String? logoUrl,
    double? logoSize,
    double? padding,
  }) {
    return QrCustomization(
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      eyeStyle: eyeStyle ?? this.eyeStyle,
      dataModuleStyle: dataModuleStyle ?? this.dataModuleStyle,
      logoUrl: logoUrl ?? this.logoUrl,
      logoSize: logoSize ?? this.logoSize,
      padding: padding ?? this.padding,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foregroundColor': foregroundColor.value,
      'backgroundColor': backgroundColor.value,
      'eyeStyle': eyeStyle.name,
      'dataModuleStyle': dataModuleStyle.name,
      'logoUrl': logoUrl,
      'logoSize': logoSize,
      'padding': padding,
    };
  }

  factory QrCustomization.fromMap(Map<String, dynamic> map) {
    return QrCustomization(
      foregroundColor: Color(map['foregroundColor'] ?? Colors.black.value),
      backgroundColor: Color(map['backgroundColor'] ?? Colors.white.value),
      eyeStyle: CustomQrEyeStyle.values.firstWhere(
        (style) => style.name == map['eyeStyle'],
        orElse: () => CustomQrEyeStyle.square,
      ),
      dataModuleStyle: CustomQrDataModuleStyle.values.firstWhere(
        (style) => style.name == map['dataModuleStyle'],
        orElse: () => CustomQrDataModuleStyle.square,
      ),
      logoUrl: map['logoUrl'],
      logoSize: map['logoSize']?.toDouble() ?? 0.2,
      padding: map['padding']?.toDouble() ?? 10.0,
    );
  }

  @override
  List<Object?> get props => [
    foregroundColor,
    backgroundColor,
    eyeStyle,
    dataModuleStyle,
    logoUrl,
    logoSize,
    padding,
  ];
}

class ExpirySettings extends Equatable {
  final DateTime? expiryDate;
  final int? maxScans;
  final bool isOneTime;

  const ExpirySettings({
    this.expiryDate,
    this.maxScans,
    this.isOneTime = false,
  });

  ExpirySettings copyWith({
    DateTime? expiryDate,
    int? maxScans,
    bool? isOneTime,
  }) {
    return ExpirySettings(
      expiryDate: expiryDate ?? this.expiryDate,
      maxScans: maxScans ?? this.maxScans,
      isOneTime: isOneTime ?? this.isOneTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
      'maxScans': maxScans,
      'isOneTime': isOneTime,
    };
  }

  factory ExpirySettings.fromMap(Map<String, dynamic> map) {
    return ExpirySettings(
      expiryDate:
          map['expiryDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['expiryDate'])
              : null,
      maxScans: map['maxScans'],
      isOneTime: map['isOneTime'] ?? false,
    );
  }

  @override
  List<Object?> get props => [expiryDate, maxScans, isOneTime];
}

enum CustomQrEyeStyle { square, circle, rounded }

enum CustomQrDataModuleStyle { square, circle, rounded }
