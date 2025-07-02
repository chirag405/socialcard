import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/contacts_service.dart';
import '../../services/supabase_service.dart';
import '../../models/user_profile.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isPermissionGranted = false;
  bool _isLoading = true;
  final ContactsService _contactsService = ContactsService();
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isPermissionGranted = status == PermissionStatus.granted;
      _isLoading = false;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _handleScanResult(barcode.rawValue!);
        break;
      }
    }
  }

  void _handleScanResult(String result) {
    // Stop the camera
    cameraController.stop();

    // Show result dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('QR Code Scanned'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Scanned content:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to home
                },
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Process the scanned result (fetch profile, save contact, etc.)
                  _processScanResult(result);
                },
                child: const Text('View Profile'),
              ),
            ],
          ),
    );
  }

  Future<void> _processScanResult(String result) async {
    try {
      // Parse the QR code result to extract profile info (slug and optional user ID)
      Map<String, String>? profileInfo = _extractProfileInfo(result);

      if (profileInfo == null || !profileInfo.containsKey('slug')) {
        // If not a SocialCard QR, try to open as URL
        if (await canLaunchUrl(Uri.parse(result))) {
          await launchUrl(Uri.parse(result));
        } else {
          _showError('Invalid QR code format');
        }
        return;
      }

      final profileSlug = profileInfo['slug']!;
      final userId = profileInfo['userId']; // Optional user ID

      // Show loading
      _showLoadingDialog();

      // Fetch the profile from the QR config
      final profile = await _fetchProfileFromSlug(profileSlug, userId: userId);

      if (profile != null) {
        // Hide loading
        Navigator.of(context).pop();

        // Save contact automatically
        await _saveScannedContact(profile);

        // Show profile details
        _showProfileDialog(profile);
      } else {
        Navigator.of(context).pop();
        _showError('Profile not found or no longer available');
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showError('Failed to process QR code: $e');
    }
  }

  Map<String, String>? _extractProfileInfo(String qrResult) {
    // Handle different QR formats:
    // 1. Direct slug: "chirag"
    // 2. Full URL: "https://domain.com/profile?slug=chirag&user=user-id"
    // 3. Legacy URL: "https://domain.com/profile?slug=chirag"
    // 4. Short URL: "https://domain.com/chirag"

    if (qrResult.contains('http')) {
      final uri = Uri.tryParse(qrResult);
      if (uri != null) {
        // Check for slug parameter
        if (uri.queryParameters.containsKey('slug')) {
          final slug = uri.queryParameters['slug'];
          final userId = uri.queryParameters['user']; // Optional user ID
          if (slug != null) {
            return {'slug': slug, if (userId != null) 'userId': userId};
          }
        }
        // Check for slug in path (legacy format)
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          return {'slug': pathSegments.last};
        }
      }
    } else {
      // Direct slug (legacy format)
      return {'slug': qrResult.trim()};
    }

    return null;
  }

  Future<UserProfile?> _fetchProfileFromSlug(
    String slug, {
    String? userId,
  }) async {
    try {
      // Get QR config by slug (and optionally by user ID for disambiguation)
      final qrConfig = await _supabaseService.getQrConfigBySlug(
        slug,
        userId: userId,
      );
      if (qrConfig == null) return null;

      // Get user profile
      final profile = await _supabaseService.getUserProfile(qrConfig.userId);
      return profile;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<void> _saveScannedContact(UserProfile profile) async {
    try {
      final currentUserId = _supabaseService.currentUserId;
      if (currentUserId != null && currentUserId != profile.id) {
        // Don't save your own profile
        await _contactsService.saveScannedContact(profile.id);
      }
    } catch (e) {
      print('Error saving contact: $e');
      // Don't show error for contact saving, just log it
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Loading profile...'),
              ],
            ),
          ),
    );
  }

  void _showProfileDialog(UserProfile profile) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(profile.name),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profile.email.isNotEmpty) ...[
                    Text('Email: ${profile.email}'),
                    const SizedBox(height: 8),
                  ],
                  if (profile.phone != null) ...[
                    Text('Phone: ${profile.phone}'),
                    const SizedBox(height: 8),
                  ],
                  if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                    Text('Bio: ${profile.bio}'),
                    const SizedBox(height: 8),
                  ],
                  Text('Links: ${profile.customLinks.length}'),
                  if (profile.customLinks.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Custom Links:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...profile.customLinks.map(
                      (link) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('• ${link.displayName}: ${link.url}'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              // Show save button if not already saved and not own profile
              if (_supabaseService.currentUserId != profile.id)
                FutureBuilder<bool>(
                  future: _contactsService.isContactSaved(profile.id),
                  builder: (context, snapshot) {
                    final isAlreadySaved = snapshot.data ?? false;

                    if (isAlreadySaved) {
                      return TextButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.check, color: Colors.green),
                        label: const Text(
                          'Saved',
                          style: TextStyle(color: Colors.green),
                        ),
                      );
                    }

                    return FilledButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _showSaveContactDialog(profile);
                      },
                      icon: const Icon(Icons.contact_phone),
                      label: const Text('Save Contact'),
                    );
                  },
                ),
            ],
          ),
    );
  }

  Future<void> _showSaveContactDialog(UserProfile profile) async {
    final notesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Save Contact'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Save ${profile.name} to your contacts?'),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Add personal notes about this contact...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (result == true) {
      try {
        _showLoadingDialog();

        await _contactsService.saveScannedContact(
          profile.id,
          notes:
              notesController.text.trim().isNotEmpty
                  ? notesController.text.trim()
                  : null,
        );

        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${profile.name} saved to contacts!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Contacts',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to contacts tab
                DefaultTabController.of(context)?.animateTo(1);
              },
            ),
          ),
        );
      } catch (e) {
        Navigator.of(context).pop(); // Close loading dialog
        _showError('Failed to save contact: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    Navigator.of(context).pop(); // Go back to home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => cameraController.toggleTorch(),
            icon: const Icon(Icons.flash_on),
          ),
          IconButton(
            onPressed: () => cameraController.switchCamera(),
            icon: const Icon(Icons.flip_camera_ios),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : !_isPermissionGranted
              ? _buildPermissionDenied()
              : _buildScanner(),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Camera Permission Required',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'To scan QR codes, please grant camera permission in your device settings.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => openAppSettings(),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(controller: cameraController, onDetect: _onDetect),
        _buildScannerOverlay(),
      ],
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.primary,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ),
      child: const Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Place QR code inside the frame to scan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(
          rect.left,
          rect.top,
          rect.left + borderRadius,
          rect.top,
        )
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderHeightSize = height / 2;
    final cutOutWidth = cutOutSize;
    final cutOutHeight = cutOutSize;

    final backgroundPaint =
        Paint()
          ..color = overlayColor
          ..style = PaintingStyle.fill;

    final boxPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(
      rect.left + borderWidthSize - cutOutWidth / 2,
      rect.top + borderHeightSize - cutOutHeight / 2,
      cutOutWidth,
      cutOutHeight,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
        Paint()..blendMode = BlendMode.clear,
      )
      ..restore();

    // Draw the border
    final borderRect = RRect.fromRectAndRadius(
      cutOutRect,
      Radius.circular(borderRadius),
    );

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left, cutOutRect.top + borderLength)
        ..lineTo(cutOutRect.left, cutOutRect.top + borderRadius)
        ..quadraticBezierTo(
          cutOutRect.left,
          cutOutRect.top,
          cutOutRect.left + borderRadius,
          cutOutRect.top,
        )
        ..lineTo(cutOutRect.left + borderLength, cutOutRect.top),
      boxPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right - borderLength, cutOutRect.top)
        ..lineTo(cutOutRect.right - borderRadius, cutOutRect.top)
        ..quadraticBezierTo(
          cutOutRect.right,
          cutOutRect.top,
          cutOutRect.right,
          cutOutRect.top + borderRadius,
        )
        ..lineTo(cutOutRect.right, cutOutRect.top + borderLength),
      boxPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left, cutOutRect.bottom - borderLength)
        ..lineTo(cutOutRect.left, cutOutRect.bottom - borderRadius)
        ..quadraticBezierTo(
          cutOutRect.left,
          cutOutRect.bottom,
          cutOutRect.left + borderRadius,
          cutOutRect.bottom,
        )
        ..lineTo(cutOutRect.left + borderLength, cutOutRect.bottom),
      boxPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right - borderLength, cutOutRect.bottom)
        ..lineTo(cutOutRect.right - borderRadius, cutOutRect.bottom)
        ..quadraticBezierTo(
          cutOutRect.right,
          cutOutRect.bottom,
          cutOutRect.right,
          cutOutRect.bottom - borderRadius,
        )
        ..lineTo(cutOutRect.right, cutOutRect.bottom - borderLength),
      boxPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
