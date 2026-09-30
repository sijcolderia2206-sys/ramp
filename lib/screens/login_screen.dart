import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../core/widgets/core_widgets.dart';
import '../core/theme/ramp_theme.dart';
import '../core/validation/app_validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleForgotPassword() async {
    final formKey = GlobalKey<FormState>();
    final controller =
        TextEditingController(text: _emailController.text.trim());
    try {
      final email = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Reset password'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              textInputAction: TextInputAction.done,
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Enter your email address.';
                if (!_isValidEmail(email)) {
                  return 'Enter a valid email address.';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email address',
                hintText: 'you@example.com',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dialogContext, controller.text);
                }
              },
              child: const Text('SEND RESET EMAIL'),
            ),
          ],
        ),
      );
      controller.dispose();
      if (email == null || !mounted) return;
      final normalizedEmail = email.trim().toLowerCase();
      if (!_isValidEmail(normalizedEmail)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter a valid email address.'),
            backgroundColor: RampColors.danger,
          ),
        );
        return;
      }

      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: normalizedEmail);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
          backgroundColor: RampColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'invalid-email' => 'Enter a valid email address.',
        'too-many-requests' => 'Too many requests. Try again later.',
        'network-request-failed' =>
          'Check your internet connection and try again.',
        'operation-not-allowed' =>
          'Password reset is not enabled for this account.',
        _ => 'Unable to send the reset email. Please try again.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: RampColors.danger),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again later.'),
          backgroundColor: RampColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _isValidEmail(String value) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);

  Future<void> _handleLogin(
      {String? overrideUsername, String? overridePassword}) async {
    final email =
        (overrideUsername ?? _emailController.text).trim().toLowerCase();
    final password = (overridePassword ?? _passwordController.text).trim();

    if (overrideUsername != null) {
      _emailController.text = overrideUsername;
    }
    if (overridePassword != null) {
      _passwordController.text = overridePassword;
    }

    if (!(_loginFormKey.currentState?.validate() ?? false)) return;

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email address.'),
          backgroundColor: RampColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
          backgroundColor: RampColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      ref.read(authProvider.notifier).state =
          FirebaseAuth.instance.currentUser!.uid;
      var dataWarning = false;
      try {
        await hydratePersistentAppData(ref);
      } on FirebaseException {
        dataWarning = true;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dataWarning
                ? 'Logged in. Firestore is unavailable, so local data is being used.'
                : "Logged in as Landlord (Emin and Mila's Admin)",
          ),
          backgroundColor: RampColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'invalid-credential' ||
        'user-not-found' ||
        'wrong-password' =>
          'The email or password is incorrect.',
        'invalid-email' => 'Enter a valid email address.',
        'user-disabled' => 'This account has been disabled.',
        'too-many-requests' => 'Too many attempts. Try again later.',
        _ => 'Unable to sign in. Please try again.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: RampColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 450 ? 420.0 : screenWidth;
    final responsivePadding = screenWidth > 400 ? 28.0 : 20.0;

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : RampColors.background,
      body: SafeArea(
        child: Center(
          child: Container(
            width: contentWidth,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                  horizontal: responsivePadding, vertical: 24.0),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.95 + (0.05 * value),
                      child: child,
                    ),
                  );
                },
                child: Form(
                  key: _loginFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App Icon Badge
                      Center(
                        child: ClayContainer(
                          width: 86,
                          height: 86,
                          color: RampColors.softBlueTint,
                          borderRadius: 43,
                          depth: 8.0,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.apartment_rounded,
                            size: 46,
                            color: RampColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Welcome to RAMP',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : RampColors.slate,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Rental Administration Management Platform',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : RampColors.mutedText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 36),

                      // Email Input
                      RampTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'you@example.com',
                        prefixIcon: const Icon(Icons.person_outline_rounded,
                            color: RampColors.primary),
                        validator: AppValidators.email,
                      ),
                      const SizedBox(height: 18),

                      // Password Input
                      RampTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Enter password',
                        obscureText: !_isPasswordVisible,
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            color: RampColors.primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: RampColors.mutedText,
                          ),
                          onPressed: () {
                            setState(
                                () => _isPasswordVisible = !_isPasswordVisible);
                          },
                        ),
                        validator: (value) {
                          final password = value ?? '';
                          if (password.isEmpty) return 'Enter your password.';
                          if (password.length < 6) {
                            return 'Password must contain at least 6 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Single Sign In CTA
                      BouncePillButton(
                        text: 'SIGN IN TO RAMP',
                        icon: Icons.login_rounded,
                        buttonState: _isLoading
                            ? BounceButtonState.loading
                            : BounceButtonState.idle,
                        onPressed: () => _handleLogin(),
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: _isLoading ? null : _handleForgotPassword,
                        child: const Text('Forgot password?'),
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
