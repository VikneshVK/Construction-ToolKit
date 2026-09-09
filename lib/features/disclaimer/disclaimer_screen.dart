import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radii.dart';
import '../../core/components/icons/buildcalc_app_logo.dart';
import '../../core/components/legal/legal_disclaimer_content.dart';
import '../../core/persistence/local_storage.dart';
import '../../app_shell.dart';

/// First-launch full screen Legal & Professional Disclaimer screen.
/// Shown only once upon the initial app launch.
class DisclaimerScreen extends StatefulWidget {
  final VoidCallback? onAccepted;

  const DisclaimerScreen({
    super.key,
    this.onAccepted,
  });

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  bool _isAccepting = false;

  Future<void> _handleAccept() async {
    if (_isAccepting) return;
    setState(() => _isAccepting = true);

    await LocalStorageService.instance.setAcceptedDisclaimer(true);

    if (!mounted) return;

    if (widget.onAccepted != null) {
      widget.onAccepted!();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AppShell(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bgCanvas,
        appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.bgSurface,
        title: Row(
          children: [
            const BuildCalcAppLogo(size: 24, withBackground: false),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Build',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 0.3,
                    ),
                  ),
                  TextSpan(
                    text: 'Calc',
                    style: TextStyle(
                      color: AppColors.brandGold,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: AppColors.borderSubtle, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.gavel_rounded, color: AppColors.brandGold, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Legal & Professional Disclaimer',
                          style: AppTypography.cardTitle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Please review and acknowledge before proceeding to jobsite tools.',
                          style: AppTypography.helperText.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.borderSubtle, height: 1.0),
              const SizedBox(height: AppSpacing.md),

              // Scrollable Legal Clauses
              const Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: LegalDisclaimerContent(),
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.borderSubtle, height: 1.0),
              const SizedBox(height: AppSpacing.md),

              // Bottom Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandGold,
                    foregroundColor: AppColors.textInverse,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.buttonRadius),
                  ),
                  onPressed: _isAccepting ? null : _handleAccept,
                  child: _isAccepting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.textInverse),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Accept & Continue',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    ),
  );
}
}
