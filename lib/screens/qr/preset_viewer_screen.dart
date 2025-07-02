import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/qr_preset.dart';
import '../../models/qr_link_config.dart';
import '../../utils/app_config.dart';

class PresetViewerScreen extends StatelessWidget {
  final QrPreset preset;

  const PresetViewerScreen({super.key, required this.preset});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(preset.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preset Header
            _buildPresetHeader(theme),
            const SizedBox(height: 24),

            // QR Code Preview
            _buildQrPreview(context, theme),
            const SizedBox(height: 24),

            // QR Customization Preview
            _buildQrCustomizationSection(theme),
            const SizedBox(height: 24),

            // Links Section
            _buildLinksSection(theme),
            const SizedBox(height: 24),

            // Expiry Settings
            _buildExpirySection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            preset.qrCustomization.foregroundColor.withOpacity(0.1),
            preset.qrCustomization.foregroundColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: preset.qrCustomization.foregroundColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // QR Preview Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: preset.qrCustomization.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: preset.qrCustomization.foregroundColor,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.qr_code,
              color: preset.qrCustomization.foregroundColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),

          // Preset Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preset.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (preset.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    preset.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Created ${_formatDate(preset.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrPreview(BuildContext context, ThemeData theme) {
    // Use a static preview URL that won't cause database lookup errors
    const previewUrl = 'https://socialcard-pro-app.netlify.app/preview';

    return _buildSection(
      theme: theme,
      title: 'QR Code Preview',
      icon: Icons.qr_code_2,
      child: Column(
        children: [
          // QR Code Display
          GestureDetector(
            onTap: () => _showEnlargedQr(context, previewUrl),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: preset.qrCustomization.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: previewUrl,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: preset.qrCustomization.backgroundColor,
                    eyeStyle: QrEyeStyle(
                      eyeShape: _getQrEyeShape(preset.qrCustomization.eyeStyle),
                      color: preset.qrCustomization.foregroundColor,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: _getQrDataModuleShape(
                        preset.qrCustomization.dataModuleStyle,
                      ),
                      color: preset.qrCustomization.foregroundColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tap to enlarge',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'PREVIEW',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preview Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is a preview showing how QR codes will look with these settings. Actual QR codes will link to your profile.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
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

  Widget _buildQrCustomizationSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'QR Code Appearance',
      icon: Icons.palette,
      child: Column(
        children: [
          _buildSettingRow(
            theme: theme,
            label: 'Foreground Color',
            value: Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: preset.qrCustomization.foregroundColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
          _buildSettingRow(
            theme: theme,
            label: 'Background Color',
            value: Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: preset.qrCustomization.backgroundColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
          _buildSettingRow(
            theme: theme,
            label: 'Eye Style',
            value: Text(preset.qrCustomization.eyeStyle.name.toUpperCase()),
          ),
          _buildSettingRow(
            theme: theme,
            label: 'Data Style',
            value: Text(
              preset.qrCustomization.dataModuleStyle.name.toUpperCase(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksSection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Included Links',
      icon: Icons.link,
      child: _buildSettingRow(
        theme: theme,
        label: 'Number of Links',
        value: Text('${preset.selectedLinkIds.length} links'),
      ),
    );
  }

  Widget _buildExpirySection(ThemeData theme) {
    return _buildSection(
      theme: theme,
      title: 'Expiry Settings',
      icon: Icons.timer,
      child: Column(
        children: [
          _buildSettingRow(
            theme: theme,
            label: 'Expiry Date',
            value: Text(
              preset.expirySettings.expiryDate != null
                  ? _formatDate(preset.expirySettings.expiryDate!)
                  : 'No expiry',
            ),
          ),
          _buildSettingRow(
            theme: theme,
            label: 'Max Scans',
            value: Text(
              preset.expirySettings.maxScans != null
                  ? '${preset.expirySettings.maxScans} scans'
                  : 'Unlimited',
            ),
          ),
          _buildSettingRow(
            theme: theme,
            label: 'One-time Use',
            value: Icon(
              preset.expirySettings.isOneTime
                  ? Icons.check_circle
                  : Icons.cancel,
              color:
                  preset.expirySettings.isOneTime ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required ThemeData theme,
    required String label,
    required Widget value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: theme.textTheme.bodyMedium), value],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Recently';
    }
  }

  void _showEnlargedQr(BuildContext context, String data) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: preset.qrCustomization.backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preset.name,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: preset.qrCustomization.foregroundColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: preset.qrCustomization.foregroundColor
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'STYLE PREVIEW',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelSmall?.copyWith(
                                  color: preset.qrCustomization.foregroundColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: preset.qrCustomization.foregroundColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: data,
                    version: QrVersions.auto,
                    size: 300.0,
                    backgroundColor: preset.qrCustomization.backgroundColor,
                    eyeStyle: QrEyeStyle(
                      eyeShape: _getQrEyeShape(preset.qrCustomization.eyeStyle),
                      color: preset.qrCustomization.foregroundColor,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: _getQrDataModuleShape(
                        preset.qrCustomization.dataModuleStyle,
                      ),
                      color: preset.qrCustomization.foregroundColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: preset.qrCustomization.foregroundColor.withOpacity(
                        0.1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: preset.qrCustomization.foregroundColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This preview shows your custom styling. Real QR codes will use your actual profile link.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: preset.qrCustomization.foregroundColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _copyLink(BuildContext context, String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  QrEyeShape _getQrEyeShape(CustomQrEyeStyle style) {
    switch (style) {
      case CustomQrEyeStyle.square:
        return QrEyeShape.square;
      case CustomQrEyeStyle.circle:
        return QrEyeShape.circle;
      case CustomQrEyeStyle.rounded:
        return QrEyeShape.square; // qr_flutter doesn't have rounded, use square
    }
  }

  QrDataModuleShape _getQrDataModuleShape(CustomQrDataModuleStyle style) {
    switch (style) {
      case CustomQrDataModuleStyle.square:
        return QrDataModuleShape.square;
      case CustomQrDataModuleStyle.circle:
        return QrDataModuleShape.circle;
      case CustomQrDataModuleStyle.rounded:
        return QrDataModuleShape
            .square; // qr_flutter doesn't have rounded, use square
    }
  }
}
