import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../models/qr_link_config.dart';
import '../models/qr_preset.dart';
import '../blocs/preset/preset_bloc.dart';
import '../blocs/preset/preset_event.dart';
import '../blocs/preset/preset_state.dart';
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
  final TextEditingController _presetDescriptionController =
      TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _showSavePreset = false;
  bool _isSavingPreset = false;
  bool _isPresetNameValid = false;

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

    // Add listener to preset name controller
    _presetNameController.addListener(_updatePresetNameValidity);

    _animationController.forward();
  }

  void _updatePresetNameValidity() {
    final isValid = _presetNameController.text.trim().isNotEmpty;
    if (_isPresetNameValid != isValid) {
      setState(() {
        _isPresetNameValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _presetNameController.removeListener(_updatePresetNameValidity);
    _presetNameController.dispose();
    _presetDescriptionController.dispose();
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

  void _saveAsPreset() {
    if (_presetNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a preset name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if this preset has expiry settings and show warning
    if (_hasExpirySettings()) {
      _showPresetLifetimeWarning();
      return;
    }

    _proceedWithSaving();
  }

  bool _hasExpirySettings() {
    return widget.qrConfig.expirySettings.expiryDate != null ||
        widget.qrConfig.expirySettings.maxScans != null ||
        widget.qrConfig.expirySettings.isOneTime;
  }

  void _showPresetLifetimeWarning() {
    final expiryInfo = _getExpiryInfo();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('Preset Lifetime Warning'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This preset includes expiry settings that may limit its usefulness:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        expiryInfo
                            .map(
                              (info) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(info)),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Recommendation: Consider creating a preset without expiry settings for reusability, or modify the expiry settings before saving.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  // Go back to editing mode to allow changes
                  setState(() => _showSavePreset = true);
                },
                child: const Text('Modify Settings'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _proceedWithSaving();
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Save Anyway'),
              ),
            ],
          ),
    );
  }

  List<String> _getExpiryInfo() {
    final List<String> info = [];
    final expiry = widget.qrConfig.expirySettings;

    if (expiry.expiryDate != null) {
      final timeLeft = expiry.expiryDate!.difference(DateTime.now());
      if (timeLeft.isNegative) {
        info.add('Already expired');
      } else if (timeLeft.inDays > 0) {
        info.add('Expires in ${timeLeft.inDays} days');
      } else if (timeLeft.inHours > 0) {
        info.add('Expires in ${timeLeft.inHours} hours');
      } else {
        info.add('Expires in ${timeLeft.inMinutes} minutes');
      }
    }

    if (expiry.maxScans != null) {
      info.add('Limited to ${expiry.maxScans} scans');
    }

    if (expiry.isOneTime) {
      info.add('One-time use only');
    }

    return info;
  }

  void _proceedWithSaving() {
    // Use PresetBloc to save the preset
    context.read<PresetBloc>().add(
      PresetSaveRequested(
        name: _presetNameController.text.trim(),
        description: _presetDescriptionController.text.trim(),
        config: widget.qrConfig,
      ),
    );

    // Close the modal
    Navigator.of(context).pop();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preset "${_presetNameController.text.trim()}" saved!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
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
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        color: theme.colorScheme.onPrimary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'QR Code Ready!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // QR Code Display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            RepaintBoundary(
                              key: _qrKey,
                              child: widget.qrWidget,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.qrConfig.shareableLink,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _copyLink,
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy Link'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _shareQr,
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
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
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _presetDescriptionController,
                                decoration: InputDecoration(
                                  hintText: 'Description (optional)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 12),
                              BlocListener<PresetBloc, PresetState>(
                                listener: (context, state) {
                                  if (state is PresetSaved) {
                                    widget.onSavePreset(state.preset);
                                  } else if (state is PresetError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to save preset: ${state.message}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () {
                                          setState(
                                            () => _showSavePreset = false,
                                          );
                                          _presetNameController.clear();
                                          _presetDescriptionController.clear();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed:
                                            _isPresetNameValid
                                                ? () => _saveAsPreset()
                                                : null,
                                        child: const Text('Save Preset'),
                                      ),
                                    ),
                                  ],
                                ),
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
