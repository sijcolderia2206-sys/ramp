// lib/features/settings/sub_screens/account_settings_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/state/ramp_state.dart';
import '../../../core/theme/ramp_theme.dart';
import '../../../core/utils/toast_service.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState
    extends ConsumerState<AccountSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _contactController;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(landlordProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _roleController = TextEditingController(text: profile.role);
    _contactController = TextEditingController(text: profile.contact);
    _avatarPath = profile.avatarPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _avatarPath = picked.path;
        });
        ToastService.showSuccess(
            source == ImageSource.camera ? 'Photo captured' : 'Photo selected');
      }
    } catch (e) {
      ToastService.showError('Permission or camera error: $e');
    }
  }

  void _showImageSourceSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Picture',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Text(
                  'Select or capture a new photo for your profile avatar.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: RampColors.softBlueTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_camera_rounded,
                        color: RampColors.primary),
                  ),
                  title: Text(
                    'Take Photo',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Capture using device camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: RampColors.softBlueTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded,
                        color: RampColors.primary),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Select an image from photo library'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_avatarPath != null && _avatarPath!.isNotEmpty)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: RampColors.dangerTint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: RampColors.danger),
                    ),
                    title: Text(
                      'Remove Photo',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: RampColors.danger,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _avatarPath = null);
                      ToastService.showInfo('Profile picture removed');
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final role = _roleController.text.trim();
    final contact = _contactController.text.trim();

    if (name.isEmpty) {
      ToastService.showError('Landlord name cannot be empty');
      return;
    }

    ref.read(landlordProfileProvider.notifier).state = (
      name: name,
      role: role.isEmpty ? 'Property Representative / Admin' : role,
      contact: contact.isEmpty
          ? '0917-123-4567 • support@ramp-properties.com'
          : contact,
      avatarPath: _avatarPath,
    );

    persistAppSettings(
      landlordName: name,
      landlordRole: role,
      landlordContact: contact,
      landlordAvatarPath: _avatarPath,
    );

    ToastService.showSuccess('Account profile updated successfully');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasLocalAvatar = _avatarPath != null &&
        _avatarPath!.isNotEmpty &&
        File(_avatarPath!).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account & Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Summary Card with Avatar Image Picker
                  RampCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _showImageSourceSheet,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: RampColors.primary,
                                backgroundImage: hasLocalAvatar
                                    ? FileImage(File(_avatarPath!))
                                    : null,
                                child: !hasLocalAvatar
                                    ? Text(
                                        _nameController.text.trim().isEmpty
                                            ? 'AP'
                                            : _nameController.text
                                                .trim()
                                                .substring(0, 1)
                                                .toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: RampColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 13,
                                    color: Colors.white,
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
                              Text(
                                _nameController.text.isNotEmpty
                                    ? _nameController.text
                                    : 'Landlord Account',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _roleController.text.isNotEmpty
                                    ? _roleController.text
                                    : 'Property Representative',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: _showImageSourceSheet,
                                child: Text(
                                  'Change Photo',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: RampColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'PERSONAL & BUSINESS DETAILS',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  RampCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Landlord / Business Name',
                            prefixIcon: Icon(Icons.business_rounded),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _roleController,
                          decoration: const InputDecoration(
                            labelText: 'Role / Designation',
                            prefixIcon: Icon(Icons.badge_rounded),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _contactController,
                          decoration: const InputDecoration(
                            labelText: 'Contact Information',
                            prefixIcon: Icon(Icons.contact_phone_rounded),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save_rounded),
                      label: Text(
                        'SAVE PROFILE CHANGES',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RampColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
