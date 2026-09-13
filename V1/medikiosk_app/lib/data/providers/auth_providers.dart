import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());
