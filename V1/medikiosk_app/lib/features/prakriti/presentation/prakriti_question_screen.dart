import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_audio_button.dart';
import '../../../core/widgets/mk_progress_bar.dart';

class PrakritiQuestionScreen extends ConsumerStatefulWidget {
  const PrakritiQuestionScreen({super.key});

  @override
  ConsumerState<PrakritiQuestionScreen> createState() => _PrakritiQuestionScreenState();
}

class _PrakritiQuestionScreenState extends ConsumerState<PrakritiQuestionScreen> {
  int _currentIndex = 0;
  final Map<int, String> _answers = {};

  final List<Map<String, dynamic>> _questions = [
    {
      "id": "PRAK_01",
      "text_hi": "आपके शरीर की बनावट कैसी है?",
      "text_en": "What is your natural body frame?",
      "options": [
        {"key": "A", "label_hi": "पतला, हल्का, लंबा या छोटा", "label_en": "Thin, light, tall or petite", "dosha": "Vata"},
        {"key": "B", "label_hi": "मध्यम, सुडौल, संतुलित", "label_en": "Medium, proportionate", "dosha": "Pitta"},
        {"key": "C", "label_hi": "भारी, चौड़ा, मजबूत", "label_en": "Broad, heavy, sturdy", "dosha": "Kapha"},
      ]
    },
    {
      "id": "PRAK_02",
      "text_hi": "आपके वज़न का रुझान कैसा रहता है?",
      "text_en": "What is your body weight tendency?",
      "options": [
        {"key": "A", "label_hi": "वज़न बढ़ाना बहुत मुश्किल", "label_en": "Hard to gain weight", "dosha": "Vata"},
        {"key": "B", "label_hi": "आसानी से घटता-बढ़ता है", "label_en": "Can gain or lose easily", "dosha": "Pitta"},
        {"key": "C", "label_hi": "जल्दी बढ़ता है, घटाना कठिन", "label_en": "Gains easily, hard to lose", "dosha": "Kapha"},
      ]
    },
    {
      "id": "PRAK_03",
      "text_hi": "आपकी त्वचा कुदरती तौर पर कैसी है?",
      "text_en": "How is your skin naturally?",
      "options": [
        {"key": "A", "label_hi": "सूखी, खुरदरी, पतली", "label_en": "Dry, rough, thin", "dosha": "Vata"},
        {"key": "B", "label_hi": "गर्म, तैलीय, तिल या दाने", "label_en": "Warm, oily, sensitive/freckles", "dosha": "Pitta"},
        {"key": "C", "label_hi": "मोटी, चिकनी, नम व चमकदार", "label_en": "Thick, smooth, well-hydrated", "dosha": "Kapha"},
      ]
    },
    {
      "id": "PRAK_04",
      "text_hi": "आपकी भूख और पाचन शक्ति कैसी है?",
      "text_en": "How is your appetite and digestion?",
      "options": [
        {"key": "A", "label_hi": "अनियमित — कभी बहुत भूख, कभी नहीं", "label_en": "Irregular — variable appetite", "dosha": "Vata"},
        {"key": "B", "label_hi": "तेज़ भूख — खाना छूटने पर गुस्सा/सिरदर्द", "label_en": "Sharp — cannot skip meals", "dosha": "Pitta"},
        {"key": "C", "label_hi": "धीमी पर स्थिर — बिना खाए भी रह सकते हैं", "label_en": "Slow but steady", "dosha": "Kapha"},
      ]
    },
    {
      "id": "PRAK_05",
      "text_hi": "आपको नींद कैसी आती है?",
      "text_en": "How are your sleep patterns?",
      "options": [
        {"key": "A", "label_hi": "हल्की, बीच में खुलती है, सपने ज़्यादा", "label_en": "Light, interrupted sleep", "dosha": "Vata"},
        {"key": "B", "label_hi": "मध्यम (6-7 घंटे), ताज़ा उठते हैं", "label_en": "Moderate, sound sleep", "dosha": "Pitta"},
        {"key": "C", "label_hi": "गहरी, भारी, सुबह उठने में सुस्ती", "label_en": "Heavy, deep, slow to wake", "dosha": "Kapha"},
      ]
    },
    {
      "id": "PRAK_06",
      "text_hi": "मौसम का आप पर क्या असर होता है?",
      "text_en": "How do you react to weather changes?",
      "options": [
        {"key": "A", "label_hi": "ठंड और हवा सहन नहीं होती", "label_en": "Averse to cold and wind", "dosha": "Vata"},
        {"key": "B", "label_hi": "गर्मी और धूप सहन नहीं होती", "label_en": "Averse to hot sun and heat", "dosha": "Pitta"},
        {"key": "C", "label_hi": "सर्दी-जुकाम और नमी से परेशानी", "label_en": "Averse to damp/humid cold", "dosha": "Kapha"},
      ]
    },
  ];

  void _selectOption(String key) {
    setState(() {
      _answers[_currentIndex] = key;
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() => _currentIndex++);
      } else {
        // Assessment complete -> navigate to results
        context.push('/prakriti/result');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentQ = _questions[_currentIndex];
    final selectedKey = _answers[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentIndex > 0) {
              setState(() => _currentIndex--);
            } else {
              context.pop();
            }
          },
        ),
        title: Text('प्रश्न ${_currentIndex + 1} of ${_questions.length}'),
        actions: [
          MkAudioButton(textToRead: currentQ["text_hi"]),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MkProgressBar(progress: progress, label: "प्रगति (${((progress) * 100).toInt()}%)"),
              const SizedBox(height: 24),

              // Question text
              Text(
                currentQ["text_hi"],
                style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold, height: 1.3),
              ),
              const SizedBox(height: 6),
              Text(
                currentQ["text_en"],
                style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
              ),
              const SizedBox(height: 32),

              // Options
              ...List.generate(currentQ["options"].length, (idx) {
                final opt = currentQ["options"][idx];
                final isSelected = selectedKey == opt["key"];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: InkWell(
                    onTap: () => _selectOption(opt["key"]),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.ayushLight.withValues(alpha: 0.15)
                            : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.ayushLight : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.ayushLight : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? AppColors.ayushLight : AppColors.onSurfaceVariantLight,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                opt["key"],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : AppColors.onSurfaceVariantLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt["label_hi"],
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  opt["label_en"],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),

              // Voice helper footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.mic, color: AppColors.ayushLight),
                        SizedBox(width: 8),
                        Text('बोलकर चुनें (A, B या C कहें)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: () {
                        if (_currentIndex < _questions.length - 1) {
                          setState(() => _currentIndex++);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
