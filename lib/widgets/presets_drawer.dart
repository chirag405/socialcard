import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/qr_preset.dart';
import '../blocs/preset/preset_bloc.dart';
import '../blocs/preset/preset_event.dart';
import '../blocs/preset/preset_state.dart';
import '../services/supabase_service.dart';

class PresetsDrawer extends StatefulWidget {
  final Function(QrPreset) onPresetSelected;

  const PresetsDrawer({super.key, required this.onPresetSelected});

  @override
  State<PresetsDrawer> createState() => _PresetsDrawerState();
}

class _PresetsDrawerState extends State<PresetsDrawer> {
  @override
  void initState() {
    super.initState();
    // Load presets when drawer opens
    final supabaseService = SupabaseService();
    final userId = supabaseService.currentUserId;
    print('🔧 PresetsDrawer: Loading presets for user: $userId');
    if (userId != null) {
      context.read<PresetBloc>().add(PresetLoadRequested(userId));
    } else {
      print('❌ PresetsDrawer: No user ID found');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.bookmark,
                      color: theme.colorScheme.onPrimary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'QR Presets',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Presets List with BLoC
          Expanded(
            child: BlocBuilder<PresetBloc, PresetState>(
              builder: (context, state) {
                print('🔧 PresetsDrawer: Current state: ${state.runtimeType}');

                if (state is PresetLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PresetLoaded) {
                  final presets = state.presets;
                  print('🔧 PresetsDrawer: Loaded ${presets.length} presets');

                  if (presets.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: presets.length,
                    itemBuilder: (context, index) {
                      final preset = presets[index];
                      return _buildPresetTile(context, preset, theme);
                    },
                  );
                }

                if (state is PresetError) {
                  print('❌ PresetsDrawer: Error: ${state.message}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load presets',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final supabaseService = SupabaseService();
                            final userId = supabaseService.currentUserId;
                            if (userId != null) {
                              context.read<PresetBloc>().add(
                                PresetLoadRequested(userId),
                              );
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Handle other states (PresetSaved, PresetUpdated, etc.)
                if (state is PresetSaved ||
                    state is PresetUpdated ||
                    state is PresetDeleted) {
                  // Trigger reload
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final supabaseService = SupabaseService();
                    final userId = supabaseService.currentUserId;
                    if (userId != null) {
                      context.read<PresetBloc>().add(
                        PresetLoadRequested(userId),
                      );
                    }
                  });
                }

                return _buildEmptyState(theme);
              },
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Create a QR code and save it as a preset to reuse settings',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Presets Yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a QR code and save it as a preset to quickly reuse your favorite settings.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '💡 Tip: After creating a QR code, tap "Save as Preset" to store it here',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetTile(
    BuildContext context,
    QrPreset preset,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).pop();
          widget.onPresetSelected(preset);

          // Show feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Applied preset: ${preset.name}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Preset Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: preset.qrCustomization.foregroundColor.withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: preset.qrCustomization.foregroundColor.withOpacity(
                      0.3,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.qr_code,
                  color: preset.qrCustomization.foregroundColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Preset Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (preset.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        preset.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${preset.selectedLinkIds.length} links',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Tap to use',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Simple Delete Button (only action needed)
              IconButton(
                onPressed: () => _showDeleteConfirmation(context, preset),
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error.withOpacity(0.7),
                  size: 20,
                ),
                tooltip: 'Delete preset',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, QrPreset preset) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Preset'),
            content: Text(
              'Are you sure you want to delete "${preset.name}"?\n\nThis action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<PresetBloc>().add(
                    PresetDeleteRequested(preset.id),
                  );
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Preset "${preset.name}" deleted'),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
