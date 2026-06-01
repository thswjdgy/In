import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../repositories/auth_repository.dart';

// ── 토스 스타일 컬러 ──────────────────────────────────────────
const _kPrimary = Color(0xFF3182F6);
const _kBg = Color(0xFFFFFFFF);
const _kSurface = Color(0xFFF9FAFB);
const _kTitle = Color(0xFF191F28);
const _kBody = Color(0xFF6B7684);
const _kBorder = Color(0xFFE5E8EB);
const _kError = Color(0xFFFF3B30);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _repo = AuthRepository();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
    // 앱 재시작 시 이미 로그인된 계정이 있으면 홈으로 이동
    _repo.currentLocalUser.then((user) {
      if (user != null && mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: _kTitle),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Text(
                _tab.index == 0 ? '로그인' : '회원가입',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _kTitle,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _tab.index == 0
                    ? '면접 기록을 저장하고 성장 과정을 확인하세요'
                    : 'AI 면접 코치와 함께 취업을 준비하세요',
                style: const TextStyle(fontSize: 14, color: _kBody),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _ToggleTabs(controller: _tab),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TabBarView(
                controller: _tab,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _LoginForm(repo: _repo),
                  _SignUpForm(repo: _repo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 탭 토글 ──────────────────────────────────────────────────

class _ToggleTabs extends StatelessWidget {
  final TabController controller;
  const _ToggleTabs({required this.controller});

  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(3),
          dividerColor: Colors.transparent,
          labelColor: _kTitle,
          unselectedLabelColor: _kBody,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          tabs: const [Tab(text: '로그인'), Tab(text: '회원가입')],
        ),
      );
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
  final _pwFocus = FocusNode();
  bool _loading = false;
  bool _pwVisible = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
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
      final user = await widget.repo.signInWithEmail(email, pw);
      if (user != null && mounted) context.go('/');
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TossField(
            label: '이메일',
            controller: _emailCtrl,
            hint: 'example@email.com',
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _pwFocus.requestFocus(),
          ),
          const SizedBox(height: 16),
          _TossField(
            label: '비밀번호',
            controller: _pwCtrl,
            focusNode: _pwFocus,
            hint: '비밀번호 입력',
            obscure: !_pwVisible,
            suffix: GestureDetector(
              onTap: () => setState(() => _pwVisible = !_pwVisible),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  _pwVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: _kBody,
                ),
              ),
            ),
            onSubmitted: (_) => _signIn(),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _loading ? null : () => _showForgotPassword(context),
              child: const Text(
                '비밀번호를 잊으셨나요?',
                style: TextStyle(
                  fontSize: 13,
                  color: _kPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: _error!),
          ],
          const SizedBox(height: 24),
          _TossButton(label: '로그인', loading: _loading, onTap: _signIn),
          const SizedBox(height: 16),
          _Divider(),
          const SizedBox(height: 16),
          _GoogleButton(loading: _loading, onTap: _googleSignIn),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () => context.go('/'),
              child: const Text(
                '로그인 없이 계속하기',
                style: TextStyle(
                  fontSize: 13,
                  color: _kBody,
                  decoration: TextDecoration.underline,
                  decorationColor: _kBody,
                ),
              ),
            ),
          ),
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

    if (name.isEmpty) { setState(() => _error = '이름을 입력해주세요.'); return; }
    if (email.isEmpty) { setState(() => _error = '이메일을 입력해주세요.'); return; }
    if (pw.length < 6) { setState(() => _error = '비밀번호는 6자 이상이어야 합니다.'); return; }
    if (pw != pwConfirm) { setState(() => _error = '비밀번호가 일치하지 않습니다.'); return; }
    if (!_agreed) { setState(() => _error = '이용약관에 동의해주세요.'); return; }

    setState(() { _loading = true; _error = null; });
    try {
      final user = await widget.repo.signUp(email, pw, name: name);
      if (user != null && mounted) context.go('/');
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TossField(
            label: '이름',
            controller: _nameCtrl,
            hint: '홍길동',
            onSubmitted: (_) => _emailFocus.requestFocus(),
          ),
          const SizedBox(height: 16),
          _TossField(
            label: '이메일',
            controller: _emailCtrl,
            focusNode: _emailFocus,
            hint: 'example@email.com',
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _pwFocus.requestFocus(),
          ),
          const SizedBox(height: 16),
          _TossField(
            label: '비밀번호',
            controller: _pwCtrl,
            focusNode: _pwFocus,
            hint: '6자 이상 입력',
            obscure: !_pwVisible,
            suffix: GestureDetector(
              onTap: () => setState(() => _pwVisible = !_pwVisible),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  _pwVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: _kBody,
                ),
              ),
            ),
            onSubmitted: (_) => _pwConfirmFocus.requestFocus(),
          ),
          const SizedBox(height: 16),
          _TossField(
            label: '비밀번호 확인',
            controller: _pwConfirmCtrl,
            focusNode: _pwConfirmFocus,
            hint: '비밀번호 재입력',
            obscure: !_pwConfirmVisible,
            suffix: GestureDetector(
              onTap: () =>
                  setState(() => _pwConfirmVisible = !_pwConfirmVisible),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  _pwConfirmVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: _kBody,
                ),
              ),
            ),
            onSubmitted: (_) => _signUp(),
          ),
          const SizedBox(height: 20),
          _AgreeRow(
            agreed: _agreed,
            onChanged: (v) => setState(() => _agreed = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: _error!),
          ],
          const SizedBox(height: 24),
          _TossButton(label: '회원가입', loading: _loading, onTap: _signUp),
          const SizedBox(height: 16),
          _Divider(),
          const SizedBox(height: 16),
          _GoogleButton(
            loading: _loading,
            onTap: _googleSignUp,
            label: 'Google로 시작하기',
          ),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () => context.go('/'),
              child: const Text(
                '로그인 없이 계속하기',
                style: TextStyle(
                  fontSize: 13,
                  color: _kBody,
                  decoration: TextDecoration.underline,
                  decorationColor: _kBody,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 비밀번호 찾기 시트 ────────────────────────────────────────

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
    setState(() {
      _loading = true;
      _error = null;
    });
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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            if (!_sent) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '비밀번호 재설정',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _kTitle,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '가입한 이메일로 재설정 링크를 보내드려요',
                  style: TextStyle(fontSize: 14, color: _kBody),
                ),
              ),
              const SizedBox(height: 24),
              _TossField(
                label: '이메일',
                controller: _emailCtrl,
                hint: 'example@email.com',
                keyboardType: TextInputType.emailAddress,
                onSubmitted: (_) => _send(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                _ErrorBanner(message: _error!),
              ],
              const SizedBox(height: 24),
              _TossButton(
                  label: '재설정 링크 보내기',
                  loading: _loading,
                  onTap: _send),
            ] else ...[
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFECF5FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined,
                    size: 28, color: _kPrimary),
              ),
              const SizedBox(height: 16),
              const Text(
                '이메일을 확인해주세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _kTitle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_emailCtrl.text.trim()}으로\n비밀번호 재설정 링크를 보냈어요',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: _kBody, height: 1.6),
              ),
              const SizedBox(height: 28),
              _TossButton(
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

class _TossField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;

  const _TossField({
    required this.label,
    required this.controller,
    this.focusNode,
    required this.hint,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kTitle,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscure,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
            onSubmitted: onSubmitted,
            style: const TextStyle(
              fontSize: 16,
              color: _kTitle,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFFBEC5CC), fontSize: 15),
              suffixIcon: suffix,
              filled: true,
              fillColor: _kSurface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _kPrimary, width: 1.5),
              ),
            ),
          ),
        ],
      );
}

class _TossButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _TossButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: loading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 54,
          decoration: BoxDecoration(
            color: loading ? const Color(0xFFB8D4FB) : _kPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
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
          height: 54,
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFF4285F4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
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
                  color: _kTitle,
                ),
              ),
            ],
          ),
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Expanded(child: Divider(color: _kBorder, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: const Text(
              '또는',
              style: TextStyle(
                  fontSize: 12, color: _kBody, fontWeight: FontWeight.w500),
            ),
          ),
          const Expanded(child: Divider(color: _kBorder, thickness: 1)),
        ],
      );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kError.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 16, color: _kError),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    fontSize: 13, color: _kError, height: 1.4),
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
                color: agreed ? _kPrimary : _kBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: agreed ? _kPrimary : _kBorder,
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
                  children: [
                    TextSpan(
                      text: '이용약관',
                      style: TextStyle(
                        fontSize: 13,
                        color: _kPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' 및 ',
                      style: TextStyle(fontSize: 13, color: _kBody),
                    ),
                    TextSpan(
                      text: '개인정보 처리방침',
                      style: TextStyle(
                        fontSize: 13,
                        color: _kPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '에 동의합니다',
                      style: TextStyle(fontSize: 13, color: _kBody),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
