import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_audio_button.dart';
import '../../../core/widgets/mk_progress_bar.dart';
import '../../../data/repositories/chat_repository.dart';
import 'widgets/complaint_grid.dart';
import 'widgets/ayush_context_chip.dart';
import 'widgets/voice_overlay.dart';
import 'widgets/chat_question_area.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String mode; // "general" | "ayush"
  const ChatScreen({super.key, this.mode = "ayush"});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late String _currentMode;
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  final ChatRepository _chatRepo = ChatRepository();

  String? _sessionId;
  String? _currentComplaintKey;
  String? _currentComplaintLabel;
  bool _isFirstTurn = true;
  bool _isLoading = false;
  int _questionIndex = 0;
  int _totalQuestions = 6;
  Map<String, dynamic>? _currentQuestion;

  // Complaint-grounded offline fallback question trees
  static final Map<String, List<Map<String, dynamic>>> _fallbackQuestions = {
    "fever": [
      {
        "id": "HPI_FEVER_ONSET",
        "text_hi": "यह बुखार आपको कब से महसूस हो रहा है?",
        "text_en": "Since when have you been feeling this fever?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "आज से ही शुरू हुआ (Since today)", "label_en": "Since today", "icon": "calendar"},
          {"key": "B", "label_hi": "पिछले 2-3 दिनों से (Past 2-3 days)", "label_en": "For 2-3 days", "icon": "calendar"},
          {"key": "C", "label_hi": "लगभग 1 हफ्ते से (Past 1 week)", "label_en": "About 1 week", "icon": "calendar"},
          {"key": "D", "label_hi": "1 हफ्ते से अधिक समय से", "label_en": "More than 1 week", "icon": "calendar"},
        ]
      },
      {
        "id": "HPI_FEVER_PATTERN",
        "text_hi": "बुखार का स्वभाव कैसा है? क्या यह पूरे दिन रहता है या किसी खास समय बढ़ता है?",
        "text_en": "What is the pattern of the fever? Is it continuous or does it spike at a specific time?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "पूरे दिन लगातार तेज़ रहता है", "label_en": "Continuous high fever", "icon": "clock"},
          {"key": "B", "label_hi": "शाम या रात को बढ़ता है", "label_en": "Evening spike", "icon": "moon"},
          {"key": "C", "label_hi": "सुबह के समय तेज़ होता है", "label_en": "Morning spike", "icon": "sun"},
          {"key": "D", "label_hi": "रुक-रुक कर आता है", "label_en": "Intermittent fever", "icon": "clock"},
        ]
      },
      {
        "id": "HPI_FEVER_ASSOCIATED",
        "text_hi": "बुखार के साथ इनमें से कौन से अन्य लक्षण महसूस हो रहे हैं?",
        "text_en": "Which of these associated symptoms are you experiencing along with fever?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "ठंड और कंपकंपी महसूस होना", "label_en": "With chills and rigors", "icon": "chills"},
          {"key": "B", "label_hi": "बहुत पसीना आना (Sweating)", "label_en": "Profuse sweating", "icon": "sweat"},
          {"key": "C", "label_hi": "तेज़ सिरदर्द व बदन दर्द", "label_en": "Severe headache & body ache", "icon": "pain"},
          {"key": "D", "label_hi": "खांसी, ज़ुकाम व गले में खराश", "label_en": "Cough & cold", "icon": "breath"},
        ]
      },
      {
        "id": "HPI_SEVERITY",
        "text_hi": "शारीरिक बेचैनी और कमज़ोरी 0 से 10 के पैमाने पर कितनी है?",
        "text_en": "Rate your physical distress and weakness from 0 to 10",
        "input_type": "slider",
        "options": []
      },
      {
        "id": "AYUSH_SWEDA",
        "text_hi": "आयुष परीक्षण: क्या बुखार के समय पसीना (स्वेद) आता है?",
        "text_en": "AYUSH Assessment: Do you experience sweating (Sweda) during fever?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "त्वचा बिल्कुल सूखी है, पसीना नहीं आता (Dry skin / Anasweda)", "label_en": "Dry skin"},
          {"key": "B", "label_hi": "पसीना आने पर बुखार उतरता है (Sweating relieves fever)", "label_en": "Sweating relieves"},
          {"key": "C", "label_hi": "रात में बहुत ज़्यादा पसीना आता है (Night sweats)", "label_en": "Night sweats"},
        ]
      },
      {
        "id": "AYUSH_AGNI",
        "text_hi": "आपकी भूख और पाचन शक्ति (अग्नि) कैसी है?",
        "text_en": "How is your appetite and digestion (Agni)?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "भूख बिल्कुल नहीं है / अरुचि (No appetite / Aruchi)", "label_en": "No appetite"},
          {"key": "B", "label_hi": "मुंह का स्वाद कड़वा या फीका (Bitter mouth taste)", "label_en": "Bitter taste"},
          {"key": "C", "label_hi": "सामान्य भूख लग रही है (Normal appetite)", "label_en": "Normal appetite"},
        ]
      },
    ],
    "headache": [
      {
        "id": "HPI_HEADACHE_SITE",
        "text_hi": "सिरदर्द मुख्य रूप से किस हिस्से में महसूस हो रहा है?",
        "text_en": "Where exactly is the headache located?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "माथे और आंखों के ऊपर (Frontal / Forehead)", "label_en": "Frontal forehead"},
          {"key": "B", "label_hi": "केवल एक तरफ - आधा सीसी (One-sided / Migraine)", "label_en": "One-sided migraine"},
          {"key": "C", "label_hi": "सिर के पीछे व गर्दन में (Back of head / Neck)", "label_en": "Back of head"},
          {"key": "D", "label_hi": "पूरे सिर में भारीपन (All over head / Tension)", "label_en": "Tension headache"},
        ]
      },
      {
        "id": "HPI_HEADACHE_ONSET",
        "text_hi": "यह सिरदर्द कब से है और कैसा महसूस होता है?",
        "text_en": "How long have you had this headache and what does it feel like?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "नसें फड़कने जैसा धक-धक दर्द (Throbbing / Pulsating)", "label_en": "Throbbing"},
          {"key": "B", "label_hi": "सिर बंधा हुआ या भारी लगना (Heavy / Tight band)", "label_en": "Tight band"},
          {"key": "C", "label_hi": "सुई चुभने जैसा तेज़ दर्द (Sharp pricking)", "label_en": "Sharp pricking"},
        ]
      },
      {
        "id": "HPI_HEADACHE_TRIGGERS",
        "text_hi": "क्या इनमें से किसी कारण से सिरदर्द बढ़ता है?",
        "text_en": "What triggers or worsens your headache?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "तेज़ रोशनी, आवाज़ या स्क्रीन देखने से (Light / Sound)", "label_en": "Light & sound"},
          {"key": "B", "label_hi": "कम नींद या मानसिक तनाव से (Lack of sleep / Stress)", "label_en": "Stress / Lack of sleep"},
          {"key": "C", "label_hi": "भूखे रहने या धूप में जाने से (Hunger / Sunlight)", "label_en": "Hunger / Sunlight"},
        ]
      },
      {
        "id": "HPI_SEVERITY",
        "text_hi": "सिरदर्द की तीव्रता 0 से 10 के पैमाने पर कितनी है?",
        "text_en": "Rate headache severity from 0 to 10",
        "input_type": "slider",
        "options": []
      },
    ],
    "abdominal_pain": [
      {
        "id": "HPI_ABDO_SITE",
        "text_hi": "यह दर्द पेट के किस हिस्से में सबसे ज़्यादा महसूस होता है?",
        "text_en": "Where in your abdomen is the discomfort located?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "ऊपरी पेट (छाती के ठीक नीचे / Epigastric)", "label_en": "Upper abdomen"},
          {"key": "B", "label_hi": "निचला पेट या नाभि के पास (Lower abdomen / Umbilical)", "label_en": "Lower abdomen"},
          {"key": "C", "label_hi": "दाहिनी तरफ पसलियों के नीचे (Right hypochondrium)", "label_en": "Right upper abdomen"},
          {"key": "D", "label_hi": "पूरे पेट में मरोड़ या भारीपन (Diffuse cramp / Bloat)", "label_en": "Diffuse cramps"},
        ]
      },
      {
        "id": "HPI_ABDO_RELATION",
        "text_hi": "दर्द का भोजन से क्या संबंध है?",
        "text_en": "How is the pain related to food intake?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "खाना खाने के तुरंत बाद बढ़ता है (Worse post-meals)", "label_en": "Worse after meals"},
          {"key": "B", "label_hi": "खाली पेट जलन होती है, खाने से आराम मिलता है (Relieved by food)", "label_en": "Relieved by food"},
          {"key": "C", "label_hi": "मसालेदार या खट्टा खाने से बढ़ता है (Worse with spicy food)", "label_en": "Worse with spicy food"},
        ]
      },
      {
        "id": "HPI_SEVERITY",
        "text_hi": "पेट दर्द की तीव्रता 0 से 10 के पैमाने पर कितनी है?",
        "text_en": "Rate abdominal pain severity from 0 to 10",
        "input_type": "slider",
        "options": []
      },
      {
        "id": "AYUSH_AGNI",
        "text_hi": "आपकी पाचन शक्ति (अग्नि) और भूख कैसी है?",
        "text_en": "How is your digestive fire (Agni)?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "सीने व गले में जलन / खट्टी डकारें (Tikshnagni / Acidity)", "label_en": "Acidity / Heartburn"},
          {"key": "B", "label_hi": "भूख न लगना / पेट फूला रहना (Mandagni / Bloating)", "label_en": "Bloating / Sluggish"},
          {"key": "C", "label_hi": "सामान्य पाचन (Normal digestion)", "label_en": "Normal"},
        ]
      },
    ],
    "cough": [
      {
        "id": "HPI_COUGH_TYPE",
        "text_hi": "खांसी का स्वरूप कैसा है?",
        "text_en": "What is the character of your cough?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "सूखी खांसी, गले में खुजली के साथ (Dry irritant cough)", "label_en": "Dry cough"},
          {"key": "B", "label_hi": "बलगम / कफ वाली खांसी (Productive with phlegm)", "label_en": "Wet / phlegm cough"},
          {"key": "C", "label_hi": "रात में या लेटने पर खांसी के दौरे (Night worsening)", "label_en": "Night bouts"},
        ]
      },
      {
        "id": "HPI_COUGH_DURATION",
        "text_hi": "यह खांसी कितने दिनों से चल रही है?",
        "text_en": "How long have you been coughing?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "3-5 दिनों से (Recent, 3-5 days)", "label_en": "3-5 days"},
          {"key": "B", "label_hi": "1 से 2 हफ्तों से (1-2 weeks)", "label_en": "1-2 weeks"},
          {"key": "C", "label_hi": "3 हफ्तों या महीने से अधिक (Chronic >3 weeks)", "label_en": ">3 weeks"},
        ]
      },
      {
        "id": "HPI_COUGH_BREATH",
        "text_hi": "क्या सांस लेने में परेशानी या छाती से सीटी जैसी आवाज़ (Wheezing) आती है?",
        "text_en": "Do you experience breathlessness or wheezing?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "नहीं, सांस सामान्य है (Normal breathing)", "label_en": "Normal breathing"},
          {"key": "B", "label_hi": "चलने या सीढ़ी चढ़ने पर सांस फूलती है (On exertion)", "label_en": "Exertional dyspnea"},
          {"key": "C", "label_hi": "सीने से सीटी जैसी आवाज़ आती है (Wheezing sound)", "label_en": "Wheezing"},
        ]
      },
      {
        "id": "HPI_SEVERITY",
        "text_hi": "खांसी से होने वाली तकलीफ़ 0 से 10 के पैमाने पर कितनी है?",
        "text_en": "Rate cough severity from 0 to 10",
        "input_type": "slider",
        "options": []
      },
    ],
    "joint_pain": [
      {
        "id": "HPI_JOINT_SITE",
        "text_hi": "दर्द या सूजन मुख्य रूप से किस जोड़ में है?",
        "text_en": "Which joints are primarily affected by pain or swelling?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "घुटनों में (Knees / Janu Sandhi)", "label_en": "Knees"},
          {"key": "B", "label_hi": "हाथ-पैरों की उंगलियों में (Fingers / Toes)", "label_en": "Small joints"},
          {"key": "C", "label_hi": "कमर या कूल्हे में (Lower back / Hip)", "label_en": "Lower back"},
          {"key": "D", "label_hi": "शरीर के कई जोड़ों में एक साथ (Multiple joints)", "label_en": "Multiple joints"},
        ]
      },
      {
        "id": "HPI_JOINT_STIFFNESS",
        "text_hi": "क्या सुबह सोकर उठने पर जोड़ों में अकड़न (जकड़ाहट) महसूस होती है?",
        "text_en": "Do you feel joint stiffness upon waking up in the morning?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "हाँ, 30 मिनट से अधिक समय तक (Morning stiffness >30m)", "label_en": ">30 min stiffness"},
          {"key": "B", "label_hi": "हाँ, पर 5-10 मिनट में खुल जाती है (Mild)", "label_en": "Brief stiffness"},
          {"key": "C", "label_hi": "अकड़न नहीं होती, केवल दर्द रहता है (Pain without stiffness)", "label_en": "No stiffness"},
        ]
      },
      {
        "id": "HPI_SEVERITY",
        "text_hi": "जोड़ों के दर्द की तीव्रता 0 से 10 के पैमाने पर कितनी है?",
        "text_en": "Rate joint pain severity from 0 to 10",
        "input_type": "slider",
        "options": []
      },
    ],
    "default": [
      {
        "id": "HPI_ONSET",
        "text_hi": "यह समस्या कब और कैसे शुरू हुई?",
        "text_en": "When and how did this issue begin?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "अचानक, 1-2 दिन पहले (Suddenly, past 1-2 days)", "label_en": "Acute 1-2 days"},
          {"key": "B", "label_hi": "धीरे-धीरे, लगभग 1 हफ्ते से (Past 1 week)", "label_en": "Past 1 week"},
          {"key": "C", "label_hi": "लंबे समय से, 1 महीने से अधिक (Chronic, >1 month)", "label_en": "Chronic >1 month"},
        ]
      },
      {
        "id": "HPI_SEVERITY",
        "text_hi": "तकलीफ की तीव्रता 0 से 10 के पैमाने पर कितनी है?",
        "text_en": "How severe is the discomfort on a scale of 0 to 10?",
        "input_type": "slider",
        "options": []
      },
      {
        "id": "AYUSH_AGNI",
        "text_hi": "आयुष मूल्यांकन: आपकी भूख और पाचन शक्ति (अग्नि) कैसी है?",
        "text_en": "AYUSH Assessment: How is your appetite and digestion (Agni)?",
        "input_type": "mcq",
        "options": [
          {"key": "A", "label_hi": "सामान्य व संतुलित भूख (Normal / Samagni)", "label_en": "Normal"},
          {"key": "B", "label_hi": "भूख कम लगना / भारीपन (Sluggish / Mandagni)", "label_en": "Sluggish"},
          {"key": "C", "label_hi": "तेज़ भूख व जलन (Excessive / Tikshnagni)", "label_en": "Sharp acidity"},
        ]
      },
    ]
  };

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
    _messages.add({
      "sender": "system",
      "text": "नमस्ते! मैं मेडीकियोस्क AI सहायक हूँ। डॉक्टर के परामर्श से पूर्व आपकी स्वास्थ्य जानकारी तैयार करने में मदद करूँगा।\n\nआज आपकी मुख्य तकलीफ़ क्या है?",
      "isInitial": true,
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _mapComplaintToKey(String rawKey) {
    final k = rawKey.toLowerCase();
    if (k.contains("fever") || k.contains("bukhar") || k.contains("बुखार") || k.contains("jwar")) {
      return "fever";
    }
    if (k.contains("head") || k.contains("sir") || k.contains("sar") || k.contains("सिर")) {
      return "headache";
    }
    if (k.contains("abdom") || k.contains("pet") || k.contains("पेट")) {
      return "abdominal_pain";
    }
    if (k.contains("cough") || k.contains("khansi") || k.contains("खांसी") || k.contains("cold") || k.contains("jukam")) {
      return "cough";
    }
    if (k.contains("joint") || k.contains("jod") || k.contains("जोड़ों") || k.contains("knee") || k.contains("ghutn")) {
      return "joint_pain";
    }
    if (k.contains("gas") || k.contains("apach") || k.contains("अपच") || k.contains("indigest") || k.contains("acidity")) {
      return "indigestion";
    }
    if (k.contains("skin") || k.contains("rash") || k.contains("दाने") || k.contains("khujli")) {
      return "skin_rash";
    }
    return "default";
  }

  Future<void> _handleComplaintSelect(Map<String, String> complaint) async {
    // Red flag emergency triage check
    if (complaint["key"] == "chest_pain") {
      context.push('/emergency');
      return;
    }

    final complaintLabel = complaint["label_hi"] ?? complaint["label"] ?? "बुखार (Fever)";
    final complaintKey = _mapComplaintToKey(complaint["key"] ?? complaintLabel);

    setState(() {
      _currentComplaintKey = complaintKey;
      _currentComplaintLabel = complaintLabel;
      _isFirstTurn = false;
      _isLoading = true;
      _messages.add({
        "sender": "patient",
        "text": complaintLabel,
      });
    });
    _scrollToBottom();

    // Call backend API
    final sessionData = await _chatRepo.createSession(
      mode: _currentMode,
      complaint: complaintLabel,
      language: "hi",
    );

    if (!mounted) return;

    if (sessionData != null && sessionData["first_question"] != null) {
      final q = sessionData["first_question"] as Map<String, dynamic>;
      final sId = sessionData["session_id"] as String?;
      final prog = q["progress"] as Map<String, dynamic>?;

      setState(() {
        _sessionId = sId;
        _currentQuestion = q;
        _questionIndex = (prog?["done"] as int? ?? 1) - 1;
        _totalQuestions = prog?["total"] as int? ?? 6;
        _isLoading = false;
        _messages.add({
          "sender": "system",
          "question": q,
        });
      });
    } else {
      // Robust offline fallback strictly grounded on complaint
      final branch = _fallbackQuestions[complaintKey] ?? _fallbackQuestions["default"]!;
      final fallbackQ = branch[0];

      setState(() {
        _currentQuestion = fallbackQ;
        _questionIndex = 0;
        _totalQuestions = branch.length;
        _isLoading = false;
        _messages.add({
          "sender": "system",
          "question": fallbackQ,
        });
      });
    }
    _scrollToBottom();
  }

  Future<void> _handleAnswer(Map<String, dynamic> answer) async {
    final answerText = answer["label_hi"] ?? answer["label"] ?? answer["text"] ?? answer.toString();

    // Check emergency keywords in free text
    final lowerAns = answerText.toLowerCase();
    if (lowerAns.contains("chest pain") || lowerAns.contains("seene mein dard") || lowerAns.contains("सीने में दर्द")) {
      context.push('/emergency');
      return;
    }

    final currentQ = _currentQuestion;
    final currentQId = currentQ?["id"] ?? "Q_STEP_$_questionIndex";
    final currentInputType = currentQ?["input_type"] ?? currentQ?["input"] ?? "mcq";

    setState(() {
      _messages.add({
        "sender": "patient",
        "text": answerText,
      });
      _isLoading = true;
    });
    _scrollToBottom();

    // Call backend API if session exists
    if (_sessionId != null) {
      final res = await _chatRepo.submitAnswer(
        sessionId: _sessionId!,
        questionId: currentQId,
        inputType: currentInputType,
        answer: answer,
        sessionLang: "hi",
      );

      if (!mounted) return;

      if (res != null) {
        final resType = res["type"];
        if (resType == "red_flag") {
          context.push('/emergency');
          return;
        }

        if (resType == "complete" || res["session_status"] == "submitted") {
          setState(() {
            _isLoading = false;
            _messages.add({
              "sender": "system",
              "text": "धन्यवाद! आपका संपूर्ण क्लिनिकल इतिहास और आयुष दशाविध प्रोफाइल सफलतापूर्वक तैयार हो गया है। डॉक्टर शर्मा के कंसोल पर सारांश सुरक्षित रूप से भेज दिया गया है।",
              "isComplete": true,
            });
          });
          _scrollToBottom();
          return;
        }

        if (res["question"] != null) {
          final nextQ = res["question"] as Map<String, dynamic>;
          final prog = nextQ["progress"] as Map<String, dynamic>?;

          setState(() {
            _currentQuestion = nextQ;
            _questionIndex = (prog?["done"] as int? ?? (_questionIndex + 2)) - 1;
            _totalQuestions = prog?["total"] as int? ?? 6;
            _isLoading = false;
            _messages.add({
              "sender": "system",
              "question": nextQ,
            });
          });
          _scrollToBottom();
          return;
        }
      }
    }

    // Offline / Fallback progression along complaint branch
    final branchKey = _currentComplaintKey ?? "default";
    final branch = _fallbackQuestions[branchKey] ?? _fallbackQuestions["default"]!;
    final nextIdx = _questionIndex + 1;

    if (nextIdx < branch.length) {
      final nextQ = branch[nextIdx];
      setState(() {
        _questionIndex = nextIdx;
        _currentQuestion = nextQ;
        _isLoading = false;
        _messages.add({
          "sender": "system",
          "question": nextQ,
        });
      });
    } else {
      // Completed intake
      setState(() {
        _isLoading = false;
        _messages.add({
          "sender": "system",
          "text": "धन्यवाद! आपका संपूर्ण क्लिनिकल इतिहास और आयुष दशाविध प्रोफाइल सफलतापूर्वक तैयार हो गया है। डॉक्टर शर्मा के कंसोल पर सारांश सुरक्षित रूप से भेज दिया गया है।",
          "isComplete": true,
        });
      });
    }
    _scrollToBottom();
  }

  void _openVoiceOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VoiceOverlay(
        sessionId: _sessionId ?? 'demo_session',
        onTranscriptConfirmed: (transcript, engine) {
          _handleAnswer({"label": transcript, "text": transcript, "engine": engine});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = _totalQuestions > 0 ? _totalQuestions : 6;
    final current = (_questionIndex + 1).clamp(1, total);
    final progress = current / total;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            const Text('क्लिनिकल हिस्ट्री इनटेक', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              _currentComplaintLabel != null
                  ? "$_currentComplaintLabel • ${_currentMode == 'ayush' ? 'आयुष मोड' : 'सामान्य मोड'}"
                  : (_currentMode == "ayush" ? "आयुष दशाविध मोड (AYUSH Mode)" : "सामान्य मोड (General OPD)"),
              style: const TextStyle(fontSize: 11, color: AppColors.ayushLight),
            ),
          ],
        ),
        actions: [
          // Emergency Red Button
          IconButton(
            icon: const Icon(Icons.emergency_outlined, color: AppColors.emergencyLight),
            tooltip: 'आपातकालीन सहायता (Emergency)',
            onPressed: () => context.push('/emergency'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mode toggle & Progress bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildModeChip("general", "General"),
                      const SizedBox(width: 8),
                      _buildModeChip("ayush", "🌿 AYUSH"),
                    ],
                  ),
                  if (!_isFirstTurn)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.ayushLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'प्रश्न $current / $total',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.ayushLight),
                      ),
                    ),
                ],
              ),
            ),

            if (_currentMode == "ayush")
              const AyushContextChip(),

            if (!_isFirstTurn)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                child: MkProgressBar(progress: progress),
              ),

            // Message list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  // Loading typing indicator
                  if (index == _messages.length && _isLoading) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.ayushLight,
                            ),
                            child: const Center(
                              child: Text('🤖', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ayushLight),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'AI डॉक्टर प्रश्न तैयार कर रहा है...',
                                  style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariantLight),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final msg = _messages[index];
                  final isSystem = msg["sender"] == "system";

                  if (isSystem) {
                    final question = msg["question"] as Map<String, dynamic>?;
                    final text = question != null ? (question["text_hi"] ?? question["text"]) : msg["text"];
                    final isComplete = msg["isComplete"] == true;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryLight,
                                ),
                                child: const Center(
                                  child: Text('🤖', style: TextStyle(fontSize: 16)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        text ?? "",
                                        style: AppTextStyles.bodyLarge.copyWith(height: 1.4),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          MkAudioButton(textToRead: text ?? ""),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Initial Complaint Grid
                          if (msg["isInitial"] == true && _isFirstTurn)
                            ComplaintGrid(onComplaintSelected: _handleComplaintSelect),

                          // Question Answer Area (only for active question)
                          if (question != null && index == _messages.length - 1 && !_isLoading)
                            Padding(
                              padding: const EdgeInsets.only(left: 42.0),
                              child: ChatQuestionArea(
                                question: question,
                                onAnswer: _handleAnswer,
                              ),
                            ),

                          // Completion CTA button
                          if (isComplete)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0, left: 42.0),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.assignment_turned_in, size: 20),
                                label: const Text('सारांश देखें व होम पर जाएं (Go to Home) →'),
                                onPressed: () => context.go('/home'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.ayushLight,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  } else {
                    // Patient Message Bubble
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                            child: Text(
                              msg["text"] ?? "",
                              style: TextStyle(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),

            // Voice Mic Bottom Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _openVoiceOverlay,
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariantLight,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.mic, color: AppColors.ayushLight, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'बोलकर उत्तर दें (Tap to Speak)...',
                              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariantLight),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton.small(
                    heroTag: 'chat_mic_fab',
                    onPressed: _openVoiceOverlay,
                    backgroundColor: AppColors.ayushLight,
                    child: const Icon(Icons.mic, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip(String modeVal, String label) {
    final isSelected = _currentMode == modeVal;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: AppColors.ayushLight.withValues(alpha: 0.2),
      onSelected: (val) {
        if (val) setState(() => _currentMode = modeVal);
      },
    );
  }
}
