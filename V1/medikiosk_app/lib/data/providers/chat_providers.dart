import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/chat_repository.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository());
