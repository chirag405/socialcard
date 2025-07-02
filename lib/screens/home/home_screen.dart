import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../models/qr_preset.dart';
import '../../widgets/presets_drawer.dart';
import '../../services/local_storage_service.dart';
import '../qr/qr_create_screen.dart';
import '../qr/qr_history_screen.dart';
import 'profile/profile_edit_screen.dart';
import 'profile_tab.dart';
import 'contacts_tab.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  final LocalStorageService _localStorage = LocalStorageService();

  // Tab order - can be customized
  final List<int> _tabOrder = [0, 1]; // 0 = Profile, 1 = Contacts

  // QR Presets (Local-First approach)
  List<QrPreset> _qrPresets = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Use a post-frame callback to ensure the widget is fully built before loading profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  void _loadUserProfile() {
    final authBloc = context.read<AuthBloc>();
    print('🔥 HomeScreen: Current auth state: ${authBloc.state.runtimeType}');

    if (authBloc.state is AuthAuthenticated) {
      final userId = (authBloc.state as AuthAuthenticated).userId;
      print('🔥 HomeScreen: Loading profile for userId: $userId');
      context.read<ProfileBloc>().add(ProfileLoadRequested(userId));
      _loadQrPresets(userId); // Load presets from local storage
    } else {
      print('🔥 HomeScreen: User not authenticated, cannot load profile');
    }
  }

  Future<void> _loadQrPresets(String userId) async {
    try {
      final presets = await _localStorage.getAllQrPresets(userId);
      setState(() {
        _qrPresets = presets;
      });
    } catch (e) {
      print('Error loading QR presets: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showScannerScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ScannerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          IconButton(
            onPressed: _showScannerScreen,
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan QR Code',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _navigateToProfileEdit();
                  break;
                case 'presets':
                  _showPresetsDrawer();
                  break;
                case 'history':
                  _navigateToQrHistory();
                  break;
                case 'settings':
                  // Navigate to settings
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Edit Profile'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'presets',
                    child: ListTile(
                      leading: Icon(Icons.bookmark),
                      title: Text('QR Presets'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'history',
                    child: ListTile(
                      leading: Icon(Icons.history),
                      title: Text('QR History'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [ProfileTab(), ContactsTab()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
        ],
      ),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton.extended(
                onPressed: () {
                  // Navigate to QR/Link creation
                  _showCreateQrDialog();
                },
                icon: const Icon(Icons.qr_code),
                label: const Text('Create QR'),
              )
              : null,
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'My Profile';
      case 1:
        return 'Saved Contacts';
      default:
        return 'SocialCard Pro';
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _navigateToProfileEdit() {
    final profileBloc = context.read<ProfileBloc>();
    final state = profileBloc.state;

    if (state is ProfileLoaded) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileEditScreen(profile: state.profile),
        ),
      );
    }
  }

  void _navigateToQrHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrHistoryScreen()),
    );
  }

  void _showCreateQrDialog() {
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
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Create New QR Code',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.qr_code,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('Standard QR Code'),
                  subtitle: const Text(
                    'Create a basic QR code for your profile',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QrCreateScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.link,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  title: const Text('Custom Link'),
                  subtitle: const Text(
                    'Create a shareable link with custom slug',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to link creation screen
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showPresetsDrawer() {
    showDialog(
      context: context,
      builder:
          (context) => PresetsDrawer(
            onPresetSelected: (preset) {
              print('🎯 Selected preset: ${preset.name}');
              // Navigate to QR create screen with preset data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QrCreateScreen(preset: preset),
                ),
              );
            },
          ),
    );
  }
}
