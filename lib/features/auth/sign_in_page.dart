import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../home/home_shell.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeShell(controller: widget.controller)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('signin'))),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: l10n.translate('email')),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value != null && value.contains('@') ? null : l10n.translate('email'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: l10n.translate('password'),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                obscureText: _obscure,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _submit,
                child: Text(l10n.translate('signin')),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                child: Text(l10n.translate('continue_guest')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
