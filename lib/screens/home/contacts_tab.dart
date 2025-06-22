import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../models/saved_contact.dart';
import '../../services/contacts_service.dart';
import '../../services/local_storage_service.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  final ContactsService _contactsService = ContactsService();
  final LocalStorageService _localStorage = LocalStorageService();

  List<UserProfile> _phoneContacts = [];
  List<SavedContact> _scannedContacts = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllContacts();
  }

  Future<void> _loadAllContacts() async {
    setState(() => _isLoading = true);
    try {
      // Load phone contacts, local scanned contacts, and Supabase saved contacts
      final phoneContactsFuture = _contactsService.getAppUsersFromContacts();
      final localScannedContactsFuture = _localStorage.getAllSavedContacts();
      final supabaseSavedContactsFuture = _contactsService.getSavedContacts();

      final results = await Future.wait([
        phoneContactsFuture,
        localScannedContactsFuture,
        supabaseSavedContactsFuture,
      ]);

      final phoneContacts = results[0] as List<UserProfile>;
      final localScannedContacts = results[1] as List<SavedContact>;
      final supabaseSavedContacts = results[2] as List<UserProfile>;

      // Combine local and Supabase saved contacts, avoiding duplicates
      final allScannedContacts = <SavedContact>[];

      // Add local contacts first
      allScannedContacts.addAll(localScannedContacts);

      // Add Supabase contacts that aren't already in local storage
      final localContactIds =
          localScannedContacts.map((c) => c.profile.id).toSet();
      for (var supabaseContact in supabaseSavedContacts) {
        if (!localContactIds.contains(supabaseContact.id)) {
          allScannedContacts.add(
            SavedContact(
              id: supabaseContact.id,
              profile: supabaseContact,
              scannedAt: supabaseContact.createdAt,
              hasUpdates: false,
            ),
          );
        }
      }

      setState(() {
        _phoneContacts = phoneContacts;
        _scannedContacts = allScannedContacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load contacts: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<dynamic> get filteredContacts {
    List<dynamic> allContacts = [];

    // Add phone contacts
    if (_searchQuery.isEmpty) {
      allContacts.addAll(_phoneContacts);
    } else {
      allContacts.addAll(
        _phoneContacts.where((contact) {
          return contact.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              (contact.email.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              )) ||
              (contact.phone?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false);
        }),
      );
    }

    // Add scanned contacts (avoid duplicates by checking if phone contact already exists)
    final phoneContactIds = _phoneContacts.map((c) => c.id).toSet();

    if (_searchQuery.isEmpty) {
      allContacts.addAll(
        _scannedContacts.where(
          (saved) => !phoneContactIds.contains(saved.profile.id),
        ),
      );
    } else {
      allContacts.addAll(
        _scannedContacts.where((saved) {
          final profile = saved.profile;
          final matchesSearch =
              profile.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (profile.email.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              )) ||
              (profile.phone?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false);
          return matchesSearch && !phoneContactIds.contains(profile.id);
        }),
      );
    }

    return allContacts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Import contacts button
          if (_phoneContacts.isEmpty && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadAllContacts,
                  icon: const Icon(Icons.import_contacts),
                  label: const Text('Import Phone Contacts'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),

          // Contacts list
          Expanded(child: _buildContactsList()),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final contacts = filteredContacts;

    if (contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.contacts, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _phoneContacts.isEmpty ? 'No contacts yet' : 'No contacts found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              _phoneContacts.isEmpty
                  ? 'Import your phone contacts or scan QR codes to add contacts'
                  : 'Try a different search term',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllContacts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];

          if (contact is UserProfile) {
            return _buildContactCard(contact: contact, isFromPhone: true);
          } else if (contact is SavedContact) {
            return _buildScannedContactCard(contact);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContactCard({
    required UserProfile contact,
    required bool isFromPhone,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewContactDetails(contact),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              Hero(
                tag: 'avatar_${contact.id}',
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      contact.profileImageUrl != null
                          ? NetworkImage(contact.profileImageUrl!)
                          : null,
                  onBackgroundImageError:
                      contact.profileImageUrl != null
                          ? (exception, stackTrace) {
                            // Handle image loading errors (like 429 rate limit)
                            debugPrint(
                              'Contact image failed to load: $exception',
                            );
                          }
                          : null,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child:
                      contact.profileImageUrl == null
                          ? Text(
                            contact.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : null,
                ),
              ),
              const SizedBox(width: 16),

              // Contact info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isFromPhone)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Contact',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (contact.bio != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        contact.bio!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.link, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${contact.customLinks.length} links',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              if (isFromPhone) ...[
                IconButton(
                  onPressed: () => _saveToLocalContacts(contact),
                  icon: const Icon(Icons.save_alt),
                  tooltip: 'Save to contacts',
                ),
              ],
              IconButton(
                onPressed: () => _viewContactDetails(contact),
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannedContactCard(SavedContact savedContact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewSavedContactDetails(savedContact),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    savedContact.profile.profileImageUrl != null
                        ? NetworkImage(savedContact.profile.profileImageUrl!)
                        : null,
                onBackgroundImageError:
                    savedContact.profile.profileImageUrl != null
                        ? (exception, stackTrace) {
                          // Handle image loading errors (like 429 rate limit)
                          debugPrint(
                            'Saved contact image failed to load: $exception',
                          );
                        }
                        : null,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child:
                    savedContact.profile.profileImageUrl == null
                        ? Text(
                          savedContact.profile.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 16),

              // Contact info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            savedContact.profile.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Scanned',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (savedContact.profile.bio != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        savedContact.profile.bio!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Saved ${_formatDate(savedContact.scannedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteSavedContact(savedContact);
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                child: const Icon(Icons.more_vert),
              ),
              IconButton(
                onPressed: () => _viewSavedContactDetails(savedContact),
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _viewContactDetails(UserProfile contact) {
    // TODO: Navigate to contact details screen
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(contact.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (contact.email.isNotEmpty) Text('Email: ${contact.email}'),
                if (contact.phone != null) Text('Phone: ${contact.phone}'),
                if (contact.bio != null) Text('Bio: ${contact.bio}'),
                Text('Links: ${contact.customLinks.length}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _viewSavedContactDetails(SavedContact savedContact) {
    _viewContactDetails(savedContact.profile);
  }

  Future<void> _saveToLocalContacts(UserProfile contact) async {
    try {
      final savedContact = SavedContact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        profile: contact,
        scannedAt: DateTime.now(),
      );

      await _localStorage.saveScanedContact(savedContact);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _loadAllContacts(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save contact: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteSavedContact(SavedContact savedContact) async {
    try {
      await _localStorage.deleteSavedContact(savedContact.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _loadAllContacts(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete contact: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
