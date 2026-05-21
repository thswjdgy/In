import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../repositories/auth_repository.dart';
import '../../../shared/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _repo = AuthRepository();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await _repo.signInWithGoogle();
      if (user != null && mounted) context.go('/');
    } catch (e) {
      if (mounted) setState(() => _error = 'Google 로그인 실패: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _emailSignIn() async {
    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text;
    if (email.isEmpty || pw.isEmpty) {
      setState(() => _error = '이메일과 비밀번호를 입력해주세요.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await _repo.signInWithEmail(email, pw);
      if (user != null && mounted) context.go('/');
    } catch (e) {
      if (mounted) setState(() => _error = '로그인 실패: 이메일 또는 비밀번호를 확인해주세요.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              _buildHero(),
              const SizedBox(height: 48),
              _buildGoogleButton(),
              const SizedBox(height: 20),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildEmailField(),
              const SizedBox(height: 12),
              _buildPasswordField(),
              const SizedBox(height: 16),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                        color: AppTheme.error, fontSize: 13),
                  ),
                ),
              if (_error != null) const SizedBox(height: 12),
              _buildSignInButton(),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loading ? null : () => context.go('/'),
                child: const Text(
                  '로그인 없이 계속하기',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'InterviewAI',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '로그인하면 면접 기록이 저장됩니다',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      );

  Widget _buildGoogleButton() => OutlinedButton.icon(
        onPressed: _loading ? null : _googleSignIn,
        icon: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.g_mobiledata_rounded, size: 24),
        label: const Text('Google로 로그인'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          foregroundColor: const Color(0xFF1E293B),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500),
        ),
      );

  Widget _buildDivider() => Row(
        children: const [
          Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('또는',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ),
          Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        ],
      );

  Widget _buildEmailField() => TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        decoration: _inputDecoration('이메일', Icons.email_outlined),
      );

  Widget _buildPasswordField() => TextField(
        controller: _pwCtrl,
        obscureText: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _emailSignIn(),
        decoration: _inputDecoration('비밀번호', Icons.lock_outlined),
      );

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      );

  Widget _buildSignInButton() => FilledButton(
        onPressed: _loading ? null : _emailSignIn,
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: AppTheme.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          '이메일로 로그인',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );
}
