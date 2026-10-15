// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';
import '../../providers/login_provider.dart';
import '../../core/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(loginNotifierProvider);
    _emailController = TextEditingController(text: initialState.email);
    _passwordController = TextEditingController(text: initialState.password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showNeumorphicSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E5EC),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.white,
                offset: Offset(-4, -4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Color(0xFFA3B1C6),
                offset: Offset(4, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? RampTheme.errorRed : RampTheme.successGreen,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: isError ? RampTheme.errorRed : RampTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final emailErr = FormValidators.email(email);
    if (emailErr != null) {
      _showNeumorphicSnackBar(emailErr, isError: true);
      return;
    }

    final pwErr = RampValidators.validatePassword(password);
    if (pwErr != null) {
      _showNeumorphicSnackBar(pwErr, isError: true);
      return;
    }

    final notifier = ref.read(loginNotifierProvider.notifier);
    notifier.setEmail(email);
    notifier.setPassword(password);

    try {
      final targetRoute = await notifier.signInWithPassword();

      if (mounted) {
        context.go(targetRoute);
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
        _showNeumorphicSnackBar(errorMsg, isError: true);
      }
    }
  }

  void _openResetPasswordDialog() {
    final resetController = TextEditingController(text: _emailController.text);
    final otpController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isSubmitting = false;
    bool codeSent = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E5EC),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(-4, -4),
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: Color(0xFFA3B1C6),
                      offset: Offset(4, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0E5EC),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white,
                                offset: Offset(-2, -2),
                                blurRadius: 4,
                              ),
                              BoxShadow(
                                color: Color(0xFFA3B1C6),
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            color: RampTheme.primaryBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            codeSent ? 'Enter Reset Code' : 'Reset Password',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: RampTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      codeSent
                          ? 'Check your Gmail for the 8-digit reset code and enter your new password below:'
                          : 'Enter your registered email address below to receive an 8-digit reset code.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: RampTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!codeSent) ...[
                      _NeumorphicInputField(
                        controller: resetController,
                        label: 'Email Address',
                        hintText: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        enabled: !isSubmitting,
                      ),
                    ] else ...[
                      _NeumorphicInputField(
                        controller: otpController,
                        label: '8-Digit Reset Code',
                        hintText: 'Enter 8-digit OTP code',
                        prefixIcon: Icons.mark_email_read_outlined,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 14),
                      _NeumorphicInputField(
                        controller: newPasswordController,
                        label: 'New Password',
                        hintText: 'Enter new password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        enabled: !isSubmitting,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: TextButton(
                            onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: RampTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: GestureDetector(
                            onTap: isSubmitting
                                ? null
                                : () async {
                                    final email = resetController.text.trim();
                                    final emailErr = FormValidators.email(email);
                                    if (emailErr != null) {
                                      _showNeumorphicSnackBar(emailErr, isError: true);
                                      return;
                                    }

                                    if (!codeSent) {
                                      // Stage 1: Send Password Reset Code via Supabase Auth
                                      setDialogState(() => isSubmitting = true);
                                      try {
                                        await ref.read(loginNotifierProvider.notifier).sendPasswordReset(email);
                                        if (dialogContext.mounted) {
                                          setDialogState(() {
                                            isSubmitting = false;
                                            codeSent = true;
                                          });
                                          _showNeumorphicSnackBar('Reset code sent to $email. Please check your inbox.', isError: false);
                                        }
                                      } catch (e) {
                                        if (dialogContext.mounted) {
                                          setDialogState(() => isSubmitting = false);
                                          _showNeumorphicSnackBar(
                                            e.toString().replaceAll('Exception: ', ''),
                                            isError: true,
                                          );
                                        }
                                      }
                                    } else {
                                      // Stage 2: Verify Recovery OTP & Update Password
                                      final otpCode = otpController.text.trim();
                                      final newPassword = newPasswordController.text.trim();

                                      if (otpCode.length < 8) {
                                        _showNeumorphicSnackBar('Please enter the full 8-digit OTP code.', isError: true);
                                        return;
                                      }
                                      if (newPassword.length < 6) {
                                        _showNeumorphicSnackBar('Password must be at least 6 characters long.', isError: true);
                                        return;
                                      }

                                      setDialogState(() => isSubmitting = true);
                                      try {
                                        final success = await ref.read(loginNotifierProvider.notifier).confirmPasswordReset(
                                          email: email,
                                          otpCode: otpCode,
                                          newPassword: newPassword,
                                        );

                                        if (dialogContext.mounted) {
                                          if (success) {
                                            Navigator.of(dialogContext).pop();
                                            _showNeumorphicSnackBar('Password updated successfully! You can now sign in.', isError: false);
                                          } else {
                                            setDialogState(() => isSubmitting = false);
                                            _showNeumorphicSnackBar('Invalid or expired reset code. Please check your inbox.', isError: true);
                                          }
                                        }
                                      } catch (e) {
                                        if (dialogContext.mounted) {
                                          setDialogState(() => isSubmitting = false);
                                          _showNeumorphicSnackBar(
                                            e.toString().replaceAll('Exception: ', ''),
                                            isError: true,
                                          );
                                        }
                                      }
                                    }
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: RampTheme.primaryBlue,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(-2, -2),
                                    blurRadius: 4,
                                  ),
                                  BoxShadow(
                                    color: Color(0xFFA3B1C6),
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        codeSent ? 'Update Password' : 'Send Reset Code',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RampTheme.spacing24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(RampTheme.spacing32),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E5EC),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-4, -4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Color(0xFFA3B1C6),
                    offset: Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Header
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0E5EC),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            offset: Offset(-4, -4),
                            blurRadius: 8,
                          ),
                          BoxShadow(
                            color: Color(0xFFA3B1C6),
                            offset: Offset(4, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/property.svg',
                        width: 40,
                        height: 40,
                        colorFilter: const ColorFilter.mode(
                          RampTheme.primaryBlue,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: RampTheme.spacing20),
                  const Text(
                    'RAMP Portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: RampTheme.primaryBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sign in to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: RampTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: RampTheme.spacing32),

                  // Email Address Input
                  _NeumorphicInputField(
                    controller: _emailController,
                    label: 'Email Address',
                    hintText: 'name@example.com',
                    prefixIcon: Icons.email_outlined,
                    enabled: !loginState.isLoading,
                    onChanged: (val) => ref.read(loginNotifierProvider.notifier).setEmail(val),
                  ),

                  const SizedBox(height: RampTheme.spacing20),

                  // Password Input
                  _NeumorphicInputField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !loginState.isPasswordVisible,
                    enabled: !loginState.isLoading,
                    onChanged: (val) => ref.read(loginNotifierProvider.notifier).setPassword(val),
                    suffixIcon: IconButton(
                      icon: Icon(
                        loginState.isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: RampTheme.textSecondary,
                        size: 20,
                      ),
                      onPressed: loginState.isLoading
                          ? null
                          : () => ref.read(loginNotifierProvider.notifier).togglePasswordVisibility(),
                    ),
                  ),

                  const SizedBox(height: RampTheme.spacing32),

                  // Convex Sign In Button
                  _NeumorphicSignInButton(
                    isLoading: loginState.isLoading,
                    onPressed: loginState.isLoading ? null : _handleSignIn,
                  ),

                  const SizedBox(height: RampTheme.spacing24),

                  // Forgot Password Link
                  Center(
                    child: TextButton(
                      onPressed: loginState.isLoading ? null : _openResetPasswordDialog,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: RampTheme.primaryBlue,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: RampTheme.primaryBlue,
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

/// Private Inset Neumorphic Input Field without standard Material underlines or borders
class _NeumorphicInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const _NeumorphicInputField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: RampTheme.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E5EC),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFA3B1C6),
                offset: Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(-2, -2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(prefixIcon, color: RampTheme.primaryBlue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  enabled: enabled,
                  style: const TextStyle(
                    fontSize: 14,
                    color: RampTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      color: RampTheme.textSecondary,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: onChanged,
                ),
              ),
              if (suffixIcon != null) suffixIcon!,
            ],
          ),
        ),
      ],
    );
  }
}

/// Large Convex Neumorphic Action Button for Sign In
class _NeumorphicSignInButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _NeumorphicSignInButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<_NeumorphicSignInButton> createState() => _NeumorphicSignInButtonState();
}

class _NeumorphicSignInButtonState extends State<_NeumorphicSignInButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDisabled ? const Color(0xFFD0D7E1) : RampTheme.primaryBlue,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed || isDisabled
              ? const [
                  BoxShadow(
                    color: Color(0xFFA3B1C6),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-4, -4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Color(0xFFA3B1C6),
                    offset: Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: widget.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Sign In',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
