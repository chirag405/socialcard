import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_profile.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';

class CustomLinksSection extends StatelessWidget {
  final UserProfile profile;

  const CustomLinksSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.link,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Custom Links',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    _showAddLinkDialog(context);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Link'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (profile.customLinks.isEmpty)
              _buildEmptyState(context)
            else
              _buildLinksList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.link_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No custom links yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Add links to your social media, website, or portfolio',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLinksList(BuildContext context) {
    final sortedLinks = List<CustomLink>.from(profile.customLinks)
      ..sort((a, b) => a.order.compareTo(b.order));

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final List<CustomLink> items = List<CustomLink>.from(sortedLinks);
        final CustomLink item = items.removeAt(oldIndex);
        items.insert(newIndex, item);

        context.read<ProfileBloc>().add(CustomLinksReordered(items));
      },
      itemCount: sortedLinks.length,
      itemBuilder: (context, index) {
        final link = sortedLinks[index];
        return _buildLinkItem(context, link, index, Key(link.id));
      },
    );
  }

  Widget _buildLinkItem(
    BuildContext context,
    CustomLink link,
    int index,
    Key key,
  ) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openLink(context, link.url),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  _getIconForLink(link.iconName),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                link.displayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                link.url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showEditLinkDialog(context, link),
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(context, link),
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    tooltip: 'Delete',
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

  void _showAddLinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => _LinkDialog(
            title: 'Add Custom Link',
            onSave: (displayName, url, iconName) {
              final newLink = CustomLink(
                id: '',
                url: url,
                displayName: displayName,
                iconName: iconName,
                order: 0,
              );
              context.read<ProfileBloc>().add(CustomLinkAdded(newLink));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
    );
  }

  void _showEditLinkDialog(BuildContext context, CustomLink link) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => _LinkDialog(
            title: 'Edit Custom Link',
            initialDisplayName: link.displayName,
            initialUrl: link.url,
            initialIconName: link.iconName,
            onSave: (displayName, url, iconName) {
              final updatedLink = link.copyWith(
                displayName: displayName,
                url: url,
                iconName: iconName,
              );
              context.read<ProfileBloc>().add(CustomLinkUpdated(updatedLink));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CustomLink link) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete Link'),
            content: Text(
              'Are you sure you want to delete "${link.displayName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<ProfileBloc>().add(CustomLinkRemoved(link.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link deleted successfully!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _openLink(BuildContext context, String url) async {
    try {
      Uri uri;
      if (url.startsWith('http://') || url.startsWith('https://')) {
        uri = Uri.parse(url);
      } else {
        uri = Uri.parse('https://$url');
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _LinkDialog extends StatefulWidget {
  final String title;
  final String? initialDisplayName;
  final String? initialUrl;
  final String? initialIconName;
  final Function(String displayName, String url, String iconName) onSave;

  const _LinkDialog({
    required this.title,
    required this.onSave,
    this.initialDisplayName,
    this.initialUrl,
    this.initialIconName,
  });

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  late TextEditingController _displayNameController;
  late TextEditingController _urlController;
  String _selectedIcon = 'link';

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'link', 'icon': Icons.link, 'label': 'Link'},
    {'name': 'website', 'icon': Icons.language, 'label': 'Website'},
    {'name': 'email', 'icon': Icons.email, 'label': 'Email'},
    {'name': 'phone', 'icon': Icons.phone, 'label': 'Phone'},
    {'name': 'instagram', 'icon': Icons.camera_alt, 'label': 'Instagram'},
    {'name': 'twitter', 'icon': Icons.alternate_email, 'label': 'Twitter'},
    {'name': 'linkedin', 'icon': Icons.business, 'label': 'LinkedIn'},
    {'name': 'github', 'icon': Icons.code, 'label': 'GitHub'},
    {'name': 'facebook', 'icon': Icons.facebook, 'label': 'Facebook'},
    {'name': 'youtube', 'icon': Icons.play_circle_filled, 'label': 'YouTube'},
    {'name': 'tiktok', 'icon': Icons.music_note, 'label': 'TikTok'},
  ];

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.initialDisplayName,
    );
    _urlController = TextEditingController(text: widget.initialUrl);
    _selectedIcon = widget.initialIconName ?? 'link';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  bool _isValidUrl(String url) {
    // Basic URL validation
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );

    // Also accept email and phone patterns
    final emailPattern = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    final phonePattern = RegExp(r'^\+?[\d\s\-\(\)]+$');

    return urlPattern.hasMatch(url) ||
        emailPattern.hasMatch(url) ||
        phonePattern.hasMatch(url) ||
        url.startsWith('http://') ||
        url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'e.g., My Website',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedIcon,
              decoration: const InputDecoration(labelText: 'Icon'),
              items:
                  _iconOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option['name'],
                      child: Row(
                        children: [
                          Icon(option['icon']),
                          const SizedBox(width: 8),
                          Text(option['label']),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIcon = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final displayName = _displayNameController.text.trim();
            final url = _urlController.text.trim();

            if (displayName.isEmpty || url.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in all fields'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Basic URL validation
            if (!_isValidUrl(url)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid URL'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            widget.onSave(displayName, url, _selectedIcon);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
