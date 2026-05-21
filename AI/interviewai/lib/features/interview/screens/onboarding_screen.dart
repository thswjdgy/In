import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';

const _countOptions = [3, 5, 7, 10];

const _allJobs = [
  // 의료·보건
  '간호사', '의사', '약사', '한의사', '치과의사', '치과위생사',
  '물리치료사', '작업치료사', '방사선사', '임상병리사', '응급구조사',
  '요양보호사', '보건교사', '영양사', '의료기기영업',
  // 교육
  '교사', '초등교사', '중등교사', '유치원교사', '보육교사',
  '학원강사', '과외교사', '교수', '강사', '특수교사',
  // 공공·행정
  '공무원', '경찰관', '소방관', '군인', '사회복지사',
  '행정직', '우체국직원', '공기업직원',
  // IT·개발
  '개발자', '백엔드개발자', '프론트엔드개발자', '앱개발자', '풀스택개발자',
  'AI엔지니어', 'DevOps엔지니어', '데이터사이언티스트', '데이터엔지니어',
  'QA엔지니어', '보안엔지니어', '클라우드엔지니어', '시스템엔지니어',
  // 기획·경영
  '기획자', 'PM', 'PO', '컨설턴트', '경영지원', '전략기획',
  '인사담당자', '재무담당자', '회계사', '세무사', '법무담당자',
  // 마케팅·영업
  '마케터', '디지털마케터', '콘텐츠마케터', '브랜드마케터', 'SNS마케터',
  '영업직', '영업관리', '해외영업', '무역직', '바이어', 'MD',
  // 디자인·크리에이티브
  '디자이너', 'UX디자이너', 'UI디자이너', '그래픽디자이너', '제품디자이너',
  '영상편집자', 'PD', '작가', '카피라이터', '방송작가', '번역가',
  // 금융
  '은행원', '증권사직원', '보험설계사', '펀드매니저', '신용분석사',
  '투자분석가', '금융컨설턴트',
  // 제조·엔지니어링
  '생산직', '품질관리', '연구원', '연구개발', '기계엔지니어',
  '전기엔지니어', '화학연구원', '환경연구원', '건축사', '토목엔지니어',
  // 서비스·요식
  '승무원', '호텔직원', '요리사', '셰프', '바리스타', '제과제빵사',
  '미용사', '헤어디자이너', '메이크업아티스트', '피부관리사',
  // 유통·물류
  '물류직', '유통직', '구매담당자', '쇼핑몰운영', '상품기획',
  // 기타 전문직
  '변호사', '법무사', '노무사', '관세사', '감정평가사',
  '기자', '아나운서', '상담사', '심리상담사', '사회복지사',
  '부동산중개사', '고객서비스', 'CS담당자',
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _jobController = TextEditingController();
  final _focusNode = FocusNode();
  String _selectedType = 'technical';
  int _questionCount = 5;

  bool get _canStart => _jobController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _jobController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _jobController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _start() {
    if (!_canStart) return;
    FocusScope.of(context).unfocus();
    context.push('/interview', extra: {
      'job': _jobController.text.trim(),
      'type': _selectedType,
      'count': _questionCount,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                  child: Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.history_rounded),
                        color: const Color(0xFF94A3B8),
                        tooltip: '면접 기록',
                        onPressed: () => context.push('/history'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHero(),
                    const SizedBox(height: 36),
                    _label('지원 직종'),
                    const SizedBox(height: 10),
                    _JobAutocomplete(
                      controller: _jobController,
                      focusNode: _focusNode,
                      onSubmitted: (_) => _start(),
                    ),
                    const SizedBox(height: 28),
                    _label('면접 유형'),
                    const SizedBox(height: 10),
                    _TypeRow(
                      selected: _selectedType,
                      onSelect: (t) => setState(() => _selectedType = t),
                    ),
                    const SizedBox(height: 28),
                    _label('질문 수'),
                    const SizedBox(height: 10),
                    _CountRow(
                      selected: _questionCount,
                      onSelect: (n) => setState(() => _questionCount = n),
                    ),
                    const SizedBox(height: 40),
                    _StartButton(
                      enabled: _canStart,
                      onTap: _start,
                    ),
                    const SizedBox(height: 24),
                  ]),
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
            child:
                const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'InterviewAI',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'AI 면접관과 실전처럼 연습하세요',
            style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
          ),
        ],
      );

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.5,
        ),
      );
}

