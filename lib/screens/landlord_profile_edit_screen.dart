// lib/screens/landlord_profile_edit_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/ramp_theme.dart';
import '../core/utils/toast_service.dart';
import '../core/validation/app_validators.dart';

class LandlordProfileEditScreen extends StatefulWidget {
  final String initialName;
  final String initialRole;
  final String initialContact;
  final String? initialAvatarPath;
  final ValueChanged<LandlordProfileValues> onSaved;

  const LandlordProfileEditScreen({
    super.key,
    required this.initialName,
    required this.initialRole,
    required this.initialContact,
    this.initialAvatarPath,
    required this.onSaved,
  });

  @override
  State<LandlordProfileEditScreen> createState() =>
      _LandlordProfileEditScreenState();
}

class LandlordProfileValues {
  final String name;
  final String role;
  final String contact;
  final String? avatarPath;

  const LandlordProfileValues({
    required this.name,
    required this.role,
    required this.contact,
    this.avatarPath,
  });
}

class _LandlordProfileEditScreenState extends State<LandlordProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _roleController;
  late final TextEditingController _contactController;
  String? _avatarPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _roleController = TextEditingController(text: widget.initialRole);
    _contactController = TextEditingController(text: widget.initialContact);
    _avatarPath = widget.initialAvatarPath;
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
      ToastService.showError('Permission or media error: $e');
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

  Future<bool> _confirmLeave() async {
    if (!_hasChanges) return true;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Leave profile editing?'),
            content: const Text(
                'Any changes entered on this page will be discarded.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('KEEP EDITING'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('LEAVE'),
              ),
            ],
          ),
        ) ??
        false;
  }

  bool get _hasChanges =>
      _nameController.text != widget.initialName ||
      _roleController.text != widget.initialRole ||
      _contactController.text != widget.initialContact ||
      _avatarPath != widget.initialAvatarPath;

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameController.text.trim();

    setState(() => _isSaving = true);
    widget.onSaved(
      LandlordProfileValues(
        name: name,
        role: _roleController.text.trim(),
        contact: _contactController.text.trim(),
        avatarPath: _avatarPath,
      ),
    );
    Navigator.pop(context);
  }

  Widget _field({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasLocalAvatar = _avatarPath != null &&
        _avatarPath!.isNotEmpty &&
        File(_avatarPath!).existsSync();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmLeave() && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () async {
              if (await _confirmLeave() && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar Banner Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _showImageSourceSheet,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 36,
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
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: RampColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 14,
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
                                    'Profile Avatar',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tap the avatar to take a picture or pick from gallery.',
                                    style: GoogleFonts.poppins(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Personal Information',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            _field(
                              label: 'Display Name',
                              hint: 'Enter a display name',
                              icon: Icons.badge_outlined,
                              controller: _nameController,
                              validator: (value) => AppValidators.personName(
                                  value,
                                  label: 'display name'),
                            ),
                            const SizedBox(height: 14),
                            _field(
                              label: 'Role',
                              hint: 'e.g. Property Representative / Admin',
                              icon: Icons.work_outline_rounded,
                              controller: _roleController,
                              validator: (value) => AppValidators.requiredText(
                                  value,
                                  label: 'a role',
                                  minLength: 3,
                                  maxLength: 80),
                            ),
                            const SizedBox(height: 14),
                            _field(
                              label: 'Contact Details',
                              hint: 'Phone number and email address',
                              icon: Icons.contact_phone_outlined,
                              controller: _contactController,
                              maxLines: 2,
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) {
                                  return 'Enter a phone number and email address.';
                                }
                                final email = RegExp(
                                        r"[\w.!#$%&'*+/=?^_`{|}~-]+@[\w.-]+\.[A-Za-z]{2,}")
                                    .firstMatch(text)
                                    ?.group(0);
                                if (AppValidators.email(email) != null) {
                                  return 'Include a valid email, such as name@gmail.com.';
                                }
                                final phone =
                                    RegExp(r'(?:\+?63|0)9[\d ()-]{9,14}')
                                        .firstMatch(text)
                                        ?.group(0);
                                if (AppValidators.philippinePhone(phone) !=
                                    null) {
                                  return 'Include a valid 11-digit PH mobile number.';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _isSaving ? null : _save,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_rounded),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child:
                                Text(_isSaving ? 'SAVING...' : 'SAVE CHANGES'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
