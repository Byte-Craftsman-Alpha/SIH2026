import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/storage_service.dart';
import 'core/services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER_ERROR: ${details.exceptionAsString()}');
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            'RENDER_ERROR:\n${details.exceptionAsString()}\n\nSTACK:\n${details.stack}',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      ),
    );
  };

  // Initialize services
  final storageService = StorageService();
  await storageService.init();
  ApiClient().syncWithStorage(storageService);

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const MediKioskApp(),
    ),
  );
}
