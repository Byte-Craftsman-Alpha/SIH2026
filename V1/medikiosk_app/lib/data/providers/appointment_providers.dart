import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/appointment_repository.dart';

final appointmentRepositoryProvider = Provider((ref) => AppointmentRepository());
