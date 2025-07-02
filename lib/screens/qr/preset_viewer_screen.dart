import 'package:flutter/material.dart';
import '../../models/qr_preset.dart';
import 'qr_create_screen.dart';

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
        actions: [
          FilledButton.icon(
            onPressed: () => _applyPreset(context),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Use This'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPresetHeader(theme),
            const SizedBox(height: 24),
            _buildQrCustomizationSection(theme),
            const SizedBox(height: 24),
            _buildLinksSection(theme),
            const SizedBox(height: 24),
            _buildExpirySection(theme),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _applyPreset(context),
                icon: const Icon(Icons.qr_code),
                label: Text('Create QR with "${preset.name}" Settings'),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
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

  void _applyPreset(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => QrCreateScreen(preset: preset)),
    );
  }
}
