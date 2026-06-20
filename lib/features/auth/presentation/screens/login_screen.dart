import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/remote/supabase_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = S.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = l.authFieldsRequired);
      return;
    }
    if (password.length < AppConstants.minPasswordLength) {
      setState(() => _error = l.authPasswordTooShort);
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      if (_isLogin) {
        await SupabaseService.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        await SupabaseService.client.auth.signUp(
          email: email,
          password: password,
        );
      }

      if (mounted) context.go('/dashboard');
    } catch (e) {
      debugPrint('[Auth Error] $e');
      if (mounted) {
        setState(() => _error = _mapAuthError(e, l));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapAuthError(Object e, S l) {
    final msg = e.toString().toLowerCase();

    if (msg.contains('handshake') || msg.contains('certificate') || msg.contains('ssl') || msg.contains('socket')) {
      return l.authErrorConnection;
    }
    if (msg.contains('invalid login') || msg.contains('invalid_credentials')) {
      return l.authErrorInvalidCredentials;
    }
    if (msg.contains('email not confirmed')) {
      return l.authErrorEmailNotConfirmed;
    }
    if (msg.contains('user already registered') || msg.contains('already been registered')) {
      return l.authErrorAlreadyRegistered;
    }
    if (msg.contains('network') || msg.contains('timeout') || msg.contains('connection')) {
      return l.authErrorConnection;
    }

    return l.authErrorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Logo
              Container(
                width: AppConstants.logoSize,
                height: AppConstants.logoSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.logoBorderRadius),
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    AppConstants.logoCharacter,
                    style: TextStyle(
                      fontFamily: AppConstants.fontPrimary,
                      fontSize: AppConstants.logoFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(l.appName, style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                _isLogin ? l.authLoginTitle : l.authRegisterTitle,
                style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: l.authEmail,
                  prefixIcon: const Icon(Icons.email_rounded, color: AppColors.textSecondary, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: l.authPassword,
                  prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.textSecondary, size: 20),
                ),
              ),
              const SizedBox(height: 8),

              // Error
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 13, color: AppColors.danger)),
                ),

              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary))
                      : Text(_isLogin ? l.authLogin : l.authRegister),
                ),
              ),
              const SizedBox(height: 16),

              // Toggle
              TextButton(
                onPressed: () => setState(() { _isLogin = !_isLogin; _error = null; }),
                child: Text(
                  _isLogin ? l.authSwitchToRegister : l.authSwitchToLogin,
                  style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 14, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),

              // Offline
              TextButton(
                onPressed: () => context.go('/dashboard'),
                child: Text(l.authContinueOffline, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 13, color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
