import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../models/user_profile.dart';

class ProfileEditScreen extends StatefulWidget {
  final UserProfile profile;

  const ProfileEditScreen({super.key, required this.profile});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late bool _isDiscoverable;

  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _bioController = TextEditingController(text: widget.profile.bio);
    _isDiscoverable = widget.profile.isDiscoverable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileUpdating;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileImageSection(),
                  const SizedBox(height: 32),
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 24),
                  _buildBioSection(),
                  const SizedBox(height: 24),
                  _buildPrivacySection(),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : widget.profile.profileImageUrl != null
                        ? NetworkImage(widget.profile.profileImageUrl!)
                            as ImageProvider
                        : null,
                onBackgroundImageError:
                    widget.profile.profileImageUrl != null
                        ? (exception, stackTrace) {
                          // Handle image loading errors (like 429 rate limit)
                          debugPrint(
                            'Profile image failed to load: $exception',
                          );
                        }
                        : null,
                child:
                    _selectedImage == null &&
                            widget.profile.profileImageUrl == null
                        ? Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey.shade400,
                        )
                        : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _showImagePickerOptions,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _showImagePickerOptions,
            child: const Text('Change Profile Picture'),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: 'Optional',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'About',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell us about yourself...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 4,
              maxLength: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.privacy_tip,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Privacy Settings',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Make me discoverable'),
              subtitle: const Text(
                'Allow people who have your phone number in their contacts to find your SocialCard profile',
              ),
              value: _isDiscoverable,
              onChanged: (value) {
                setState(() {
                  _isDiscoverable = value;
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_selectedImage != null ||
                    widget.profile.profileImageUrl != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Remove Photo',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = widget.profile.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        bio:
            _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
        isDiscoverable: _isDiscoverable,
        updatedAt: DateTime.now(),
      );

      context.read<ProfileBloc>().add(ProfileUpdateRequested(updatedProfile));

      if (_selectedImage != null) {
        context.read<ProfileBloc>().add(
          ProfileImageUpdateRequested(_selectedImage!.path),
        );
      }
    }
  }
}
