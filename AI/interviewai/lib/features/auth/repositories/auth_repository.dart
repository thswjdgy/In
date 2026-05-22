import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<User?> signUp(String email, String password, {String? name}) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (name != null && name.isNotEmpty) {
      await result.user?.updateDisplayName(name);
    }
    return result.user;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  String parseError(Object e) {
    if (e is FirebaseAuthException) {
      return switch (e.code) {
        'user-not-found' => '등록되지 않은 이메일입니다.',
        'wrong-password' || 'invalid-credential' => '이메일 또는 비밀번호가 올바르지 않습니다.',
        'email-already-in-use' => '이미 사용 중인 이메일입니다.',
        'weak-password' => '비밀번호는 6자 이상이어야 합니다.',
        'invalid-email' => '이메일 형식이 올바르지 않습니다.',
        'too-many-requests' => '잠시 후 다시 시도해주세요.',
        'network-request-failed' => '인터넷 연결을 확인해주세요.',
        'operation-not-allowed' => '이 로그인 방식은 사용할 수 없습니다.',
        _ => '오류가 발생했습니다. 다시 시도해주세요.',
      };
    }
    return '오류가 발생했습니다.';
  }
}
