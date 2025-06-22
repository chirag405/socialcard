import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../blocs/qr_link/qr_link_bloc.dart';
import '../../blocs/qr_link/qr_link_state.dart';
import '../../blocs/qr_link/qr_link_event.dart';
import '../../widgets/qr_config_card.dart';
import '../../models/qr_link_config.dart';

class QrHistoryScreen extends StatefulWidget {
  const QrHistoryScreen({super.key});

  @override
  State<QrHistoryScreen> createState() => _QrHistoryScreenState();
}

class _QrHistoryScreenState extends State<QrHistoryScreen> {
  Timer? _expiryCheckTimer;

  @override
  void initState() {
    super.initState();

    // Load QR configs on screen init
    context.read<QrLinkBloc>().add(LoadQrConfigs());

    // Set up periodic expiry check every minute
    _expiryCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkExpiredConfigs(),
    );
  }

  @override
  void dispose() {
    _expiryCheckTimer?.cancel();
    super.dispose();
  }

  void _checkExpiredConfigs() {
    // Trigger a reload to check for newly expired configs
    context.read<QrLinkBloc>().add(LoadQrConfigs());
  }

  void _deleteConfig(QrLinkConfig config) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(config.isExpired ? 'Remove QR Code' : 'Delete QR Code'),
            content: Text(
              config.isExpired
                  ? 'This QR code has expired. Do you want to remove it from your history?'
                  : 'Are you sure you want to delete this QR code? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<QrLinkBloc>().add(DeleteQrConfig(config.id));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        config.isExpired
                            ? 'Expired QR removed'
                            : 'QR code deleted',
                      ),
                      backgroundColor:
                          config.isExpired ? Colors.orange : Colors.red,
                    ),
                  );
                },
                child: Text(
                  config.isExpired ? 'Remove' : 'Delete',
                  style: TextStyle(
                    color: config.isExpired ? Colors.orange : Colors.red,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _shareConfig(QrLinkConfig config) {
    // Create a simple QR widget for sharing
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share QR Code',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text('Link: ${config.shareableLink}'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement actual sharing
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR History'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.read<QrLinkBloc>().add(LoadQrConfigs());
            },
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

          if (state is QrLinkError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load QR history',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<QrLinkBloc>().add(LoadQrConfigs());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is QrLinkLoaded) {
            final configs = state.qrConfigs ?? <QrLinkConfig>[];

            if (configs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No QR codes yet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first QR code to see it here',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create QR Code'),
                    ),
                  ],
                ),
              );
            }

            // Separate expired and active configs
            final activeConfigs =
                configs.where((config) => !config.isExpired).toList();
            final expiredConfigs =
                configs.where((config) => config.isExpired).toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<QrLinkBloc>().add(LoadQrConfigs());
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Active QR Codes Section
                  if (activeConfigs.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.qr_code, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Active QR Codes (${activeConfigs.length})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...activeConfigs.map(
                      (config) => QrConfigCard(
                        config: config,
                        onTap: () => _shareConfig(config),
                        onShare: () => _shareConfig(config),
                        onDelete: () => _deleteConfig(config),
                      ),
                    ),
                  ],

                  // Expired QR Codes Section
                  if (expiredConfigs.isNotEmpty) ...[
                    if (activeConfigs.isNotEmpty) const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Expired QR Codes (${expiredConfigs.length})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Clear All Expired'),
                                      content: Text(
                                        'Remove all ${expiredConfigs.length} expired QR codes from your history?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            for (final config
                                                in expiredConfigs) {
                                              context.read<QrLinkBloc>().add(
                                                DeleteQrConfig(config.id),
                                              );
                                            }
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${expiredConfigs.length} expired QR codes removed',
                                                ),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Clear All',
                                            style: TextStyle(
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: const Text('Clear All'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...expiredConfigs.map(
                      (config) => QrConfigCard(
                        config: config,
                        onDelete: () => _deleteConfig(config),
                      ),
                    ),
                  ],

                  // Bottom padding
                  const SizedBox(height: 80),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
