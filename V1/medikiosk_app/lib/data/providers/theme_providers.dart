import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final isDark = storage.getBool('is_dark_mode') ?? false;
  return isDark ? ThemeMode.dark : ThemeMode.light;
});

final localeProvider = StateProvider<Locale>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final langCode = storage.getString('app_language') ?? 'en';
  return Locale(langCode);
});

final kioskModeProvider = StateProvider<bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getBool('kiosk_mode_enabled') ?? false;
});
