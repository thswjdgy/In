import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Firebase 없이 동작하는 로컬 사용자 모델
class LocalUser {
  final String uid;
  final String email;
  final String? displayName;

  const LocalUser({
    required this.uid,
    required this.email,
    this.displayName,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
      };

  factory LocalUser.fromJson(Map<String, dynamic> j) => LocalUser(
        uid: j['uid'] as String,
        email: j['email'] as String,
        displayName: j['displayName'] as String?,
      );
}

class AuthRepository {
  static const _kLocalUsers = 'local_users';
  static const _kCurrentUser = 'local_current_user';

  // Firebase 사용 가능 여부 확인 (앱이 실제로 초기화된 경우만 true)
  bool get _firebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth get _auth => FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ── 현재 로그인 유저 (Firebase 우선, 없으면 로컬) ──────────────

  Future<LocalUser?> get currentLocalUser async {
    if (_firebaseAvailable) {
      final u = _auth.currentUser;
      if (u != null) {
        return LocalUser(
            uid: u.uid, email: u.email ?? '', displayName: u.displayName);
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kCurrentUser);
    if (json == null) return null;
    return LocalUser.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Stream<LocalUser?> get localAuthChanges async* {
    if (_firebaseAvailable) {
      await for (final u in _auth.authStateChanges()) {
        yield u == null
            ? null
            : LocalUser(
                uid: u.uid,
                email: u.email ?? '',
                displayName: u.displayName);
      }
    } else {
      yield await currentLocalUser;
    }
  }

  // ── Firebase 래핑 메서드 ──────────────────────────────────────

  Future<LocalUser?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    final u = result.user;
    if (u == null) return null;
    return LocalUser(
        uid: u.uid, email: u.email ?? '', displayName: u.displayName);
  }

  Future<LocalUser?> signInWithEmail(String email, String password) async {
    if (_firebaseAvailable) {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final u = result.user;
      if (u == null) return null;
      return LocalUser(
          uid: u.uid, email: u.email ?? '', displayName: u.displayName);
    }
    // 로컬 인증
    return _localSignIn(email, password);
  }

  Future<LocalUser?> signUp(String email, String password,
      {String? name}) async {
    if (_firebaseAvailable) {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (name != null && name.isNotEmpty) {
        await result.user?.updateDisplayName(name);
      }
      final u = result.user;
      if (u == null) return null;
      return LocalUser(uid: u.uid, email: email, displayName: name);
    }
    // 로컬 회원가입
    return _localSignUp(email, password, name: name);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (_firebaseAvailable) {
      await _auth.sendPasswordResetEmail(email: email);
      return;
    }
    // 로컬 환경에서는 성공 처리 (실제 이메일 없음)
  }

  Future<void> signOut() async {
    if (_firebaseAvailable) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      await _auth.signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCurrentUser);
  }

  // ── 로컬 인증 (Firebase 미설정 시 fallback) ───────────────────

  Future<Map<String, Map<String, dynamic>>> _loadLocalUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocalUsers);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded
        .map((k, v) => MapEntry(k, v as Map<String, dynamic>));
  }

  Future<void> _saveLocalUsers(
      Map<String, Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocalUsers, jsonEncode(users));
  }

  Future<LocalUser> _localSignUp(String email, String password,
      {String? name}) async {
    final users = await _loadLocalUsers();
    if (users.containsKey(email)) {
      throw _LocalAuthException('이미 사용 중인 이메일입니다.');
    }
    final uid = 'local_${DateTime.now().millisecondsSinceEpoch}';
    users[email] = {'uid': uid, 'password': password, 'displayName': name};
    await _saveLocalUsers(users);
    final user = LocalUser(uid: uid, email: email, displayName: name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrentUser, jsonEncode(user.toJson()));
    return user;
  }

  Future<LocalUser> _localSignIn(String email, String password) async {
    final users = await _loadLocalUsers();
    final data = users[email];
    if (data == null) {
      throw _LocalAuthException('등록되지 않은 이메일입니다.');
    }
    if (data['password'] != password) {
      throw _LocalAuthException('이메일 또는 비밀번호가 올바르지 않습니다.');
    }
    final user = LocalUser(
      uid: data['uid'] as String,
      email: email,
      displayName: data['displayName'] as String?,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrentUser, jsonEncode(user.toJson()));
    return user;
  }

  // ── 에러 파싱 ─────────────────────────────────────────────────

  String parseError(Object e) {
    if (e is _LocalAuthException) return e.message;
    final msg = e.toString();
    if (msg.contains('no-app') || msg.contains('initializeApp')) {
      return 'Firebase가 설정되지 않았습니다.';
    }
    if (e is FirebaseAuthException) {
      return switch (e.code) {
        'user-not-found' => '등록되지 않은 이메일입니다.',
        'wrong-password' || 'invalid-credential' =>
          '이메일 또는 비밀번호가 올바르지 않습니다.',
        'email-already-in-use' => '이미 사용 중인 이메일입니다.',
        'weak-password' => '비밀번호는 6자 이상이어야 합니다.',
        'invalid-email' => '이메일 형식이 올바르지 않습니다.',
        'too-many-requests' => '잠시 후 다시 시도해주세요.',
        'network-request-failed' => '인터넷 연결을 확인해주세요.',
        'operation-not-allowed' => '이 로그인 방식은 사용할 수 없습니다.',
        _ => '오류가 발생했습니다. 다시 시도해주세요.',
      };
    }
    return '오류가 발생했습니다. 다시 시도해주세요.';
  }
}

class _LocalAuthException implements Exception {
  final String message;
  const _LocalAuthException(this.message);
}
