import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_donut_chart.dart';
import '../../../core/widgets/mk_button.dart';
import '../../../data/providers/theme_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/storage_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _audioGuidanceEnabled = true;
  AppEnvironment _activeEnv = AppEnvironment.beta;
  String _activeUrl = '';
  bool _isPinging = false;
  String? _pingMessage;
  bool? _pingSuccess;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEnvSettings();
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _loadEnvSettings() {
    final storage = ref.read(storageServiceProvider);
    setState(() {
      _activeEnv = storage.getEnvironment();
      _activeUrl = ApiClient().baseUrl;
      _urlController.text = storage.getVercelUrl();
    });
  }

  void _switchEnvironment(AppEnvironment newEnv) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setEnvironment(newEnv);
    final targetUrl = storage.getActiveApiUrl();
    ApiClient().updateBaseUrl(targetUrl);
    setState(() {
      _activeEnv = newEnv;
      _activeUrl = ApiClient().baseUrl;
      _pingMessage = null;
      _pingSuccess = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newEnv == AppEnvironment.normal
                ? '☁️ सामान्य मोड (Normal) सक्रिय: Vercel + Supabase'
                : '🧪 बीटा मोड (Beta) सक्रिय: स्थानीय सर्वर + SQLite',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _testServerConnection() async {
    setState(() {
      _isPinging = true;
      _pingMessage = null;
      _pingSuccess = null;
    });

    final res = await ApiClient().testConnection();
    if (!mounted) return;

    setState(() {
      _isPinging = false;
      _pingSuccess = res['success'] == true;
      if (_pingSuccess == true) {
        final data = res['data'] is Map ? res['data'] : {};
        final dbType = data['database_type'] ?? 'ok';
        final envMode = data['env_mode'] ?? 'unknown';
        final latency = res['latency_ms'];
        _pingMessage = 'कनेक्शन सफल ($latency ms) • DB: $dbType • Env: $envMode';
      } else {
        final latency = res['latency_ms'];
        _pingMessage = 'कनेक्शन विफल ($latency ms) • सर्वर से उत्तर नहीं मिला';
      }
    });
  }

  void _showEditVercelUrlDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vercel सर्वर URL सेट करें'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'अपना डिप्लॉय किया हुआ Vercel बैकएंड URL दर्ज करें:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'https://your-app.vercel.app/api/v1',
                labelText: 'Backend URL',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('रद्द करें'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = _urlController.text.trim();
              if (newUrl.isNotEmpty) {
                final storage = ref.read(storageServiceProvider);
                await storage.setVercelUrl(newUrl);
                if (_activeEnv == AppEnvironment.normal) {
                  ApiClient().updateBaseUrl(newUrl);
                }
                setState(() {
                  _activeUrl = ApiClient().baseUrl;
                });
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('सुरक्षित करें'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('स्वास्थ्य डेटा डाउनलोड (DPDP Export)'),
        content: const Text(
          'DPDP Act 2023 के तहत आपका संपूर्ण नैदानिक इतिहास, पर्चियां, लैब रिकॉर्ड्स और सहमति लॉग एनक्रिप्टेड JSON/PDF फॉर्मेट में तैयार किया गया है।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('बंद करें (Close)'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('स्वास्थ्य डेटा फ़ाइल (medikiosk_health_record.json) डाउनलोड हो गई।'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('डाउनलोड करें (Save)'),
          ),
        ],
      ),
    );
  }

  void _requestErasure() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('डेटा मिटाने का अनुरोध (Right to Erasure)'),
        content: const Text(
          'क्या आप MediKiosk से अपना समस्त व्यक्तिगत व नैदानिक डेटा स्थायी रूप से मिटाने का अनुरोध दर्ज करना चाहते हैं?\n\n(अनुरोध 72 घंटे में नोडल अधिकारी द्वारा प्रोसेस किया जाएगा।)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('रद्द करें (Cancel)'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyLight),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('डेटा मिटाने का अनुरोध आईडी #REQ-8821 दर्ज कर लिया गया है।'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('अनुरोध भेजें', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('लॉगआउट (Sign Out)'),
        content: const Text('क्या आप MediKiosk सत्र से बाहर निकलना चाहते हैं?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('रद्द करें (Cancel)'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyLight),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            child: const Text('लॉगआउट', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('प्रोफ़ाइल व सेटिंग्स (Profile)'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient Identity Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                          child: Text(
                            'RK',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'रमेश कुमार (Ramesh Kumar)',
                                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '+91 98765 43210  •  41 वर्ष, पुरुष',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.ayushDark.withValues(alpha: 0.15)
                                      : AppColors.ayushLight.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: isDark ? AppColors.ayushDark : AppColors.ayushLight,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ABHA: 91-2345-6789-0123',
                                      style: AppTextStyles.caption.copyWith(
                                        color: isDark ? AppColors.ayushDark : AppColors.ayushLight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // AYUSH Prakriti Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.ayushDark.withValues(alpha: 0.3) : AppColors.ayushLight.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.spa_outlined,
                                color: isDark ? AppColors.ayushDark : AppColors.ayushLight,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'आयुष प्रकृति विवरण',
                                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.ayushDark.withValues(alpha: 0.2)
                                : AppColors.ayushLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'वात-पित्त (Vata-Pitta)',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.ayushDark : AppColors.ayushLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const MkDonutChart(vata: 45, pitta: 35, kapha: 20, showLegend: false),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDoshaBadge('वात (Vata)', '45%', Colors.blue),
                        _buildDoshaBadge('पित्त (Pitta)', '35%', Colors.redAccent),
                        _buildDoshaBadge('कफ (Kapha)', '20%', Colors.green),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => context.push('/prakriti'),
                            child: const Text('पुनः परीक्षण (Re-test)'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => context.push('/prakriti/delta'),
                            child: const Text('डेल्टा चेक (<30s)'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Emergency Contacts Section
              Text(
                'आपातकालीन संपर्क (Emergency Contacts)',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildContactTile(
                name: 'सुनीता कुमार (Sunita Kumar)',
                relation: 'पत्नी (Spouse) • प्राथमिक संपर्क',
                phone: '+91 98765 43211',
                hasConsent: true,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildContactTile(
                name: 'डॉ. पी. के. वर्मा (Dr. P.K. Verma)',
                relation: 'फैमिली फिजिशियन (Primary Doctor)',
                phone: '+91 98765 43212',
                hasConsent: true,
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // DPDP Act Compliance & Data Governance
              Text(
                'डेटा अधिकार व गोपनीयता (DPDP Act 2023)',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildActionItem(
                      icon: Icons.file_download_outlined,
                      title: 'मेरा स्वास्थ्य डेटा डाउनलोड करें (Export Data)',
                      subtitle: 'एनक्रिप्टेड JSON / PDF रिकॉर्ड प्राप्त करें',
                      onTap: _exportData,
                      isDark: isDark,
                    ),
                    Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    _buildActionItem(
                      icon: Icons.security_outlined,
                      title: 'सक्रिय अनुमतियां देखें (Active Consents)',
                      subtitle: 'देखें किस अस्पताल/डॉक्टर के पास डेटा एक्सेस है',
                      onTap: () => context.push('/appointments'),
                      isDark: isDark,
                    ),
                    Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    _buildActionItem(
                      icon: Icons.delete_forever_outlined,
                      title: 'डेटा मिटाने का अधिकार (Right to Erasure)',
                      subtitle: 'सिस्टम से स्थायी रूप से डेटा हटाने का अनुरोध करें',
                      titleColor: AppColors.emergencyLight,
                      iconColor: AppColors.emergencyLight,
                      onTap: _requestErasure,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Server & Database Environment (Beta vs Normal)
              Text(
                'सर्वर व डेटाबेस चयन (Server & Database Environment)',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _switchEnvironment(AppEnvironment.beta),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: _activeEnv == AppEnvironment.beta
                                    ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '🧪 Beta (Local SQLite)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: _activeEnv == AppEnvironment.beta
                                      ? (isDark ? Colors.black : Colors.white)
                                      : (isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _switchEnvironment(AppEnvironment.normal),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: _activeEnv == AppEnvironment.normal
                                    ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '☁️ Normal (Vercel)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: _activeEnv == AppEnvironment.normal
                                      ? (isDark ? Colors.black : Colors.white)
                                      : (isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _activeEnv == AppEnvironment.beta
                          ? '• स्थानीय सर्वर (127.0.0.1:8000) व लोकल SQLite डेटाबेस का उपयोग हो रहा है।'
                          : '• Vercel क्लाउड बैकएंड व Supabase Postgres/Storage का उपयोग हो रहा है।',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.link, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _activeUrl.isEmpty ? ApiClient().baseUrl : _activeUrl,
                              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_activeEnv == AppEnvironment.normal)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              tooltip: 'Edit Vercel URL',
                              onPressed: _showEditVercelUrlDialog,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isPinging ? null : _testServerConnection,
                            icon: _isPinging
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.wifi_tethering, size: 16),
                            label: Text(_isPinging ? 'जांच जारी...' : 'चेक कनेक्शन (Ping)'),
                          ),
                        ),
                      ],
                    ),
                    if (_pingMessage != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _pingSuccess == true
                              ? AppColors.ayushLight.withValues(alpha: 0.15)
                              : AppColors.emergencyLight.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _pingSuccess == true ? Icons.check_circle : Icons.error_outline,
                              color: _pingSuccess == true ? AppColors.ayushLight : AppColors.emergencyLight,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _pingMessage!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _pingSuccess == true ? AppColors.ayushLight : AppColors.emergencyLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Accessibility & Preferences
              Text(
                'सुलभता व प्राथमिकताएं (Accessibility)',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('आवाज मार्गदर्शन (Audio Guidance / TTS)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text('प्रश्नों व निर्देशों को बोलकर सुनाएं', style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _audioGuidanceEnabled,
                            onChanged: (v) => setState(() => _audioGuidanceEnabled = v),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('डार्क मोड (Dark Theme / Charcoal)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text('मिल्क-व्हाइट व चारकोल ब्लैक थीम बदलें', style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                              ],
                            ),
                          ),
                          Switch(
                            value: isDark,
                            onChanged: (v) {
                              ref.read(themeModeProvider.notifier).state =
                                  isDark ? ThemeMode.light : ThemeMode.dark;
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    InkWell(
                      onTap: () => context.push('/language'),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('भाषा बदलें (Change Language)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text('हिंदी (Hindi) / English', style: AppTextStyles.caption.copyWith(color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
                                ],
                              ),
                            ),
                            const Icon(Icons.language),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Logout Button
              MkButton(
                text: 'लॉगआउट (Sign Out)',
                variant: MkButtonVariant.outline,
                icon: Icons.logout,
                onPressed: _confirmLogout,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'MediKiosk v2.0 • MoA & AIIA New Delhi',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoshaBadge(String label, String pct, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 2),
        Text(pct, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildContactTile({
    required String name,
    required String relation,
    required String phone,
    required bool hasConsent,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isDark ? AppColors.primaryLight : AppColors.primaryDark,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleMedium.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(
                  '$relation • $phone',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.ayushDark.withValues(alpha: 0.15) : AppColors.ayushLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'पूर्व-सहमति ✓',
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.ayushDark : AppColors.ayushLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    Color? iconColor,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? (isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? (isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}
