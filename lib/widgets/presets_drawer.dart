import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/qr_preset.dart';
import '../blocs/preset/preset_bloc.dart';
import '../blocs/preset/preset_event.dart';
import '../blocs/preset/preset_state.dart';
import '../services/supabase_service.dart';
import '../screens/qr/preset_viewer_screen.dart';

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
    final userId = context.read<SupabaseService>().currentUserId;
    if (userId != null) {
      context.read<PresetBloc>().add(PresetLoadRequested(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'My Presets',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: BlocConsumer<PresetBloc, PresetState>(
                  listener: (context, state) {
                    if (state is PresetError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    } else if (state is PresetDeleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Preset deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is PresetLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is PresetLoaded) {
                      final presets = state.presets;

                      if (presets.isEmpty) {
                        return _buildEmptyState(theme);
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: presets.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final preset = presets[index];
                          return _buildPresetCard(context, theme, preset);
                        },
                      );
                    }

                    if (state is PresetError) {
                      return _buildErrorState(theme, state.message);
                    }

                    return _buildEmptyState(theme);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Presets Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create QR codes and save them as presets\nfor quick reuse',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Presets',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard(
    BuildContext context,
    ThemeData theme,
    QrPreset preset,
  ) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to preset viewer instead of direct apply
          Navigator.pop(context); // Close drawer first
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PresetViewerScreen(preset: preset),
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
                          'Tap to view',
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
          (dialogContext) => AlertDialog(
            title: const Text('Delete Preset'),
            content: Text('Are you sure you want to delete "${preset.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<PresetBloc>().add(
                    PresetDeleteRequested(preset.id),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
