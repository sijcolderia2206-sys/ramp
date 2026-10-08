// lib/features/settings/sub_screens/about_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/ramp_theme.dart';

class AboutSettingsScreen extends StatelessWidget {
  const AboutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About RAMP',
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
                  // App Header Card
                  RampCard(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            height: 72,
                            width: 72,
                            errorBuilder: (_, __, ___) => Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: RampColors.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.apartment_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'RAMP',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Rental Administration & Maintenance Platform',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: RampColors.softBlueTint,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Version 1.0.0 (Build 100)',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: RampColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // System Description Section
                  Text(
                    'SYSTEM OVERVIEW & PURPOSE',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 10),

                  RampCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comprehensive Property & Tenant Ecosystem',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'RAMP is an enterprise-grade, cross-platform property management solution engineered to streamline real estate administration, utility submeter tracking, automated financial billing, and maintenance dispatching.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            height: 1.5,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Core Platform Capabilities ("All Abouts")
                  Text(
                    'CORE PLATFORM CAPABILITIES',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 10),

                  RampCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildFeatureTile(
                          icon: Icons.apartment_rounded,
                          iconColor: RampColors.primary,
                          title: 'Portfolio & Unit Management',
                          description:
                              'Organize multi-unit properties, track vacancies, store unit specifications, and manage tenant leases in real time.',
                        ),
                        const Divider(height: 1),
                        _buildFeatureTile(
                          icon: Icons.receipt_long_rounded,
                          iconColor: const Color(0xFFD97706),
                          title: 'Submeter & Itemized Billing Engine',
                          description:
                              'Calculates monthly statements using the formula:\nBase Rent + Water Usage (₱45.00/m³) + Electricity Usage (₱12.50/kWh) + Late Fees.',
                        ),
                        const Divider(height: 1),
                        _buildFeatureTile(
                          icon: Icons.verified_user_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: 'Payment Verification Queue',
                          description:
                              'Landlords review uploaded payment receipts with OCR proof-of-payment parsing, zero-latency verification, and instant receipt generation.',
                        ),
                        const Divider(height: 1),
                        _buildFeatureTile(
                          icon: Icons.build_circle_rounded,
                          iconColor: RampColors.danger,
                          title: 'Maintenance SLA Engine',
                          description:
                              'Tracks repair tickets across Emergency (24h), Medium (3 days), and Low (7 days) severities with photo uploads and technician dispatch.',
                        ),
                        const Divider(height: 1),
                        _buildFeatureTile(
                          icon: Icons.cloud_sync_rounded,
                          iconColor: RampColors.primary,
                          title: 'Offline Persistence Engine',
                          description:
                              'Guarantees uninterrupted operation offline by queuing local actions and automatically syncing with cloud storage upon reconnection.',
                        ),
                        const Divider(height: 1),
                        _buildFeatureTile(
                          icon: Icons.auto_awesome_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: 'Gemini AI Property Assistant',
                          description:
                              'Integrated natural language assistant powered by Google Gemini AI for instant queries on financial trends, tenant history, and unit statuses.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Dual Role Access System
                  Text(
                    'DUAL-ROLE USER SYSTEM',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 10),

                  RampCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: RampColors.softBlueTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.admin_panel_settings_rounded,
                                  color: RampColors.primary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Landlord Portal (Desktop / Tablet)',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Data-dense financial dashboards, AI query bars, verification queues, portfolio management, and live maintenance dispatching.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: RampColors.successTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_pin_rounded,
                                  color: Color(0xFF10B981), size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tenant Portal (Mobile-First)',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Action-oriented screen for rent tracking, utility submeter monitoring, digital payment uploads, and ticketing with photo proof and 1-to-5 star ratings.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Maintenance SLA Guidelines
                  Text(
                    'SERVICE LEVEL AGREEMENTS (SLA)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 10),

                  RampCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSlaItem(
                          'Emergency Severity (24 Hours)',
                          'Water leaks, main power outages, structure hazards, or security locks.',
                          RampColors.danger,
                        ),
                        const SizedBox(height: 12),
                        _buildSlaItem(
                          'Medium Severity (3 Days)',
                          'Appliance defects, minor plumbing leaks, or submeter calibration.',
                          RampColors.warning,
                        ),
                        const SizedBox(height: 12),
                        _buildSlaItem(
                          'Low Severity (7 Days)',
                          'Cosmetic touch-ups, light fixture replacements, or routine checks.',
                          RampColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer Copyright Info
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '© ${DateTime.now().year} RAMP Platform. All rights reserved.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Empowering landlords & tenants through intelligent software.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: RampColors.mutedText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlaItem(String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: RampColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
