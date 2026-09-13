import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class EmergencyScreen extends StatefulWidget {
  final String flagCode;
  const EmergencyScreen({super.key, this.flagCode = "CHEST_PAIN_DYSPNEA"});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  int _countdown = 10;
  Timer? _timer;
  bool _alertSent = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        t.cancel();
        setState(() {
          _countdown = 0;
          _alertSent = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _call108() async {
    final uri = Uri.parse("tel:108");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('आपातकालीन स्क्रीन बंद करें?'),
              content: const Text('क्या आप वाकई सुरक्षित हैं और इस आपातकालीन सहायता स्क्रीन से बाहर जाना चाहते हैं?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('नहीं, रुकें')),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/home');
                  },
                  child: const Text('हाँ, बाहर जाएं', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF4F3),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFBF4F3),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.emergencyLight),
            onPressed: () => context.go('/home'),
          ),
          title: const Text(
            '🚨 आपातकालीन सहायता (Emergency)',
            style: TextStyle(color: AppColors.emergencyLight, fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Warning Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.emergencyLight.withValues(alpha: 0.4), width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 42)),
                      const SizedBox(height: 8),
                      Text(
                        'गंभीर लक्षण पहचाने गए!\nCritical Symptoms Detected',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.emergencyLight,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _alertSent
                            ? '✓ अस्पताल इमरजेंसी डेस्क और आपके परिजनों को सतर्क कर दिया गया है'
                            : '$_countdown सेकंड में अस्पताल डेस्क और परिजनों को स्वचालित अलर्ट भेजा जाएगा',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3 Big Emergency Buttons
                _buildActionCard(
                  emoji: '🚑',
                  title: '108 एम्बुलेंस को तुरंत कॉल करें',
                  subtitle: 'National Emergency Ambulance Service (Toll-Free)',
                  color: AppColors.emergencyLight,
                  onTap: _call108,
                ),
                const SizedBox(height: 12),

                _buildActionCard(
                  emoji: '👨‍👩‍👧',
                  title: 'परिवार को आपातकालीन चेतावनी SMS भेजें',
                  subtitle: 'सीता देवी (+91 98765-XXXXX) को आपकी लोकेशन भेजी जाएगी',
                  color: const Color(0xFFD97706),
                  onTap: () {
                    setState(() => _alertSent = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('परिजनों को SMS चेतावनी भेज दी गई!')),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _buildActionCard(
                  emoji: '🏥',
                  title: 'निकटतम इमरजेंसी वॉर्ड (AIIA Trauma Wing)',
                  subtitle: 'भूतल, कमरा नंबर 12 · दूरी: 40 मीटर',
                  color: AppColors.primaryLight,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('इमरजेंसी वॉर्ड दिशा-निर्देश खोले जा रहे हैं...')),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // First-Aid Accordion
                Text('प्राथमिक उपचार निर्देश (First-Aid Guide)', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                _buildFirstAidTile(
                  title: 'सीने में दर्द या सांस की तकलीफ़ होने पर:',
                  points: [
                    'तुरंत शांत होकर बैठ जाएं, लेटें नहीं।',
                    'तंग कपड़े ढीले करें और गहरी धीमी सांस लें।',
                    'अकेले चलने का प्रयास न करें, तुरंत सहारा लें।',
                  ],
                ),
                const SizedBox(height: 10),

                _buildFirstAidTile(
                  title: 'यदि चक्कर या बेहोशी महसूस हो:',
                  points: [
                    'पैरों को थोड़ा ऊंचा करके पीठ के बल लेट जाएं।',
                    'चेहरे पर ताजे पानी के छींटे मारें।',
                    'कुछ भी खाने या पीने की ज़बरदस्ती न करें।',
                  ],
                ),

                const SizedBox(height: 24),

                // Kiosk Attendant Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('कियोस्क अटेंडेंट को सूचना दे दी गई है, कृपया प्रतीक्षा करें।')),
                      );
                    },
                    icon: const Icon(Icons.support_agent, color: AppColors.primaryLight),
                    label: const Text('कियोस्क सहायक को बुलाएं (Call Hospital Attendant)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstAidTile({required String title, required List<String> points}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          ...points.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(p, style: const TextStyle(fontSize: 12, height: 1.3))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
