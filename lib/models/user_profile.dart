import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final String? bio;
  final List<CustomLink> customLinks;
  final bool isDiscoverable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    this.bio,
    this.customLinks = const [],
    this.isDiscoverable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? bio,
    List<CustomLink>? customLinks,
    bool? isDiscoverable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      customLinks: customLinks ?? this.customLinks,
      isDiscoverable: isDiscoverable ?? this.isDiscoverable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'customLinks': customLinks.map((link) => link.toMap()).toList(),
      'isDiscoverable': isDiscoverable,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'],
      customLinks:
          (map['customLinks'] as List<dynamic>?)
              ?.map((link) => CustomLink.fromMap(link))
              .toList() ??
          [],
      isDiscoverable: map['isDiscoverable'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    profileImageUrl,
    bio,
    customLinks,
    isDiscoverable,
    createdAt,
    updatedAt,
  ];
}

class CustomLink extends Equatable {
  final String id;
  final String url;
  final String displayName;
  final String iconName;
  final int order;

  const CustomLink({
    required this.id,
    required this.url,
    required this.displayName,
    required this.iconName,
    required this.order,
  });

  CustomLink copyWith({
    String? id,
    String? url,
    String? displayName,
    String? iconName,
    int? order,
  }) {
    return CustomLink(
      id: id ?? this.id,
      url: url ?? this.url,
      displayName: displayName ?? this.displayName,
      iconName: iconName ?? this.iconName,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'displayName': displayName,
      'iconName': iconName,
      'order': order,
    };
  }

  factory CustomLink.fromMap(Map<String, dynamic> map) {
    return CustomLink(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
      displayName: map['displayName'] ?? '',
      iconName: map['iconName'] ?? 'link',
      order: map['order'] ?? 0,
    );
  }

  @override
  List<Object> get props => [id, url, displayName, iconName, order];
}
