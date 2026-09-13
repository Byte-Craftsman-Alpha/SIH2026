import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_button.dart';
import '../../../data/repositories/appointment_repository.dart';

class AppointmentsListScreen extends ConsumerStatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  ConsumerState<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends ConsumerState<AppointmentsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppointmentRepository _appointmentRepo = AppointmentRepository();

  bool _isLoading = true;
  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _pastAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    try {
      final upcoming = await _appointmentRepo.getAppointments(statusFilter: 'upcoming');
      final past = await _appointmentRepo.getAppointments(statusFilter: 'past');
      if (mounted) {
        setState(() {
          _upcomingAppointments = upcoming;
          _pastAppointments = past;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _revokeConsent(Map<String, dynamic> appt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('डेटा सहमति वापस लें? (Revoke Consent)'),
        content: Text(
          'क्या आप ${appt['doctor']} और अस्पताल के साथ साझा किए गए अपने क्लिनिकल रिकॉर्ड्स की सहमति तत्काल वापस लेना चाहते हैं?\n\n(DPDP Act 2023 के तहत आपका डेटा अस्पताल पोर्टल से हटा दिया जाएगा।)',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('रद्द करें (Cancel)'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyLight),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('हाँ, निरस्त करें', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final apptId = appt['id']?.toString() ?? '';
      bool success = false;
      if (apptId.isNotEmpty) {
        success = await _appointmentRepo.revokeConsent(apptId);
      }
      if (mounted) {
        setState(() {
          appt['consentRevoked'] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'सहमति सफलतापूर्वक निरस्त कर दी गई (Consent Revoked).'
                : 'सहमति स्थानीय रूप से निरस्त कर दी गई।'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadAppointments();
      }
    }
  }

  Future<void> _cancelAppointment(Map<String, dynamic> appt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('अपॉइंटमेंट रद्द करें? (Cancel Appointment)'),
        content: Text(
          'क्या आप टोकन ${appt['token']} वाली यह अपॉइंटमेंट रद्द करना चाहते हैं?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('नहीं (Keep)'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyLight),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('रद्द करें (Cancel)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final apptId = appt['id']?.toString() ?? '';
      bool success = false;
      if (apptId.isNotEmpty) {
        success = await _appointmentRepo.cancelAppointment(apptId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'टोकन ${appt['token']} रद्द कर दिया गया है।'
                : 'अपॉइंटमेंट रद्द करने में समस्या आई।'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadAppointments();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('अपॉइंटमेंट्स (Appointments)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          indicatorColor: isDark ? AppColors.accentDark : AppColors.accentLight,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'आगामी (Upcoming)'),
            Tab(text: 'पूर्व परामर्श (Past)'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingTab(isDark),
                _buildPastTab(isDark),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/hospitals');
          _loadAppointments();
        },
        icon: const Icon(Icons.add),
        label: const Text('नई अपॉइंटमेंट (New)'),
      ),
    );
  }

  Widget _buildUpcomingTab(bool isDark) {
    if (_upcomingAppointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAppointments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'कोई आगामी अपॉइंटमेंट नहीं है',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'No active appointments scheduled',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                  ),
                ),
                const SizedBox(height: 24),
                MkButton(
                  text: 'डॉक्टर चुनें व टोकन लें',
                  onPressed: () async {
                    await context.push('/hospitals');
                    _loadAppointments();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        itemCount: _upcomingAppointments.length,
        itemBuilder: (context, index) {
          final appt = _upcomingAppointments[index];
          return _buildAppointmentCard(appt, isUpcoming: true, isDark: isDark);
        },
      ),
    );
  }

  Widget _buildPastTab(bool isDark) {
    if (_pastAppointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAppointments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'कोई पूर्व परामर्श रिकॉर्ड नहीं मिला',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'No past appointments or cancellations',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        itemCount: _pastAppointments.length,
        itemBuilder: (context, index) {
          final appt = _pastAppointments[index];
          return _buildAppointmentCard(appt, isUpcoming: false, isDark: isDark);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(
    Map<String, dynamic> appt, {
    required bool isUpcoming,
    required bool isDark,
  }) {
    final bool isUrgent = appt['urgency'] == 'urgent';
    final bool isRevoked = appt['consentRevoked'] == true;
    final String status = appt['status']?.toString() ?? 'booked';
    final bool isCancelled = status == 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Token + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appt['token'] ?? 'A-001',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  if (isUrgent)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.emergencyLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'प्राथमिकता (Urgent)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.emergencyLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isCancelled
                          ? AppColors.emergencyLight.withValues(alpha: 0.15)
                          : isUpcoming
                              ? (isDark
                                  ? AppColors.ayushDark.withValues(alpha: 0.15)
                                  : AppColors.ayushLight.withValues(alpha: 0.15))
                              : (isDark
                                  ? AppColors.onSurfaceVariantDark.withValues(alpha: 0.15)
                                  : AppColors.onSurfaceVariantLight.withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isCancelled
                          ? 'रद्द (Cancelled)'
                          : isUpcoming
                              ? 'सक्रिय (Active)'
                              : 'पूर्ण (Completed)',
                      style: AppTextStyles.caption.copyWith(
                        color: isCancelled
                            ? AppColors.emergencyLight
                            : isUpcoming
                                ? (isDark ? AppColors.ayushDark : AppColors.ayushLight)
                                : (isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Doctor & Specialty
          Text(
            appt['doctor'] ?? 'Doctor',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            appt['specialty'] ?? 'Ayurveda / Medicine',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.ayushDark : AppColors.ayushLight,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),

          // Hospital & Room
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${appt['hospital']} (${appt['room']})',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Date & Time
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${appt['date']}  •  ${appt['time']}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),

          // DPDP Consent Status & Actions
          if (isUpcoming && !isCancelled) ...[
            Row(
              children: [
                Icon(
                  isRevoked ? Icons.lock_outline : Icons.verified_user_outlined,
                  size: 16,
                  color: isRevoked ? AppColors.emergencyLight : (isDark ? AppColors.ayushDark : AppColors.ayushLight),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isRevoked
                        ? 'डेटा सहमति निरस्त (Data Access Revoked)'
                        : 'डेटा साझाकरण सक्रिय (DPDP Consent Active)',
                    style: AppTextStyles.caption.copyWith(
                      color: isRevoked
                          ? AppColors.emergencyLight
                          : (isDark ? AppColors.ayushDark : AppColors.ayushLight),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isRevoked)
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _revokeConsent(appt),
                    child: Text(
                      'सहमति रद्द करें (Revoke)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.emergencyLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('पर्ची देखें (Slip)'),
                    onPressed: () {
                      context.push('/booking/confirm');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.emergencyLight,
                      side: const BorderSide(color: AppColors.emergencyLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('रद्द करें'),
                    onPressed: () => _cancelAppointment(appt),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isCancelled
                        ? 'अपॉइंटमेंट रद्द की गई (Appointment Cancelled)'
                        : 'सत्र समाप्त (Consultation completed)',
                    style: AppTextStyles.caption.copyWith(
                      color: isCancelled ? AppColors.emergencyLight : (isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
                      fontWeight: isCancelled ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.history_edu, size: 16),
                  label: const Text('पर्चा देखें (Rx)'),
                  onPressed: () {
                    context.push('/documents');
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
