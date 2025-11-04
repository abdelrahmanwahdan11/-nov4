import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/locale/localization_extension.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../home/home_shell_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.appController,
    required this.authController,
  });

  static const routeName = '/auth/register';

  final AppController appController;
  final AuthController authController;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;
  late final ValueNotifier<bool> _obscurePassword;
  late final ValueNotifier<bool> _obscureConfirm;
  late final ValueNotifier<bool> _autoValidate;
  late final ValueNotifier<double> _strengthNotifier;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    _obscurePassword = ValueNotifier<bool>(true);
    _obscureConfirm = ValueNotifier<bool>(true);
    _autoValidate = ValueNotifier<bool>(false);
    _strengthNotifier = ValueNotifier<double>(0);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _obscurePassword.dispose();
    _obscureConfirm.dispose();
    _autoValidate.dispose();
    _strengthNotifier.dispose();
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

  String? _validateConfirm(String? value) {
    final text = value ?? '';
    if (text.isEmpty) {
      return context.tr('auth_error_required');
    }
    if (text != _passwordController.text) {
      return context.tr('auth_error_password_match');
    }
    return null;
  }

  void _updateStrength(String password) {
    var score = 0.0;
    if (password.length >= 6) {
      score += 0.3;
    }
    if (password.length >= 10) {
      score += 0.2;
    }
    if (RegExp(r'[A-Z]').hasMatch(password)) {
      score += 0.2;
    }
    if (RegExp(r'[0-9]').hasMatch(password)) {
      score += 0.2;
    }
    if (RegExp(r'[!@#\$%^&*(),.?\-_=+{}\[\]|<>]').hasMatch(password)) {
      score += 0.1;
    }
    _strengthNotifier.value = score.clamp(0.0, 1.0);
  }

  Color _strengthColor(double strength, ThemeData theme) {
    if (strength >= 0.7) {
      return theme.colorScheme.primary;
    }
    if (strength >= 0.4) {
      return theme.colorScheme.tertiary;
    }
    return theme.colorScheme.error;
  }

  String _strengthLabel(double strength) {
    if (strength >= 0.7) {
      return context.tr('auth_strength_strong');
    }
    if (strength >= 0.4) {
      return context.tr('auth_strength_medium');
    }
    return context.tr('auth_strength_weak');
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
    await widget.authController.register(
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
                    context.tr('auth_register_title'),
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ).animate().fadeIn(duration: const Duration(milliseconds: 400)).slideY(
                        begin: 0.3,
                        end: 0,
                        duration: const Duration(milliseconds: 400),
                      ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('auth_register_subtitle'),
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
                                  textInputAction: TextInputAction.next,
                                  validator: _validatePassword,
                                  onChanged: (value) {
                                    _updateStrength(value);
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            ValueListenableBuilder<double>(
                              valueListenable: _strengthNotifier,
                              builder: (context, strength, _) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LinearProgressIndicator(
                                      value: strength,
                                      minHeight: 6,
                                      color: _strengthColor(strength, theme),
                                      backgroundColor: theme.colorScheme.surfaceVariant,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.tr('auth_password_strength') + ': ' + _strengthLabel(strength),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ).animate().fadeIn(duration: const Duration(milliseconds: 300));
                              },
                            ),
                            const SizedBox(height: 16),
                            ValueListenableBuilder<bool>(
                              valueListenable: _obscureConfirm,
                              builder: (context, obscure, _) {
                                return TextFormField(
                                  controller: _confirmController,
                                  decoration: InputDecoration(
                                    labelText: context.tr('auth_confirm_password_label'),
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: () => _obscureConfirm.value = !obscure,
                                      icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                                      tooltip: context.tr(
                                        obscure ? 'auth_password_show' : 'auth_password_hide',
                                      ),
                                    ),
                                  ),
                                  obscureText: obscure,
                                  textInputAction: TextInputAction.done,
                                  validator: _validateConfirm,
                                  onFieldSubmitted: (_) => _submit(),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.tr('auth_register_cta')),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.tr('auth_have_account')),
                      TextButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).pushReplacementNamed(LoginPage.routeName),
                        child: Text(context.tr('auth_login_link')),
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
