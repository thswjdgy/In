import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // google-services.json 미설정 시 Firebase 없이 실행 (면접 기능은 정상 동작)
  }
  runApp(const ProviderScope(child: App()));
}
