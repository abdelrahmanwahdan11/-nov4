import 'package:flutter/material.dart';
import 'package:greenly/core/state/simple_provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/session_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await context.read<AuthController>().register(_emailController.text, _passwordController.text);
      await context.read<SessionController>().setGuest(false);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final direction = loc.locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
    return Directionality(
      textDirection: direction,
      child: Scaffold(
        appBar: AppBar(title: Text(loc.translate('onboardingCreateAccount'))),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email is required';
                      final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!regex.hasMatch(value)) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 8) return 'Password must be at least 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading ? const CircularProgressIndicator() : Text(loc.translate('onboardingCreateAccount')),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                    child: Text(loc.translate('onboardingLogin')),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.read<SessionController>().setGuest(true).then(
                          (_) => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
                        ),
                    child: Text(loc.translate('onboardingGuest')),
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
