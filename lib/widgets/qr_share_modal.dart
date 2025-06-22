import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import '../models/qr_link_config.dart';
import '../models/qr_preset.dart';
import '../services/local_storage_service.dart';

class QrShareModal extends StatefulWidget {
  final QrLinkConfig qrConfig;
  final Widget qrWidget;
  final Function(QrPreset) onSavePreset;

  const QrShareModal({
    super.key,
    required this.qrConfig,
    required this.qrWidget,
    required this.onSavePreset,
  });

  @override
  State<QrShareModal> createState() => _QrShareModalState();
}

class _QrShareModalState extends State<QrShareModal>
    with TickerProviderStateMixin {
  final GlobalKey _qrKey = GlobalKey();
  final TextEditingController _presetNameController = TextEditingController();
  final LocalStorageService _localStorage = LocalStorageService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _showSavePreset = false;
  bool _isSavingPreset = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _presetNameController.dispose();
    super.dispose();
  }

  Future<void> _shareQr() async {
    try {
      // For now, just share the link - QR image sharing can be added later
      await Share.share(
        'Check out my SocialCard profile: ${widget.qrConfig.shareableLink}',
        subject: 'My SocialCard Profile',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.qrConfig.shareableLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveAsPreset() async {
    if (_presetNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a preset name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSavingPreset = true);

    try {
      final preset = QrPreset(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _presetNameController.text.trim(),
        userId: widget.qrConfig.userId,
        selectedLinkIds: widget.qrConfig.selectedLinkIds,
        qrCustomization: widget.qrConfig.qrCustomization,
        expirySettings: widget.qrConfig.expirySettings,
        description: widget.qrConfig.description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to local storage first (Local-First approach)
      await _localStorage.saveQrPreset(preset);

      // Notify parent widget
      widget.onSavePreset(preset);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preset saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save preset: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSavingPreset = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'QR Code Created!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // QR Code Display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: RepaintBoundary(
                          key: _qrKey,
                          child: widget.qrWidget,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description
                      if (widget.qrConfig.description.isNotEmpty == true) ...[
                        Text(
                          widget.qrConfig.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _copyLink,
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy Link'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _shareQr,
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Save as Preset Section
                      if (!_showSavePreset) ...[
                        TextButton.icon(
                          onPressed:
                              () => setState(() => _showSavePreset = true),
                          icon: const Icon(Icons.bookmark_add),
                          label: const Text('Save as Preset'),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Save as Preset',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _presetNameController,
                                decoration: InputDecoration(
                                  hintText:
                                      'Enter preset name (e.g., "Work Events")',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed:
                                        () => setState(
                                          () => _showSavePreset = false,
                                        ),
                                    child: const Text('Cancel'),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed:
                                        _isSavingPreset ? null : _saveAsPreset,
                                    child:
                                        _isSavingPreset
                                            ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Text('Save Preset'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
