import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../blocs/qr_link/qr_link_bloc.dart';
import '../../blocs/qr_link/qr_link_event.dart';
import '../../blocs/qr_link/qr_link_state.dart';
import '../../models/qr_link_config.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_config.dart';

class ActiveLinksScreen extends StatefulWidget {
  const ActiveLinksScreen({super.key});

  @override
  State<ActiveLinksScreen> createState() => _ActiveLinksScreenState();
}

class _ActiveLinksScreenState extends State<ActiveLinksScreen> {
  @override
  void initState() {
    super.initState();
    _loadActiveLinks();
  }

  void _loadActiveLinks() {
    final userId = context.read<SupabaseService>().currentUserId;
    if (userId != null) {
      context.read<QrLinkBloc>().add(QrLinkLoadActiveRequested(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active QR Links'),
        actions: [
          IconButton(
            onPressed: _loadActiveLinks,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<QrLinkBloc, QrLinkState>(
        builder: (context, state) {
          if (state is QrLinkLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QrLinkActiveLoaded) {
            final activeLinks = state.activeLinks;

            if (activeLinks.isEmpty) {
              return _buildEmptyState(theme);
            }

            return RefreshIndicator(
              onRefresh: () async => _loadActiveLinks(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: activeLinks.length,
                itemBuilder: (context, index) {
                  final link = activeLinks[index];
                  return _buildLinkCard(context, theme, link);
                },
              ),
            );
          }

          if (state is QrLinkError) {
            return _buildErrorState(theme, state.message);
          }

          return _buildEmptyState(theme);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Links',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create QR codes to see them here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.add),
            label: const Text('Create QR Code'),
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
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error Loading Links',
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
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadActiveLinks,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(
    BuildContext context,
    ThemeData theme,
    QrLinkConfig link,
  ) {
    final isExpiringSoon = _isExpiringSoon(link);
    final isExpired = link.isExpired;
    final expiryText = _getExpiryText(link);
    final progressValue = _getExpiryProgress(link);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isExpired ? 1 : 3,
      color:
          isExpired
              ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
              : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Status indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color:
                        isExpired
                            ? Colors.red
                            : isExpiringSoon
                            ? Colors.orange
                            : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),

                // Link info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        link.description.isNotEmpty
                            ? link.description
                            : 'QR Link - ${link.linkSlug}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              isExpired
                                  ? theme.colorScheme.onSurface.withOpacity(0.6)
                                  : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppConfig.baseDomain}/profile/${link.linkSlug}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton<String>(
                  onSelected: (value) => _handleAction(context, value, link),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'share',
                          child: ListTile(
                            leading: Icon(Icons.share),
                            title: Text('Share'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'copy',
                          child: ListTile(
                            leading: Icon(Icons.copy),
                            title: Text('Copy Link'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        if (!isExpired) ...[
                          const PopupMenuItem(
                            value: 'deactivate',
                            child: ListTile(
                              leading: Icon(Icons.pause),
                              title: Text('Deactivate'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ] else ...[
                          const PopupMenuItem(
                            value: 'reactivate',
                            child: ListTile(
                              leading: Icon(Icons.play_arrow),
                              title: Text('Reactivate'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                _buildStatChip(
                  context,
                  icon: Icons.visibility,
                  label: 'Scans',
                  value: '${link.scanCount}',
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  context,
                  icon: Icons.link,
                  label: 'Links',
                  value: '${link.selectedLinkIds.length}',
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                if (expiryText.isNotEmpty)
                  _buildStatChip(
                    context,
                    icon: Icons.schedule,
                    label: 'Expires',
                    value: expiryText,
                    color:
                        isExpired
                            ? Colors.red
                            : isExpiringSoon
                            ? Colors.orange
                            : Colors.green,
                  ),
              ],
            ),

            // Progress bar for expiry (if applicable)
            if (progressValue != null && !isExpired) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progressValue,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isExpiringSoon ? Colors.orange : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Usage: ${(progressValue * 100).toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],

            // Status badges
            if (isExpired || isExpiringSoon) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        'EXPIRED',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isExpiringSoon)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'EXPIRING SOON',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool _isExpiringSoon(QrLinkConfig link) {
    if (link.isExpired) return false;

    // Check if expiring within 24 hours
    if (link.expirySettings.expiryDate != null) {
      final hoursUntilExpiry =
          link.expirySettings.expiryDate!.difference(DateTime.now()).inHours;
      if (hoursUntilExpiry <= 24 && hoursUntilExpiry > 0) return true;
    }

    // Check if close to max scans (80% threshold)
    if (link.expirySettings.maxScans != null) {
      final threshold = (link.expirySettings.maxScans! * 0.8).ceil();
      if (link.scanCount >= threshold) return true;
    }

    return false;
  }

  String _getExpiryText(QrLinkConfig link) {
    if (link.expirySettings.expiryDate != null) {
      final now = DateTime.now();
      final expiry = link.expirySettings.expiryDate!;

      if (expiry.isBefore(now)) {
        return 'Expired';
      }

      final diff = expiry.difference(now);
      if (diff.inDays > 0) {
        return '${diff.inDays}d';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h';
      } else {
        return '${diff.inMinutes}m';
      }
    }

    if (link.expirySettings.maxScans != null) {
      return '${link.scanCount}/${link.expirySettings.maxScans}';
    }

    if (link.expirySettings.isOneTime && link.scanCount > 0) {
      return 'Used';
    }

    return '';
  }

  double? _getExpiryProgress(QrLinkConfig link) {
    if (link.expirySettings.maxScans != null) {
      return link.scanCount / link.expirySettings.maxScans!;
    }
    return null;
  }

  void _handleAction(BuildContext context, String action, QrLinkConfig link) {
    switch (action) {
      case 'share':
        Share.share(link.shareableLink);
        break;
      case 'copy':
        Clipboard.setData(ClipboardData(text: link.shareableLink));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copied to clipboard')),
        );
        break;
      case 'deactivate':
        _showDeactivateDialog(context, link);
        break;
      case 'reactivate':
        _reactivateLink(link);
        break;
      case 'delete':
        _showDeleteDialog(context, link);
        break;
    }
  }

  void _showDeactivateDialog(BuildContext context, QrLinkConfig link) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Deactivate Link'),
            content: Text(
              'Are you sure you want to deactivate "${link.linkSlug}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _deactivateLink(link);
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Deactivate'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(BuildContext context, QrLinkConfig link) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete Link'),
            content: Text(
              'Are you sure you want to permanently delete "${link.linkSlug}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _deleteLink(link);
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _deactivateLink(QrLinkConfig link) {
    context.read<QrLinkBloc>().add(
      QrLinkUpdateRequested(link.copyWith(isActive: false)),
    );
  }

  void _reactivateLink(QrLinkConfig link) {
    context.read<QrLinkBloc>().add(
      QrLinkUpdateRequested(link.copyWith(isActive: true)),
    );
  }

  void _deleteLink(QrLinkConfig link) {
    context.read<QrLinkBloc>().add(QrLinkDeleteRequested(link.id));
  }
}
