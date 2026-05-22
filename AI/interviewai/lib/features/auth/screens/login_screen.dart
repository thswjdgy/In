import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../repositories/auth_repository.dart';
import '../../../shared/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _repo = AuthRepository();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.primary,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            _HeroHeader(tabCtrl: _tabCtrl),
            Expanded(
              child: _AuthCard(tabCtrl: _tabCtrl, repo: _repo),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 상단 브랜드 영역 ──────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final TabController tabCtrl;
  const _HeroHeader({required this.tabCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'InterviewAI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                tabCtrl.index == 0
                    ? '다시 만나서\n반갑습니다 👋'
                    : '함께 시작해요\n지금 바로 💪',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.35,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tabCtrl.index == 0
                    ? '면접 연습 기록이 기다리고 있어요'
                    : 'AI 면접 코치와 함께 취업을 준비하세요',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 하단 카드 (탭 + 폼) ──────────────────────────────────────

class _AuthCard extends StatelessWidget {
  final TabController tabCtrl;
  final AuthRepository repo;
  const _AuthCard({required this.tabCtrl, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          _TabBar(tabCtrl: tabCtrl),
          Expanded(
            child: TabBarView(
              controller: tabCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _LoginForm(repo: repo),
                _SignUpForm(repo: repo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 탭 바 ────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final TabController tabCtrl;
  const _TabBar({required this.tabCtrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: tabCtrl,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(3),
          labelColor: AppTheme.primary,
          unselectedLabelColor: const Color(0xFF94A3B8),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: '로그인'),
            Tab(text: '회원가입'),
          ],
        ),
      ),
    );
  }
}

// ── 로그인 폼 ─────────────────────────────────────────────────

class _LoginForm extends StatefulWidget {
  final AuthRepository repo;
  const _LoginForm({required this.repo});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _pwFocus = FocusNode();
  bool _loading = false;
  bool _pwVisible = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _emailFocus.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text;
    if (email.isEmpty || pw.isEmpty) {
      setState(() => _error = '이메일과 비밀번호를 입력해주세요.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await widget.repo.signInWithEmail(email, pw);
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) setState(() => _error = widget.repo.parseError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = await widget.repo.signInWithGoogle();
      if (user != null && mounted) context.go('/');
    } catch (e) {
      if (mounted) setState(() => _error = widget.repo.parseError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GoogleButton(loading: _loading, onTap: _googleSignIn),
          const SizedBox(height: 16),
          _Divider(),
          const SizedBox(height: 16),
          _AuthField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            hint: '이메일',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            nextFocus: _pwFocus,
          ),
          const SizedBox(height: 10),
          _AuthField(
            controller: _pwCtrl,
            focusNode: _pwFocus,
            hint: '비밀번호',
            icon: Icons.lock_outlined,
            obscure: !_pwVisible,
            suffix: IconButton(
              icon: Icon(
                _pwVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 20,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: () => setState(() => _pwVisible = !_pwVisible),
            ),
            onSubmitted: (_) => _signIn(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _loading ? null : () => _showForgotPassword(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '비밀번호를 잊으셨나요?',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            _ErrorBox(message: _error!),
          ],
          const SizedBox(height: 16),
          _PrimaryButton(
            label: '로그인',
            loading: _loading,
            onTap: _signIn,
          ),
          const SizedBox(height: 16),
          _GuestButton(),
        ],
      ),
    );
  }

  void _showForgotPassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ForgotPasswordSheet(repo: widget.repo),
    );
  }
}

// ── 회원가입 폼 ───────────────────────────────────────────────

class _SignUpForm extends StatefulWidget {
  final AuthRepository repo;
  const _SignUpForm({required this.repo});

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pwConfirmCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _pwFocus = FocusNode();
  final _pwConfirmFocus = FocusNode();
  bool _loading = false;
  bool _pwVisible = false;
  bool _pwConfirmVisible = false;
  bool _agreed = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _pwConfirmCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _pwFocus.dispose();
    _pwConfirmFocus.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text;
    final pwConfirm = _pwConfirmCtrl.text;

    if (name.isEmpty) {
      setState(() => _error = '이름을 입력해주세요.');
      return;
    }
    if (email.isEmpty) {
      setState(() => _error = '이메일을 입력해주세요.');
      return;
    }
    if (pw.length < 6) {
      setState(() => _error = '비밀번호는 6자 이상이어야 합니다.');
      return;
    }
    if (pw != pwConfirm) {
      setState(() => _error = '비밀번호가 일치하지 않습니다.');
      return;
    }
    if (!_agreed) {
      setState(() => _error = '이용약관에 동의해주세요.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await widget.repo.signUp(email, pw, name: name);
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) setState(() => _error = widget.repo.parseError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignUp() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = await widget.repo.signInWithGoogle();
      if (user != null && mounted) context.go('/');
    } catch (e) {
      if (mounted) setState(() => _error = widget.repo.parseError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GoogleButton(loading: _loading, onTap: _googleSignUp, label: 'Google로 시작하기'),
          const SizedBox(height: 16),
          _Divider(),
          const SizedBox(height: 16),
          _AuthField(
            controller: _nameCtrl,
            focusNode: _nameFocus,
            hint: '이름',
            icon: Icons.person_outline_rounded,
            nextFocus: _emailFocus,
          ),
          const SizedBox(height: 10),
          _AuthField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            hint: '이메일',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            nextFocus: _pwFocus,
          ),
          const SizedBox(height: 10),
          _AuthField(
            controller: _pwCtrl,
            focusNode: _pwFocus,
            hint: '비밀번호 (6자 이상)',
            icon: Icons.lock_outlined,
            obscure: !_pwVisible,
            suffix: IconButton(
              icon: Icon(
                _pwVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 20,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: () => setState(() => _pwVisible = !_pwVisible),
            ),
            nextFocus: _pwConfirmFocus,
          ),
          const SizedBox(height: 10),
          _AuthField(
            controller: _pwConfirmCtrl,
            focusNode: _pwConfirmFocus,
            hint: '비밀번호 확인',
            icon: Icons.lock_outlined,
            obscure: !_pwConfirmVisible,
            suffix: IconButton(
              icon: Icon(
                _pwConfirmVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 20,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: () => setState(() => _pwConfirmVisible = !_pwConfirmVisible),
            ),
            onSubmitted: (_) => _signUp(),
          ),
          const SizedBox(height: 14),
          _AgreeRow(
            agreed: _agreed,
            onChanged: (v) => setState(() => _agreed = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            _ErrorBox(message: _error!),
          ],
          const SizedBox(height: 16),
          _PrimaryButton(
            label: '회원가입',
            loading: _loading,
            onTap: _signUp,
          ),
          const SizedBox(height: 16),
          _GuestButton(),
        ],
      ),
    );
  }
}

// ── 비밀번호 찾기 바텀시트 ────────────────────────────────────

class _ForgotPasswordSheet extends StatefulWidget {
  final AuthRepository repo;
  const _ForgotPasswordSheet({required this.repo});

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = '이메일을 입력해주세요.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await widget.repo.sendPasswordResetEmail(email);
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _error = widget.repo.parseError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            if (!_sent) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '비밀번호 재설정',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '가입한 이메일을 입력하면 재설정 링크를 보내드려요',
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                ),
              ),
              const SizedBox(height: 20),
              _AuthField(
                controller: _emailCtrl,
                hint: '이메일',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                onSubmitted: (_) => _send(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                _ErrorBox(message: _error!),
              ],
              const SizedBox(height: 16),
              _PrimaryButton(label: '재설정 링크 보내기', loading: _loading, onTap: _send),
            ] else ...[
              const SizedBox(height: 8),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_rounded,
                    size: 32, color: AppTheme.success),
              ),
              const SizedBox(height: 16),
              const Text(
                '이메일을 확인하세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_emailCtrl.text.trim()} 으로\n비밀번호 재설정 링크를 보냈어요',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
              ),
              const SizedBox(height: 24),
              _PrimaryButton(
                label: '확인',
                loading: false,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 공용 컴포넌트 ─────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final FocusNode? nextFocus;
  final ValueChanged<String>? onSubmitted;

  const _AuthField({
    required this.controller,
    this.focusNode,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.nextFocus,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        keyboardType: keyboardType,
        textInputAction:
            nextFocus != null ? TextInputAction.next : TextInputAction.done,
        onSubmitted: onSubmitted ??
            (nextFocus != null
                ? (_) => FocusScope.of(context).requestFocus(nextFocus)
                : null),
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.8),
          ),
        ),
      );
}

class _GoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  final String label;

  const _GoogleButton({
    required this.loading,
    required this.onTap,
    this.label = 'Google로 로그인',
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: loading ? null : onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4285F4),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '또는',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFCBD5E1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        ],
      );
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: loading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 52,
          decoration: BoxDecoration(
            gradient: loading
                ? null
                : const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  ),
            color: loading ? const Color(0xFFE2E8F0) : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: loading
                ? null
                : [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF94A3B8),
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      );
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 16, color: AppTheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.error,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
}

class _AgreeRow extends StatelessWidget {
  final bool agreed;
  final ValueChanged<bool> onChanged;

  const _AgreeRow({required this.agreed, required this.onChanged});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onChanged(!agreed),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: agreed ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: agreed ? AppTheme.primary : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: agreed
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text.rich(
                TextSpan(
                  text: '이용약관',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.primary,
                  ),
                  children: [
                    TextSpan(
                      text: ' 및 ',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    TextSpan(
                      text: '개인정보 처리방침',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: '에 동의합니다',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _GuestButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () => context.go('/'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF94A3B8),
        ),
        child: const Text(
          '로그인 없이 계속하기',
          style: TextStyle(fontSize: 13),
        ),
      );
}
