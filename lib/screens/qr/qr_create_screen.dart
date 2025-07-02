import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../blocs/qr_link/qr_link_bloc.dart';
import '../../blocs/qr_link/qr_link_event.dart';
import '../../blocs/qr_link/qr_link_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_state.dart';
import '../../models/qr_link_config.dart';
import '../../models/qr_preset.dart';
import '../../widgets/qr_share_modal.dart';
import '../../utils/app_config.dart';

class QrCreateScreen extends StatefulWidget {
  final QrPreset? preset; // Accept preset parameter

  const QrCreateScreen({super.key, this.preset});

  @override
  State<QrCreateScreen> createState() => _QrCreateScreenState();
}

class _QrCreateScreenState extends State<QrCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Customization settings
  Color _foregroundColor = Colors.black;
  Color _backgroundColor = Colors.white;
  CustomQrEyeStyle _eyeStyle = CustomQrEyeStyle.square;
  CustomQrDataModuleStyle _dataModuleStyle = CustomQrDataModuleStyle.square;

  // Expiry settings - Default to 5 minutes expiry
  bool _hasExpiry = true;
  DateTime? _expiryDate;
  int? _maxScans;
  bool _isOneTime = false;

  // Selected social links
  Set<String> _selectedLinkIds = {};
  bool _hasInitializedDefaults = false;

  @override
  void initState() {
    super.initState();

    // Apply preset settings if provided
    if (widget.preset != null) {
      _applyPresetSettings(widget.preset!);
    } else {
      // Set default expiry to 5 minutes from now only if no preset
      _expiryDate = DateTime.now().add(const Duration(minutes: 5));
    }
  }

  void _applyPresetSettings(QrPreset preset) {
    print('🎨 Applying preset: ${preset.name}');

    setState(() {
      // Apply QR customization
      _foregroundColor = preset.qrCustomization.foregroundColor;
      _backgroundColor = preset.qrCustomization.backgroundColor;
      _eyeStyle = preset.qrCustomization.eyeStyle;
      _dataModuleStyle = preset.qrCustomization.dataModuleStyle;

      // Apply expiry settings
      _hasExpiry =
          preset.expirySettings.expiryDate != null ||
          preset.expirySettings.maxScans != null ||
          preset.expirySettings.isOneTime;
      _expiryDate = preset.expirySettings.expiryDate;
      _maxScans = preset.expirySettings.maxScans;
      _isOneTime = preset.expirySettings.isOneTime;

      // Apply selected links
      _selectedLinkIds = preset.selectedLinkIds.toSet();

      // Fill description if available
      if (preset.description.isNotEmpty) {
        _descriptionController.text = preset.description;
      }

      _hasInitializedDefaults = true; // Skip default initialization
    });

    print('🎨 Applied preset settings:');
    print('  - Foreground: $_foregroundColor');
    print('  - Background: $_backgroundColor');
    print('  - Eye style: $_eyeStyle');
    print('  - Data style: $_dataModuleStyle');
    print('  - Selected links: ${_selectedLinkIds.length}');
    print('  - Has expiry: $_hasExpiry');
    print('  - Expiry date: $_expiryDate');
    print('  - Max scans: $_maxScans');
    print('  - One time: $_isOneTime');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize default link selections only if no preset was applied
    if (!_hasInitializedDefaults && widget.preset == null) {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        setState(() {
          // Select all links by default only when no preset
          _selectedLinkIds =
              profileState.profile.customLinks.map((link) => link.id).toSet();
          _hasInitializedDefaults = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _slugController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            widget.preset != null
                ? Text('Create QR - ${widget.preset!.name}')
                : const Text('Create QR Code'),
        elevation: 0,
        actions:
            widget.preset != null
                ? [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bookmark,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Preset Applied',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
                : null,
      ),
      body: BlocConsumer<QrLinkBloc, QrLinkState>(
        listener: (context, state) {
          if (state is QrLinkCreated) {
            // Check if the final slug is different from what user entered
            final originalSlug = _slugController.text.trim();
            final finalSlug = state.config.linkSlug;

            if (originalSlug.isNotEmpty && finalSlug != originalSlug) {
              // Show message about automatic slug modification
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Your custom slug was modified to "$finalSlug" to ensure uniqueness.',
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 4),
                ),
              );
            }

            _showQrShareModal(state.config);
          } else if (state is QrLinkError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action:
                    state.message.contains('already taken')
                        ? SnackBarAction(
                          label: 'Generate Random',
                          textColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              _slugController
                                  .clear(); // This will trigger auto-generation
                            });
                          },
                        )
                        : null,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show preset info if applied
                  if (widget.preset != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bookmark,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Using Preset: ${widget.preset!.name}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                if (widget.preset!.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.preset!.description,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                  _buildQrPreview(),
                  const SizedBox(height: 24),
                  _buildBasicSettings(),
                  const SizedBox(height: 24),
                  _buildSocialLinksSection(),
                  const SizedBox(height: 24),
                  _buildCustomizationSection(),
                  const SizedBox(height: 24),
                  _buildExpirySection(),
                  const SizedBox(height: 32),
                  _buildCreateButton(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQrPreview() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: AppConfig.generateProfileLink(
                  _slugController.text.isEmpty
                      ? 'preview'
                      : _slugController.text,
                ),
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: _backgroundColor,
                eyeStyle: QrEyeStyle(
                  eyeShape: _getQrEyeShape(_eyeStyle),
                  color: _foregroundColor,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: _getQrDataModuleShape(_dataModuleStyle),
                  color: _foregroundColor,
                ),
              ),
            ),
            if (_descriptionController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _descriptionController.text,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Basic Settings',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _slugController,
              decoration: InputDecoration(
                labelText: 'Custom Link *',
                hintText: 'e.g., johnsmith, myprofile, etc.',
                prefixText: '${AppConfig.baseDomain}/profile/',
                prefixStyle: TextStyle(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'Required - This will be your profile link',
                suffixIcon: Icon(
                  Icons.link,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Custom link is required';
                }
                final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
                if (!regex.hasMatch(value.trim())) {
                  return 'Only letters, numbers, hyphens, and underscores allowed';
                }
                if (value.trim().length < 3) {
                  return 'Link must be at least 3 characters long';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., John Smith - Software Developer',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
              onChanged: (value) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinksSection() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoaded) {
          return const SizedBox.shrink();
        }

        final profile = state.profile;
        if (profile.customLinks.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.link_off, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No social links found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add social links to your profile first',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.share,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Select Links to Share',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose which links will be visible when someone scans your QR code',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ...profile.customLinks.map((link) {
                  final isSelected = _selectedLinkIds.contains(link.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedLinkIds.add(link.id);
                          } else {
                            _selectedLinkIds.remove(link.id);
                          }
                        });
                      },
                      title: Text(link.displayName),
                      subtitle: Text(link.url),
                      secondary: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          _getIconForLink(link.iconName),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedLinkIds.clear();
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedLinkIds =
                              profile.customLinks
                                  .map((link) => link.id)
                                  .toSet();
                        });
                      },
                      child: const Text('Select All'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForLink(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
        return Icons.alternate_email;
      case 'linkedin':
        return Icons.business;
      case 'github':
        return Icons.code;
      case 'website':
        return Icons.language;
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'facebook':
        return Icons.facebook;
      case 'youtube':
        return Icons.play_circle_filled;
      case 'tiktok':
        return Icons.music_note;
      default:
        return Icons.link;
    }
  }

  Widget _buildCustomizationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Customization',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Foreground Color'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _pickColor(true),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: _foregroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Background Color'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _pickColor(false),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: _backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Eye Style'),
            const SizedBox(height: 8),
            SegmentedButton<CustomQrEyeStyle>(
              segments: const [
                ButtonSegment(
                  value: CustomQrEyeStyle.square,
                  label: Text('Square'),
                  icon: Icon(Icons.square_outlined),
                ),
                ButtonSegment(
                  value: CustomQrEyeStyle.circle,
                  label: Text('Circle'),
                  icon: Icon(Icons.circle_outlined),
                ),
                ButtonSegment(
                  value: CustomQrEyeStyle.rounded,
                  label: Text('Rounded'),
                  icon: Icon(Icons.rounded_corner),
                ),
              ],
              selected: {_eyeStyle},
              onSelectionChanged: (Set<CustomQrEyeStyle> newSelection) {
                setState(() {
                  _eyeStyle = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Data Module Style'),
            const SizedBox(height: 8),
            SegmentedButton<CustomQrDataModuleStyle>(
              segments: const [
                ButtonSegment(
                  value: CustomQrDataModuleStyle.square,
                  label: Text('Square'),
                  icon: Icon(Icons.square_outlined),
                ),
                ButtonSegment(
                  value: CustomQrDataModuleStyle.circle,
                  label: Text('Circle'),
                  icon: Icon(Icons.circle_outlined),
                ),
                ButtonSegment(
                  value: CustomQrDataModuleStyle.rounded,
                  label: Text('Rounded'),
                  icon: Icon(Icons.rounded_corner),
                ),
              ],
              selected: {_dataModuleStyle},
              onSelectionChanged: (Set<CustomQrDataModuleStyle> newSelection) {
                setState(() {
                  _dataModuleStyle = newSelection.first;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpirySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Expiry Settings',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Set Expiry'),
              subtitle: const Text(
                'QR code will expire after certain conditions',
              ),
              value: _hasExpiry,
              onChanged: (value) {
                setState(() {
                  _hasExpiry = value;
                  if (!value) {
                    _expiryDate = null;
                    _maxScans = null;
                    _isOneTime = false;
                  }
                });
              },
            ),
            if (_hasExpiry) ...[
              const SizedBox(height: 16),
              // Quick preset buttons
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('5 min'),
                    selected: false,
                    onSelected: (_) {
                      setState(() {
                        _expiryDate = DateTime.now().add(
                          const Duration(minutes: 5),
                        );
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('1 hour'),
                    selected: false,
                    onSelected: (_) {
                      setState(() {
                        _expiryDate = DateTime.now().add(
                          const Duration(hours: 1),
                        );
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('1 day'),
                    selected: false,
                    onSelected: (_) {
                      setState(() {
                        _expiryDate = DateTime.now().add(
                          const Duration(days: 1),
                        );
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('1 week'),
                    selected: false,
                    onSelected: (_) {
                      setState(() {
                        _expiryDate = DateTime.now().add(
                          const Duration(days: 7),
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Expiry Date'),
                subtitle: Text(
                  _expiryDate != null
                      ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year} at ${_expiryDate!.hour.toString().padLeft(2, '0')}:${_expiryDate!.minute.toString().padLeft(2, '0')}'
                      : 'Not set',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _selectExpiryDate,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Max Scans'),
                subtitle: Text(_maxScans?.toString() ?? 'Unlimited'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _setMaxScans,
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.looks_one),
                title: const Text('One-time Use'),
                subtitle: const Text('QR code expires after first scan'),
                value: _isOneTime,
                onChanged: (value) {
                  setState(() {
                    _isOneTime = value;
                    if (value) {
                      _maxScans = 1;
                    }
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton(QrLinkState state) {
    final isLoading = state is QrLinkLoading;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : _createQrCode,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Create QR & Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.link, size: 20),
                  ],
                ),
      ),
    );
  }

  void _pickColor(bool isForeground) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Select ${isForeground ? 'Foreground' : 'Background'} Color',
            ),
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    Colors.black,
                    Colors.white,
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.teal,
                    Colors.pink,
                    Colors.indigo,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isForeground) {
                            _foregroundColor = color;
                          } else {
                            _backgroundColor = color;
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _expiryDate ?? DateTime.now().add(const Duration(minutes: 5)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      if (!mounted) return;

      // Also pick time for more precise expiry
      final timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _expiryDate ?? DateTime.now().add(const Duration(minutes: 5)),
        ),
      );

      if (timePicked != null) {
        setState(() {
          _expiryDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
      } else {
        // If user cancels time picker, just use the date with current time
        setState(() {
          _expiryDate = picked;
        });
      }
    }
  }

  void _setMaxScans() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _maxScans?.toString());
        return AlertDialog(
          title: const Text('Set Max Scans'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Maximum number of scans',
              hintText: 'Leave empty for unlimited',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                setState(() {
                  _maxScans = value;
                  if (value == 1) {
                    _isOneTime = true;
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  void _createQrCode() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final config = QrLinkConfig(
        id: '', // Will be set by BLoC
        userId: '', // Will be set by BLoC
        linkSlug: _slugController.text.trim(),
        description: _descriptionController.text.trim(),
        selectedLinkIds: _selectedLinkIds.toList(),
        qrCustomization: QrCustomization(
          foregroundColor: _foregroundColor,
          backgroundColor: _backgroundColor,
          eyeStyle: _eyeStyle,
          dataModuleStyle: _dataModuleStyle,
        ),
        expirySettings: ExpirySettings(
          expiryDate: _expiryDate,
          maxScans: _maxScans,
          isOneTime: _isOneTime,
        ),
        createdAt: now,
        updatedAt: now,
      );

      // Use BLoC to create QR config (saves to Supabase)
      context.read<QrLinkBloc>().add(QrLinkCreateRequested(config));
    }
  }

  void _showQrShareModal(QrLinkConfig config) {
    // Create the QR widget to show in the modal
    final qrWidget = QrImageView(
      data: config.shareableLink,
      version: QrVersions.auto,
      size: 200.0,
      backgroundColor: config.qrCustomization.backgroundColor,
      eyeStyle: QrEyeStyle(
        eyeShape: _getQrEyeShape(config.qrCustomization.eyeStyle),
        color: config.qrCustomization.foregroundColor,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: _getQrDataModuleShape(
          config.qrCustomization.dataModuleStyle,
        ),
        color: config.qrCustomization.foregroundColor,
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => QrShareModal(
            qrConfig: config,
            qrWidget: qrWidget,
            onSavePreset: (preset) {
              // Preset is already saved to local storage by the modal
              // Just show success message since modal handles the saving
            },
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
