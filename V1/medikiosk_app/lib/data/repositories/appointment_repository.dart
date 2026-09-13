import '../../core/services/api_client.dart';

class AppointmentRepository {
  final ApiClient _apiClient;

  AppointmentRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Map<String, dynamic>>> getAppointments({String statusFilter = 'upcoming'}) async {
    try {
      final response = await _apiClient.dio.get(
        '/appointments',
        queryParameters: {'status_filter': statusFilter},
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          final slotStart = map['slot_start'] as String? ?? 'Today, 10:30 AM';
          final parts = slotStart.split(',');
          final dateStr = parts.isNotEmpty ? parts[0].trim() : slotStart;
          final timeStr = parts.length > 1 ? parts.sublist(1).join(',').trim() : slotStart;

          return {
            'id': map['id']?.toString() ?? '',
            'token': map['token_no']?.toString() ?? 'A-001',
            'doctor': map['doctor_name']?.toString() ?? 'Doctor',
            'specialty': map['specialty']?.toString() ?? 'Ayurveda / Medicine',
            'hospital': map['hospital_name']?.toString() ?? 'All India Institute of Ayurveda',
            'room': 'Room 104, OPD Block A',
            'date': dateStr,
            'time': timeStr,
            'urgency': map['urgency']?.toString() ?? 'regular',
            'status': map['status']?.toString() ?? 'booked',
            'consentRevoked': !(map['can_revoke'] == true),
            'shared_data_summary': map['shared_data_summary']?.toString() ?? 'Summary + 2 verified documents',
          };
        }).toList();
      }
    } catch (e) {
      // Fallback handled by caller
    }
    return [];
  }

  Future<bool> cancelAppointment(String id) async {
    try {
      final response = await _apiClient.dio.post('/appointments/$id/cancel');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> revokeConsent(String id) async {
    try {
      final response = await _apiClient.dio.post('/appointments/$id/revoke-access');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> bookAppointment({
    required String hospitalId,
    required String doctorId,
    required String slot,
    String urgency = 'regular',
    String? urgencyReason,
    String consentScope = 'summary_plus_documents',
  }) async {
    final payload = {
      'hospital_id': hospitalId,
      'doctor_id': doctorId,
      'slot': slot,
      'urgency': urgency,
      'urgency_reason': urgencyReason,
      'consent': {
        'scope': consentScope,
        'purpose': 'consultation',
        'consent_version': '1.2',
      },
      'context': {
        'summary_version_id': 'sum_ramesh_01',
        'document_ids': ['doc_01', 'doc_02'],
      }
    };

    try {
      final response = await _apiClient.dio.post('/appointments', data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      // Return fallback
    }
    return null;
  }
}
