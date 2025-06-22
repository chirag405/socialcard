import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;

  const ProfileLoadRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class ProfileUpdateRequested extends ProfileEvent {
  final UserProfile profile;

  const ProfileUpdateRequested(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileImageUpdateRequested extends ProfileEvent {
  final String imagePath;

  const ProfileImageUpdateRequested(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

class CustomLinkAdded extends ProfileEvent {
  final CustomLink link;

  const CustomLinkAdded(this.link);

  @override
  List<Object> get props => [link];
}

class CustomLinkUpdated extends ProfileEvent {
  final CustomLink link;

  const CustomLinkUpdated(this.link);

  @override
  List<Object> get props => [link];
}

class CustomLinkRemoved extends ProfileEvent {
  final String linkId;

  const CustomLinkRemoved(this.linkId);

  @override
  List<Object> get props => [linkId];
}

class CustomLinksReordered extends ProfileEvent {
  final List<CustomLink> reorderedLinks;

  const CustomLinksReordered(this.reorderedLinks);

  @override
  List<Object> get props => [reorderedLinks];
}
