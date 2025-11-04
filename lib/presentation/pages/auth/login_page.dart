import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/locale/localization_extension.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../home/home_shell_page.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.appController,
    required this.authController,
  });

  static const routeName = '/auth/login';

  final AppController appController;
  final AuthController authController;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final ValueNotifier<bool> _obscurePassword;
  late final ValueNotifier<bool> _autoValidate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _obscurePassword = ValueNotifier<bool>(true);
    _autoValidate = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    _autoValidate.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final text = value ?? '';
    if (text.isEmpty) {
      return context.tr('auth_error_required');
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(text)) {
      return context.tr('auth_error_email');
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) {
      return context.tr('auth_error_required');
    }
    if (text.length < 6) {
      return context.tr('auth_error_password_short');
    }
    return null;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) {
      return;
    }
    if (!form.validate()) {
      _autoValidate.value = true;
      return;
    }
    setState(() {
      _submitting = true;
    });
    await widget.authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    await widget.appController.setSeenOnboarding(true);
    if (!mounted) {
      return;
    }
    setState(() {
      _submitting = false;
    });
    Navigator.of(context).pushNamedAndRemoveUntil(
      HomeShellPage.routeName,
      (_) => false,
    );
  }

  Future<void> _guestMode() async {
    setState(() {
      _submitting = true;
    });
    await widget.authController.continueAsGuest();
    await widget.appController.setSeenOnboarding(true);
    if (!mounted) {
      return;
    }
    setState(() {
      _submitting = false;
    });
    Navigator.of(context).pushNamedAndRemoveUntil(
      HomeShellPage.routeName,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.tr('auth_login_title'),
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ).animate().fadeIn(duration: const Duration(milliseconds: 400)).slideY(
                        begin: 0.3,
                        end: 0,
                        duration: const Duration(milliseconds: 400),
                      ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('auth_login_subtitle'),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ValueListenableBuilder<bool>(
                    valueListenable: _autoValidate,
                    builder: (context, autoValidate, _) {
                      return Form(
                        key: _formKey,
                        autovalidateMode: autoValidate
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: context.tr('auth_email_label'),
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),
                            ValueListenableBuilder<bool>(
                              valueListenable: _obscurePassword,
                              builder: (context, obscure, _) {
                                return TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: context.tr('auth_password_label'),
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: () => _obscurePassword.value = !obscure,
                                      icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                                      tooltip: context.tr(
                                        obscure ? 'auth_password_show' : 'auth_password_hide',
                                      ),
                                    ),
                                  ),
                                  obscureText: obscure,
                                  textInputAction: TextInputAction.done,
                                  validator: _validatePassword,
                                  onFieldSubmitted: (_) => _submit(),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(ForgotPasswordPage.routeName),
                      child: Text(context.tr('auth_forgot_password')),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.tr('auth_login_cta')),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _submitting ? null : _guestMode,
                    child: Text(context.tr('auth_continue_guest')),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.tr('auth_no_account')),
                      TextButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).pushReplacementNamed(RegisterPage.routeName),
                        child: Text(context.tr('auth_register_link')),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: const Duration(milliseconds: 500)).moveY(
                    begin: 24,
                    end: 0,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
