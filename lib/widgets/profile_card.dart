import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../screens/profile/profile_edit_screen.dart';
import '../screens/qr/qr_create_screen.dart';

class ProfileCard extends StatelessWidget {
  final UserProfile profile;

  const ProfileCard({super.key, required this.profile});

  void _navigateToProfileEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileEditScreen(profile: profile),
      ),
    );
  }

  void _navigateToQrCreate(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const QrCreateScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Image
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child:
                  profile.profileImageUrl != null
                      ? ClipOval(
                        child: Image.network(
                          profile.profileImageUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Show initials when image fails to load
                            return Container(
                              width: 100,
                              height: 100,
                              color: Theme.of(context).colorScheme.primary,
                              child: Center(
                                child: Text(
                                  profile.name.isNotEmpty
                                      ? profile.name[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 100,
                              height: 100,
                              color: Theme.of(context).colorScheme.primary,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      : Text(
                        profile.name.isNotEmpty
                            ? profile.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              profile.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Email
            Text(
              profile.email,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),

            // Phone (if available)
            if (profile.phone != null) ...[
              const SizedBox(height: 4),
              Text(
                profile.phone!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],

            // Bio (if available)
            if (profile.bio != null && profile.bio!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                profile.bio!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToProfileEdit(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToQrCreate(context),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
