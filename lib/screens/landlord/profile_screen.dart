// lib/screens/landlord/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme.dart';
import '../../core/supabase_auth_service.dart';
import '../../providers/session_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final SupabaseAuthService _authService = SupabaseAuthService();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    }
  }

  String get _firstName {
    final email = _authService.activeEmail;
    if (email.contains('@')) {
      final part = email.split('@').first;
      if (part.toLowerCase() == 'landlord') return 'Apex';
      return part[0].toUpperCase() + part.substring(1);
    }
    return 'Apex';
  }

  @override
  Widget build(BuildContext context) {
    final email = _authService.activeEmail;
    final initialLetter = _firstName.isNotEmpty ? _firstName[0].toUpperCase() : 'A';
    final sessionState = ref.watch(sessionProvider);
    final nowSession = sessionState.nowSession;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(RampTheme.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with Change Picture Button
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: RampTheme.primaryBlue,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? Text(
                            initialLetter,
                            style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: RampTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: RampTheme.spacing16),

            Center(
              child: Column(
                children: [
                  Text(
                    _firstName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: RampTheme.spacing24),

            // Landlord Credentials
            Container(
              padding: const EdgeInsets.all(RampTheme.spacing20),
              decoration: BoxDecoration(
                color: RampTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: RampTheme.standardShadow,
              ),
              child: Column(
                children: [
                  _ProfileDetailTile(
                    icon: Icons.person,
                    label: 'Full Name',
                    value: '$_firstName Landlord Owner',
                  ),
                  const Divider(height: 16),
                  const _ProfileDetailTile(
                    icon: Icons.verified_user,
                    label: 'Role',
                    value: 'Landlord',
                  ),
                  const Divider(height: 16),
                  const _ProfileDetailTile(
                    icon: Icons.business,
                    label: 'Business Name',
                    value: 'Apex Property Management',
                  ),
                  const Divider(height: 16),
                  _ProfileDetailTile(
                    icon: Icons.email,
                    label: 'Email Address',
                    value: email,
                  ),
                ],
              ),
            ),

            const SizedBox(height: RampTheme.spacing24),

            // Active Now Session Card Section
            const Text(
              'ACTIVE NOW SESSION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: RampTheme.textSecondary,
              ),
            ),
            const SizedBox(height: RampTheme.spacing8),

            Container(
              padding: const EdgeInsets.all(RampTheme.spacing16),
              decoration: BoxDecoration(
                color: RampTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: RampTheme.standardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: RampTheme.successGreen.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.phone_android_rounded, color: RampTheme.successGreen, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nowSession?.deviceName ?? 'Current Device',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: RampTheme.textPrimary),
                              ),
                              Text(
                                nowSession?.osVersion ?? 'Active OS Platform',
                                style: const TextStyle(fontSize: 12, color: RampTheme.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: RampTheme.successGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: RampTheme.successGreen, size: 8),
                            SizedBox(width: 6),
                            Text(
                              'Active Now',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: RampTheme.successGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('IP Address / Security', style: TextStyle(fontSize: 12, color: RampTheme.textSecondary)),
                      Text(nowSession?.ipAddress ?? 'Secure Connection', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/sessions'),
                      icon: const Icon(Icons.security, size: 18),
                      label: const Text('Manage Sessions & Security'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RampTheme.primaryBlue,
                        side: const BorderSide(color: RampTheme.primaryBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileDetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: RampTheme.primaryBlue, size: 22),
          const SizedBox(width: RampTheme.spacing12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
