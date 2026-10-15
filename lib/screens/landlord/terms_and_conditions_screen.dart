// lib/screens/landlord/terms_and_conditions_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/neumorphic_widgets.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0E5EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Terms & Privacy Policy',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NeumorphicContainer(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.gavel_rounded, size: 36, color: Color(0xFF2196F3)),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RAMP Service Agreement',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Rental Administration Management Platform',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF708090),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('1. Acceptance of Terms'),
              _buildSectionText(
                'By registering or using the RAMP platform (Landlord or Tenant portal), you agree to comply with and be bound by these Terms and Conditions. If you do not agree to these terms, you may not access or use our services.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('2. User Responsibilities & Data Accuracy'),
              _buildSectionText(
                'Landlords are responsible for providing accurate rental unit details, lease information, and submeter readings. Tenants are responsible for submitting true payment proofs and reporting genuine maintenance issues in a timely manner.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('3. Data Safety & Privacy'),
              _buildSectionText(
                'RAMP stores personal information including names, contact numbers, email addresses, and payment records securely on Supabase cloud servers. Information is encrypted in transit and at rest, and accessed strictly based on role permissions (Landlord vs. Tenant).',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('4. Device Access & Permissions'),
              _buildSectionText(
                'RAMP requests access to device features such as Camera and Storage solely for user-initiated actions, including taking maintenance defect photos, scanning payment QR codes, or attaching lease documents. Device access can be revoked anytime in your device settings.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('5. Offline Data Synchronization'),
              _buildSectionText(
                'The RAMP app caches data locally on your device to ensure uninterrupted offline access. Any actions created while offline are queued locally and automatically pushed to the cloud once an active internet connection is re-established.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('6. Account Security & Contact'),
              _buildSectionText(
                'Users are responsible for maintaining the confidentiality of their credentials. For support or privacy queries, contact RAMP administration at support@ramp-property.com.',
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'I Understand & Agree',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF506070),
          height: 1.5,
        ),
      ),
    );
  }
}
