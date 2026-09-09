import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

/// Reusable Legal & Professional Engineering Disclaimer content component.
/// Adheres strictly to DESIGN.md industrial aesthetics.
/// Includes inline expandable cards for the Full Privacy Policy and Terms of Use.
class LegalDisclaimerContent extends StatefulWidget {
  final bool showAcceptedBadge;

  const LegalDisclaimerContent({
    super.key,
    this.showAcceptedBadge = false,
  });

  @override
  State<LegalDisclaimerContent> createState() => _LegalDisclaimerContentState();
}

class _LegalDisclaimerContentState extends State<LegalDisclaimerContent> {
  bool _showPrivacyPolicy = false;
  bool _showTermsOfUse = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showAcceptedBadge) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.statusSuccessBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.statusSuccess.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle_outline, color: AppColors.statusSuccess, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Terms & Disclaimer accepted on this device',
                    style: TextStyle(
                      color: AppColors.statusSuccess,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Overview intro card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.brandGold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.info_outline, color: AppColors.brandGold, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'BuildCalc is a specialized jobsite reference and estimation instrument. Please review these essential terms before applying calculations to physical construction.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Clause 1: Reference & Estimation Only
        _buildClauseCard(
          icon: Icons.calculate_outlined,
          iconColor: AppColors.brandGold,
          title: '1. For Reference & Estimation Only',
          summary: 'All outputs are mathematical approximations.',
          body:
              'All calculations, dimensions, conversion values, rafter profiles, and material estimates (concrete volume, lumber board feet, block counts) are mathematical approximations based on user inputs. Physical jobsite conditions, settling, lumber mill variances, and formwork deflection will cause real-world requirements to differ from raw geometric estimates.',
        ),
        const SizedBox(height: AppSpacing.sm),

        // Clause 2: Not an Engineering / Architectural Stamp
        _buildClauseCard(
          icon: Icons.architecture_outlined,
          iconColor: const Color(0xFF38BDF8), // Sky blueprint blue
          title: '2. Not a Substitute for PE / Architectural Stamps',
          summary: 'No certified structural engineering provided.',
          body:
              'BuildCalc does not provide licensed architectural, structural engineering, or municipal inspection services. Generated diagrams and figures do not constitute sealed engineering drawings or structural load calculations. Always consult a licensed Professional Engineer (PE) or registered architect for structural modifications, load-bearing walls, and foundation designs.',
        ),
        const SizedBox(height: AppSpacing.sm),

        // Clause 3: Building Codes & Local Authority (AHJ)
        _buildClauseCard(
          icon: Icons.gavel_outlined,
          iconColor: const Color(0xFFA855F7), // Precision violet
          title: '3. Building Codes & Authority Having Jurisdiction (AHJ)',
          summary: 'Model code references (IRC) are general guidelines.',
          body:
              'Where the app references the International Residential Code (IRC §R311.7 for stairs, rafters, etc.), these represent published model codes. Municipalities and states frequently adopt local amendments or alternative code cycles. The local Authority Having Jurisdiction (AHJ) or building inspector has sole and final authority.',
        ),
        const SizedBox(height: AppSpacing.sm),

        // Clause 4: Mandatory Jobsite Field Verification
        _buildClauseCard(
          icon: Icons.straighten_outlined,
          iconColor: const Color(0xFF10B981), // Machinist emerald
          title: '4. Mandatory Field Verification ("Measure Twice")',
          summary: 'Verify all dimensions before cutting or pouring.',
          body:
              'The user is solely responsible for independently verifying all physical measurements, plumb lines, levels, and square angles on the jobsite prior to ordering materials, cutting framing lumber, or scheduling ready-mix concrete pours. Neither VK Solutions nor contributors are liable for material waste, miscuts, or project delays.',
        ),
        const SizedBox(height: AppSpacing.sm),

        // Clause 5: Limitation of Liability & As-Is Warranty
        _buildClauseCard(
          icon: Icons.shield_outlined,
          iconColor: AppColors.statusWarning,
          title: '5. "As-Is" Warranty & Limitation of Liability',
          summary: 'No warranties of merchantability or specific fitness.',
          body:
              'BuildCalc is provided on an "AS IS" and "AS AVAILABLE" basis without warranties of any kind. Under no circumstances shall VK Solutions or its developers be liable for any direct, indirect, incidental, structural, or consequential damages, loss of materials, structural failure, or personal injury resulting from use of the app.',
        ),
        const SizedBox(height: AppSpacing.sm),

        // Clause 6: 100% Offline Privacy
        _buildClauseCard(
          icon: Icons.cloud_off_outlined,
          iconColor: AppColors.textSecondary,
          title: '6. 100% Offline Privacy Guarantee',
          summary: 'Zero data collected or transmitted.',
          body:
              'BuildCalc operates completely offline. All notes, profiles, and calculation histories are stored exclusively within your personal device\'s local storage. No user data, analytics, or calculations are ever transmitted over the network.',
        ),
        const SizedBox(height: AppSpacing.md),

        // Expandable 1: Full Privacy Policy
        _buildExpandableLegalCard(
          icon: Icons.privacy_tip_outlined,
          title: 'Full Privacy Policy',
          subtitle: 'Zero data collection & offline device storage details',
          isExpanded: _showPrivacyPolicy,
          onToggle: () => setState(() => _showPrivacyPolicy = !_showPrivacyPolicy),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Zero Personal Data Collected: We do not collect names, email addresses, phone numbers, location data, or device identifiers.',
                style: AppTypography.helperText,
              ),
              SizedBox(height: 6),
              Text(
                '• Local Device Storage: All calculation records, project notes, stair profiles, and bookmarked logs remain strictly in your device\'s local storage (SharedPreferences).',
                style: AppTypography.helperText,
              ),
              SizedBox(height: 6),
              Text(
                '• No Third-Party Trackers: Contains zero ad networks, zero analytics SDKs (no Firebase/Google Analytics), and zero crash loggers.',
                style: AppTypography.helperText,
              ),
              SizedBox(height: 6),
              Text(
                '• Children\'s Privacy: Designed for trade professionals and contractors aged 18 and older.',
                style: AppTypography.helperText,
              ),
              SizedBox(height: 6),
              Text(
                '• Contact Email: vksolution.tech@gmail.com',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.brandGold),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Expandable 2: Terms of Use & License
        _buildExpandableLegalCard(
          icon: Icons.description_outlined,
          title: 'Terms of Use & License',
          subtitle: 'Permitted commercial trade use & IP rights',
          isExpanded: _showTermsOfUse,
          onToggle: () => setState(() => _showTermsOfUse = !_showTermsOfUse),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Commercial Trade Use: Contractors and estimators are fully authorized to use calculations, material estimates, and 2D diagrams for commercial bids, jobsite framing, and building quotes.',
                style: AppTypography.helperText,
              ),
              SizedBox(height: 6),
              Text(
                '• Intellectual Property: Algorithms, geometric solvers, UI layouts, and branding are the property of VK Solutions.',
                style: AppTypography.helperText,
              ),
              SizedBox(height: 6),
              Text(
                '• Governing Terms: Use of the app implies full acceptance of our limitation of liability and "as-is" software warranty.',
                style: AppTypography.helperText,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // App Version, Developer & Copyright Footer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              const Text(
                'BuildCalc v1.0.0 · Offline Jobsite Instrument',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '© 2026 VK Solutions · All rights reserved',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Support: vksolution.tech@gmail.com',
                style: AppTypography.helperText.copyWith(
                  fontSize: 11,
                  color: AppColors.brandGold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildClauseCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String summary,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.brandGold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: AppTypography.helperText.copyWith(
              color: AppColors.textPrimary,
              height: 1.35,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableLegalCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isExpanded ? AppColors.brandGold : AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.brandGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: AppTypography.helperText.copyWith(fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.brandGold,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(color: AppColors.borderSubtle, height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: content,
            ),
          ],
        ],
      ),
    );
  }
}
