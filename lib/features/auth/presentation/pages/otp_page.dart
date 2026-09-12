import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/app/router/route_names.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/core/widgets/auth_scaffold.dart';
import 'package:patch_bro/features/auth/presentation/models/otp_verification_args.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';
import 'package:patch_bro/features/auth/presentation/widgets/otp_input.dart';
import 'package:patch_bro/features/auth/presentation/widgets/otp_resend_section.dart';
import 'package:patch_bro/features/profile/presentation/providers/profile_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({
    super.key,
    required this.request,
  });

  final OtpVerificationArgs request;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _otpController = TextEditingController();

  bool _isResending = false;

  String get _message {
    switch (widget.request.type) {
      case OtpVerificationType.passwordReset:
        return 'We have sent a password reset code\nto your mobile number.';

      case OtpVerificationType.phoneChange:
        return 'We have sent a verification code\nto your new mobile number.';

      case OtpVerificationType.signup:
        return 'We have sent a verification code\nto your mobile number.';
    }
  }

  // ---------------------------------------------------------------------------
  // VERIFY OTP
  // ---------------------------------------------------------------------------

  Future<void> _verifyOtp() async {
    if (ref.read(authControllerProvider).isLoading ||
        _isResending) {
      return;
    }

    final token = _otpController.text.trim();

    if (token.length != 6) {
      AppSnackbar.error(
        context,
        'Please enter the 6-digit verification code.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final controller = ref.read(
      authControllerProvider.notifier,
    );

    try {
      switch (widget.request.type) {
        // ==========================================================
        // PASSWORD RESET
        // ==========================================================

        case OtpVerificationType.passwordReset:
          await controller.verifyPasswordResetOtp(
            phone: widget.request.phone,
            token: token,
          );

          if (!mounted) {
            return;
          }

          context.go(RouteNames.resetPassword);
          return;

        // ==========================================================
        // PHONE CHANGE
        // ==========================================================

        case OtpVerificationType.phoneChange:
          await controller.verifyPhoneChangeOtp(
            phone: widget.request.phone,
            token: token,
          );

          if (!mounted) {
            return;
          }

          final profileData =
              widget.request.profileData;

          if (profileData == null) {
            AppSnackbar.error(
              context,
              'Profile information is missing. Please try again.',
            );
            return;
          }

          await ref
              .read(profileRepositoryProvider)
              .saveProfile(
                name: profileData.name,
                phone: profileData.phone,
                address1: profileData.address1,
                address2: profileData.address2,
                pinCode: profileData.pinCode,
                state: profileData.state,
                latitude:
                    profileData.location.latitude,
                longitude:
                    profileData.location.longitude,
                locationAddress:
                    profileData.location.address,
                isWorker:
                    profileData.isWorker,
              );

          if (!mounted) {
            return;
          }

          context.go(
            profileData.isWorker
                ? '/worker/home'
                : '/employer/home',
          );

          return;

        // ==========================================================
        // SIGNUP
        // ==========================================================

        case OtpVerificationType.signup:
          await controller.verifyOtp(
            phone: widget.request.phone,
            token: token,
          );

          if (!mounted) {
            return;
          }

          context.go('/profile-details');
          return;
      }
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(
        context,
        error.message,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(
        context,
        'Unable to verify the OTP. Please try again.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // RESEND OTP
  // ---------------------------------------------------------------------------

  Future<void> _resendOtp() async {
    if (_isResending ||
        ref.read(authControllerProvider).isLoading) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    final controller = ref.read(
      authControllerProvider.notifier,
    );

    try {
      if (widget.request.type ==
          OtpVerificationType.passwordReset) {
        await controller.sendPasswordResetOtp(
          phone: widget.request.phone,
        );
      } else {
        await controller.resendOtp(
          phone: widget.request.phone,
        );
      }

      if (!mounted) {
        return;
      }

      _otpController.clear();

      AppSnackbar.success(
        context,
        'A new OTP has been sent.',
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(
        context,
        error.message,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(
        context,
        'Unable to resend OTP. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final authIsLoading = ref.watch(
      authControllerProvider.select(
        (state) => state.isLoading,
      ),
    );

    final isLoading =
        authIsLoading || _isResending;

    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return AuthScaffold(
      appBar: AppBar(
        title: const Text('Verification'),
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    // --------------------------------------------------------
                    // OTP IMAGE
                    // --------------------------------------------------------

                    SizedBox(
                      height: _imageHeight(
                        size.height,
                        size.width,
                      ),
                      child: Image.asset(
                        'assets/images/otp_image.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // --------------------------------------------------------
                    // TITLE
                    // --------------------------------------------------------

                    Text(
                      'Verification Code',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // --------------------------------------------------------
                    // MESSAGE
                    // --------------------------------------------------------

                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(
                        height: 1.45,
                        color: theme
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(
                              alpha: 0.7,
                            ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --------------------------------------------------------
                    // OTP INPUT
                    // --------------------------------------------------------

                    OtpInput(
                      controller: _otpController,
                      length: 6,
                      enabled: !isLoading,
                      onCompleted: (_) {
                        if (!isLoading) {
                          _verifyOtp();
                        }
                      },
                    ),

                    const SizedBox(height: 30),

                    // --------------------------------------------------------
                    // VERIFY BUTTON
                    // --------------------------------------------------------

                    AppPrimaryButton(
                      label: 'Verify',
                      isLoading: isLoading,
                      onPressed:
                          isLoading ? null : _verifyOtp,
                    ),

                    const SizedBox(height: 24),

                    // --------------------------------------------------------
                    // RESEND
                    // --------------------------------------------------------

                    OtpResendSection(
                      onResend: _resendOtp,
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RESPONSIVE IMAGE HEIGHT
  // ---------------------------------------------------------------------------

  double _imageHeight(
    double screenHeight,
    double screenWidth,
  ) {
    final calculated = screenWidth * 0.60;

    if (screenHeight < 700) {
      return calculated.clamp(
        145.0,
        185.0,
      );
    }

    if (screenHeight < 850) {
      return calculated.clamp(
        165.0,
        215.0,
      );
    }

    return calculated.clamp(
      180.0,
      240.0,
    );
  }
}