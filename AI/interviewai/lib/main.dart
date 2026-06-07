import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase 미설정 또는 값이 placeholder인 경우 → 로컬 인증으로 동작
    debugPrint('Firebase init skipped: $e');
  }
  runApp(const ProviderScope(child: App()));
}
