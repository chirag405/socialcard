import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_state.dart';
import '../../blocs/profile/profile_event.dart';
import '../../models/user_profile.dart';
import '../../widgets/profile_card.dart';
import '../../widgets/custom_links_section.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileLoaded ||
            state is ProfileUpdating ||
            state is ProfileUpdated) {
          UserProfile profile;

          if (state is ProfileLoaded) {
            profile = state.profile;
          } else if (state is ProfileUpdating) {
            profile = state.profile;
          } else {
            profile = (state as ProfileUpdated).profile;
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(ProfileLoadRequested(profile.id));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileCard(profile: profile),
                  const SizedBox(height: 24),
                  CustomLinksSection(profile: profile),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          );
        } else if (state is ProfileError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading profile',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (state.profile != null) {
                      context.read<ProfileBloc>().add(
                        ProfileLoadRequested(state.profile!.id),
                      );
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('No profile data available'));
      },
    );
  }
}