// ── 직종 자동완성 ─────────────────────────────────────────────

class _JobAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  const _JobAutocomplete({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  @override
  State<_JobAutocomplete> createState() => _JobAutocompleteState();
}

class _JobAutocompleteState extends State<_JobAutocomplete> {
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onChanged() {
    final q = widget.controller.text.trim();
    setState(() {
      _filtered = q.isEmpty
          ? []
          : _allJobs.where((j) => j.contains(q)).take(6).toList();
    });
  }

  void _onFocusChanged() {
    if (!widget.focusNode.hasFocus) setState(() => _filtered = []);
  }

  void _select(String job) {
    widget.controller.text = job;
    widget.controller.selection =
        TextSelection.fromPosition(TextPosition(offset: job.length));
    widget.focusNode.unfocus();
    setState(() => _filtered = []);
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            textInputAction: TextInputAction.done,
            onSubmitted: widget.onSubmitted,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: '예) 간호사, 영업직, 공무원…',
              hintStyle: const TextStyle(
                fontSize: 15,
                color: Color(0xFFCBD5E1),
              ),
              prefixIcon: const Icon(
                Icons.work_outline_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          size: 18, color: Color(0xFF94A3B8)),
                      onPressed: () {
                        widget.controller.clear();
                        setState(() => _filtered = []);
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                borderSide:
                    const BorderSide(color: AppTheme.primary, width: 1.5),
              ),
            ),
          ),
          if (_filtered.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: _filtered.asMap().entries.map((entry) {
                  final isLast = entry.key == _filtered.length - 1;
                  return InkWell(
                    onTap: () => _select(entry.value),
                    borderRadius: BorderRadius.vertical(
                      top: entry.key == 0
                          ? const Radius.circular(12)
                          : Radius.zero,
                      bottom:
                          isLast ? const Radius.circular(12) : Radius.zero,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      decoration: isLast
                          ? null
                          : const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Color(0xFFF1F5F9), width: 1),
                              ),
                            ),
                      child: Row(
                        children: [
                          const Icon(Icons.work_outline_rounded,
                              size: 16, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 10),
                          Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      );
}

// ── 면접 유형 ─────────────────────────────────────────────────

class _TypeRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _TypeRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _TypeChip(
            label: '직무 면접',
            icon: Icons.work_rounded,
            value: 'technical',
            selected: selected == 'technical',
            onTap: () => onSelect('technical'),
          ),
          const SizedBox(width: 10),
          _TypeChip(
            label: '인성 면접',
            icon: Icons.person_outline_rounded,
            value: 'personality',
            selected: selected == 'personality',
            onTap: () => onSelect('personality'),
          ),
        ],
      );
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.primary.withValues(alpha: 0.07)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    selected ? AppTheme.primary : const Color(0xFFE2E8F0),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 18,
                    color: selected
                        ? AppTheme.primary
                        : const Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppTheme.primary
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ── 질문 수 ───────────────────────────────────────────────────

class _CountRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _CountRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => Row(
        children: _countOptions.asMap().entries.map((entry) {
          final n = entry.value;
          final isLast = entry.key == _countOptions.length - 1;
          final isSelected = selected == n;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 8),
              child: GestureDetector(
                onTap: () => onSelect(n),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$n',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '문제',
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
}

// ── 시작 버튼 ─────────────────────────────────────────────────

class _StartButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _StartButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  )
                : null,
            color: enabled ? null : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mic_rounded,
                  color: enabled ? Colors.white : const Color(0xFF94A3B8),
                  size: 20),
              const SizedBox(width: 8),
              Text(
                '면접 시작',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: enabled ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      );
}
