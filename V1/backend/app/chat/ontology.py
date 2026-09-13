import re
from typing import Dict, Any, List, Optional
from app.gemini.schemas import InterviewStep, Question, RedFlag

RED_FLAG_PATTERNS = [
    {
        "code": "CHEST_PAIN_DYSPNEA",
        "severity": "high",
        "keywords": ["chest pain", "seene mein dard", "chhati mein dard", "dil mein dard", "heart pain"],
        "co_symptoms": ["saans", "breath", "dyspnea", "sweating", "pasina", "jaw", "left arm", "bazu", "chakkar"],
        "reason": "Severe chest discomfort accompanied by dyspnea or diaphoresis (Possible Acute Coronary Syndrome)"
    },
    {
        "code": "STROKE_FAST",
        "severity": "high",
        "keywords": ["slurred", "ladkhadana", "muh tedha", "face droop", "hath kamzor", "arm weakness", "paralysis", "falij"],
        "co_symptoms": [],
        "reason": "Sudden onset neurological deficit or speech disturbance (FAST criteria suspected stroke)"
    },
    {
        "code": "HEMATEMESIS",
        "severity": "high",
        "keywords": ["blood vomit", "khoon ki ulti", "kala pakhana", "black stool", "rectal bleed"],
        "co_symptoms": [],
        "reason": "Active gastrointestinal bleeding"
    },
    {
        "code": "ALTERED_SENSORIUM",
        "severity": "high",
        "keywords": ["behosh", "unconscious", "confusion", "dawa overdose", "sudden coma", "not responding"],
        "co_symptoms": [],
        "reason": "Loss of consciousness or acute altered mental status"
    },
    {
        "code": "SEVERE_DEHYDRATION",
        "severity": "medium",
        "keywords": ["continuous vomiting", "lagatar dast", "severe diarrhea", "no urine", "peshab band"],
        "co_symptoms": [],
        "reason": "Acute hypovolemia or dehydration shock risk"
    }
]

CHIEF_COMPLAINTS_MCQ = {
    "id": "CC_01",
    "text": "नमस्ते! आज आप किस मुख्य स्वास्थ्य समस्या के लिए परामर्श लेना चाहते हैं?",
    "text_en": "Hello! What is the primary health complaint you are seeking consultation for today?",
    "input_type": "mcq",
    "options": [
        {"key": "fever", "label": "बुखार (Fever / Jwara)", "icon": "thermostat"},
        {"key": "headache", "label": "सिरदर्द (Headache / Shiroruk)", "icon": "psychology"},
        {"key": "abdominal_pain", "label": "पेट दर्द या अपच (Stomach ache / Indigestion / Amlapitta)", "icon": "restaurant"},
        {"key": "joint_pain", "label": "जोड़ों का दर्द (Joint Pain / Sandhivata)", "icon": "accessibility"},
        {"key": "cough", "label": "खांसी व सांस समस्या (Cough / Shwasa-Kasa)", "icon": "air"},
        {"key": "other", "label": "अन्य समस्या (Other symptom)", "icon": "more_horiz"}
    ],
    "section": "chief_complaint",
    "progress": {"done": 1, "total": 12}
}

SOCRATES_QUESTIONS: Dict[str, List[Dict[str, Any]]] = {
    "fever": [
        {
            "id": "HPI_FEVER_ONSET",
            "text": "यह बुखार आपको कब से महसूस हो रहा है?",
            "text_en": "Since when have you been feeling this fever?",
            "input_type": "mcq",
            "options": [
                {"key": "acute_today", "label": "आज से (Since today)"},
                {"key": "subacute_days", "label": "पिछले 2-3 दिनों से (Past 2-3 days)"},
                {"key": "week", "label": "लगभग 1 हफ्ते से (Past 1 week)"},
                {"key": "chronic", "label": "1 हफ्ते से अधिक (More than 1 week)"}
            ],
            "section": "hpi",
            "progress": {"done": 2, "total": 10}
        },
        {
            "id": "HPI_FEVER_PATTERN",
            "text": "बुखार का स्वभाव कैसा है? क्या यह पूरे दिन रहता है या किसी खास समय बढ़ता है?",
            "text_en": "What is the pattern of the fever? Is it continuous or does it spike at a specific time?",
            "input_type": "mcq",
            "options": [
                {"key": "continuous", "label": "पूरे दिन लगातार तेज़ रहता है (Continuous high fever)"},
                {"key": "evening_spike", "label": "शाम या रात को बढ़ता है (Evening / Night spike)"},
                {"key": "chills_rigors", "label": "ठंड या कंपकंपी के साथ चढ़ता है (With chills and rigors)"},
                {"key": "intermittent", "label": "दवा लेने पर उतर जाता है फिर आ जाता है (Intermittent)"}
            ],
            "section": "hpi",
            "progress": {"done": 3, "total": 10}
        },
        {
            "id": "HPI_FEVER_ASSOCIATED",
            "text": "बुखार के साथ इनमें से कौन से अन्य लक्षण महसूस हो रहे हैं?",
            "text_en": "Which of these associated symptoms are you experiencing along with fever?",
            "input_type": "mcq",
            "options": [
                {"key": "bodyache_headache", "label": "तेज़ सिरदर्द व बदन दर्द (Severe headache & body ache)"},
                {"key": "cough_cold", "label": "खांसी, ज़ुकाम व गले में दर्द (Cough, cold & sore throat)"},
                {"key": "burning_urine", "label": "पेशाब में जलन या दर्द (Burning micturition)"},
                {"key": "nausea_vomiting", "label": "जी मिचलाना या उल्टी (Nausea or vomiting)"}
            ],
            "section": "hpi",
            "progress": {"done": 4, "total": 10}
        },
        {
            "id": "HPI_SEVERITY",
            "text": "शारीरिक बेचैनी और कमज़ोरी 0 से 10 के पैमाने पर कितनी है?",
            "text_en": "Rate your physical distress and weakness from 0 to 10",
            "input_type": "slider",
            "options": [],
            "section": "hpi",
            "progress": {"done": 5, "total": 10}
        },
        {
            "id": "AYUSH_SWEDA",
            "text": "आयुष परीक्षण: क्या बुखार के समय पसीना (स्वेद) आता है?",
            "text_en": "AYUSH Assessment: Do you experience sweating (Sweda) during fever?",
            "input_type": "mcq",
            "options": [
                {"key": "anasweda", "label": "त्वचा बिल्कुल सूखी है, पसीना नहीं आता (Dry skin / Anasweda)"},
                {"key": "sweat_relief", "label": "पसीना आने पर बुखार उतरता है (Sweating relieves fever)"},
                {"key": "night_sweats", "label": "रात में बहुत ज़्यादा पसीना आता है (Profuse night sweats)"}
            ],
            "section": "ayush",
            "progress": {"done": 6, "total": 10}
        },
        {
            "id": "AYUSH_AGNI",
            "text": "आपकी भूख और पाचन शक्ति (अग्नि) कैसी है?",
            "text_en": "How is your appetite and digestion (Agni)?",
            "input_type": "mcq",
            "options": [
                {"key": "mandagni", "label": "भूख बिल्कुल नहीं है / अरुचि (No appetite / Aruchi)"},
                {"key": "bitter_taste", "label": "मुंह का स्वाद कड़वा या फीका (Bitter or tasteless mouth)"},
                {"key": "samagni", "label": "सामान्य भूख लग रही है (Normal appetite)"}
            ],
            "section": "ayush",
            "progress": {"done": 7, "total": 10}
        }
    ],
    "headache": [
        {
            "id": "HPI_HEADACHE_SITE",
            "text": "सिरदर्द मुख्य रूप से किस हिस्से में महसूस हो रहा है?",
            "text_en": "Where exactly is the headache located?",
            "input_type": "mcq",
            "options": [
                {"key": "frontal", "label": "माथे और आंखों के ऊपर (Frontal / Forehead)"},
                {"key": "one_sided", "label": "केवल एक तरफ - आधा सीसी (One-sided / Migraine)"},
                {"key": "occipital", "label": "सिर के पीछे व गर्दन में (Back of head / Neck)"},
                {"key": "diffuse", "label": "पूरे सिर में भारीपन (All over head / Tension)"}
            ],
            "section": "hpi",
            "progress": {"done": 2, "total": 10}
        },
        {
            "id": "HPI_HEADACHE_ONSET",
            "text": "यह सिरदर्द कब से है और कैसा महसूस होता है?",
            "text_en": "How long have you had this headache and what does it feel like?",
            "input_type": "mcq",
            "options": [
                {"key": "throbbing", "label": "नसें फड़कने जैसा धक-धक दर्द (Throbbing / Pulsating)"},
                {"key": "tight_band", "label": "सिर बंधा हुआ या भारी लगना (Heavy / Tight band)"},
                {"key": "sharp_pricking", "label": "सुई चुभने जैसा तेज़ दर्द (Sharp pricking)"}
            ],
            "section": "hpi",
            "progress": {"done": 3, "total": 10}
        },
        {
            "id": "HPI_HEADACHE_TRIGGERS",
            "text": "क्या इनमें से किसी कारण से सिरदर्द बढ़ता है?",
            "text_en": "What triggers or worsens your headache?",
            "input_type": "mcq",
            "options": [
                {"key": "light_sound", "label": "तेज़ रोशनी, आवाज़ या स्क्रीन देखने से (Light / Sound)"},
                {"key": "stress_sleep", "label": "कम नींद या मानसिक तनाव से (Lack of sleep / Stress)"},
                {"key": "empty_stomach", "label": "भूखे रहने या धूप में जाने से (Hunger / Sunlight)"},
                {"key": "constant", "label": "लगातार एक जैसा बना रहता है (Constant)"}
            ],
            "section": "hpi",
            "progress": {"done": 4, "total": 10}
        },
        {
            "id": "HPI_SEVERITY",
            "text": "सिरदर्द की तीव्रता 0 से 10 के पैमाने पर कितनी है?",
            "text_en": "Rate headache severity from 0 to 10",
            "input_type": "slider",
            "options": [],
            "section": "hpi",
            "progress": {"done": 5, "total": 10}
        },
        {
            "id": "AYUSH_NIDRA",
            "text": "आयुष मूल्यांकन: आपकी नींद और मानसिक तनाव की क्या स्थिति है?",
            "text_en": "AYUSH Assessment: How is your sleep quality and mental stress?",
            "input_type": "mcq",
            "options": [
                {"key": "anidra", "label": "नींद नहीं आती / बार-बार खुलती है (Disturbed sleep / Anidra)"},
                {"key": "heavy_morning", "label": "सुबह उठने पर सिर भारी रहता है (Morning heaviness)"},
                {"key": "normal_sleep", "label": "नींद सामान्य है (Normal sleep)"}
            ],
            "section": "ayush",
            "progress": {"done": 6, "total": 10}
        }
    ],
    "abdominal_pain": [
        {
            "id": "HPI_ABDO_SITE",
            "text": "यह दर्द पेट के किस हिस्से में सबसे ज़्यादा महसूस होता है?",
            "text_en": "Where in your abdomen is the discomfort located?",
            "input_type": "mcq",
            "options": [
                {"key": "epigastric", "label": "ऊपरी पेट (छाती के ठीक नीचे / Epigastric)"},
                {"key": "lower_abdo", "label": "निचला पेट या नाभि के पास (Lower abdomen / Umbilical)"},
                {"key": "right_upper", "label": "दाहिनी तरफ पसलियों के नीचे (Right hypochondrium)"},
                {"key": "diffuse", "label": "पूरे पेट में मरोड़ या भारीपन (Diffuse cramp / Bloat)"}
            ],
            "section": "hpi",
            "progress": {"done": 2, "total": 10}
        },
        {
            "id": "HPI_ABDO_RELATION",
            "text": "दर्द का भोजन से क्या संबंध है?",
            "text_en": "How is the pain related to food intake?",
            "input_type": "mcq",
            "options": [
                {"key": "after_food", "label": "खाना खाने के तुरंत बाद बढ़ता है (Worse post-meals)"},
                {"key": "empty_stomach", "label": "खाली पेट जलन होती है, खाने से आराम मिलता है (Relieved by food)"},
                {"key": "spicy_fried", "label": "मसालेदार या खट्टा खाने से बढ़ता है (Worse with spicy food)"},
                {"key": "no_relation", "label": "भोजन से कोई संबंध नहीं (Unrelated to meals)"}
            ],
            "section": "hpi",
            "progress": {"done": 3, "total": 10}
        },
        {
            "id": "HPI_SEVERITY",
            "text": "पेट दर्द की तीव्रता 0 से 10 के पैमाने पर कितनी है?",
            "text_en": "Rate abdominal pain severity from 0 to 10",
            "input_type": "slider",
            "options": [],
            "section": "hpi",
            "progress": {"done": 4, "total": 10}
        },
        {
            "id": "AYUSH_AGNI",
            "text": "आपकी पाचन शक्ति (अग्नि) और भूख कैसी है?",
            "text_en": "How is your digestive fire (Agni)?",
            "input_type": "mcq",
            "options": [
                {"key": "tikshnagni", "label": "सीने व गले में जलन / खट्टी डकारें (Tikshnagni / Acidity)"},
                {"key": "mandagni", "label": "भूख न लगना / पेट फूला रहना (Mandagni / Bloating)"},
                {"key": "samagni", "label": "सामान्य पाचन (Normal digestion)"}
            ],
            "section": "ayush",
            "progress": {"done": 5, "total": 10}
        },
        {
            "id": "AYUSH_KOSHTHA",
            "text": "शौच साफ होने की स्थिति (कोष्ठ) कैसी है?",
            "text_en": "How are your bowel movements (Koshtha)?",
            "input_type": "mcq",
            "options": [
                {"key": "krura", "label": "कब्ज रहती है (Constipated / Krura)"},
                {"key": "mrudu", "label": "दस्त या पतला शौच (Loose stool / Mrudu)"},
                {"key": "madhyama", "label": "सामान्य व नियमित (Formed / Normal)"}
            ],
            "section": "ayush",
            "progress": {"done": 6, "total": 10}
        }
    ],
    "cough": [
        {
            "id": "HPI_COUGH_TYPE",
            "text": "खांसी का स्वरूप कैसा है?",
            "text_en": "What is the character of your cough?",
            "input_type": "mcq",
            "options": [
                {"key": "dry", "label": "सूखी खांसी, गले में खुजली के साथ (Dry irritant cough)"},
                {"key": "productive", "label": "बलगम / कफ वाली खांसी (Productive with phlegm)"},
                {"key": "nocturnal", "label": "रात में या लेटने पर खांसी के दौरे (Night worsening)"}
            ],
            "section": "hpi",
            "progress": {"done": 2, "total": 10}
        },
        {
            "id": "HPI_COUGH_DURATION",
            "text": "यह खांसी कितने दिनों से चल रही है?",
            "text_en": "How long have you been coughing?",
            "input_type": "mcq",
            "options": [
                {"key": "days", "label": "3-5 दिनों से (Recent, 3-5 days)"},
                {"key": "weeks", "label": "1 से 2 हफ्तों से (1-2 weeks)"},
                {"key": "chronic", "label": "3 हफ्तों या महीने से अधिक (Chronic >3 weeks)"}
            ],
            "section": "hpi",
            "progress": {"done": 3, "total": 10}
        },
        {
            "id": "HPI_COUGH_BREATH",
            "text": "क्या सांस लेने में परेशानी या छाती से सीटी जैसी आवाज़ (Wheezing) आती है?",
            "text_en": "Do you experience breathlessness or wheezing?",
            "input_type": "mcq",
            "options": [
                {"key": "normal", "label": "नहीं, सांस सामान्य है (Normal breathing)"},
                {"key": "exertion", "label": "चलने या सीढ़ी चढ़ने पर सांस फूलती है (On exertion)"},
                {"key": "wheeze", "label": "सीने से सीटी जैसी आवाज़ आती है (Wheezing sound)"}
            ],
            "section": "hpi",
            "progress": {"done": 4, "total": 10}
        },
        {
            "id": "HPI_SEVERITY",
            "text": "खांसी से होने वाली तकलीफ़ 0 से 10 के पैमाने पर कितनी है?",
            "text_en": "Rate cough severity from 0 to 10",
            "input_type": "slider",
            "options": [],
            "section": "hpi",
            "progress": {"done": 5, "total": 10}
        },
        {
            "id": "AYUSH_KAFHA",
            "text": "आयुष मूल्यांकन: कफ का रंग और गाढ़ापन कैसा है?",
            "text_en": "AYUSH Assessment: What is the color and consistency of phlegm?",
            "input_type": "mcq",
            "options": [
                {"key": "white_thick", "label": "सफेद व गाढ़ा (Kapha predominant)"},
                {"key": "yellow_green", "label": "पीला या हरा (Infection / Pitta-Kapha)"},
                {"key": "no_sputum", "label": "कफ बिल्कुल नहीं निकलता (Vataja / Dry)"}
            ],
            "section": "ayush",
            "progress": {"done": 6, "total": 10}
        }
    ],
    "joint_pain": [
        {
            "id": "HPI_JOINT_SITE",
            "text": "दर्द या सूजन मुख्य रूप से किस जोड़ में है?",
            "text_en": "Which joints are primarily affected by pain or swelling?",
            "input_type": "mcq",
            "options": [
                {"key": "knees", "label": "घुटनों में (Knees / Janu Sandhi)"},
                {"key": "small_joints", "label": "हाथ-पैरों की उंगलियों में (Fingers / Toes)"},
                {"key": "back_hip", "label": "कमर या कूल्हे में (Lower back / Hip)"},
                {"key": "multiple", "label": "शरीर के कई जोड़ों में एक साथ (Multiple joints)"}
            ],
            "section": "hpi",
            "progress": {"done": 2, "total": 10}
        },
        {
            "id": "HPI_JOINT_STIFFNESS",
            "text": "क्या सुबह सोकर उठने पर जोड़ों में अकड़न (जकड़ाहट) महसूस होती है?",
            "text_en": "Do you feel joint stiffness upon waking up in the morning?",
            "input_type": "mcq",
            "options": [
                {"key": "prolonged", "label": "हाँ, 30 मिनट से अधिक समय तक (Morning stiffness >30m)"},
                {"key": "brief", "label": "हाँ, पर चलने-फिरने से 5-10 मिनट में खुल जाती है (Mild)"},
                {"key": "none", "label": "अकड़न नहीं होती, केवल दर्द रहता है (Pain without stiffness)"}
            ],
            "section": "hpi",
            "progress": {"done": 3, "total": 10}
        },
        {
            "id": "HPI_SEVERITY",
            "text": "जोड़ों के दर्द की तीव्रता 0 से 10 के पैमाने पर कितनी है?",
            "text_en": "Rate joint pain severity from 0 to 10",
            "input_type": "slider",
            "options": [],
            "section": "hpi",
            "progress": {"done": 4, "total": 10}
        },
        {
            "id": "AYUSH_AMA",
            "text": "आयुष मूल्यांकन: क्या जोड़ों में भारीपन या छूने पर गर्म महसूस होता है?",
            "text_en": "AYUSH Assessment: Is there joint swelling, warmth or heavy feeling (Amavata)?",
            "input_type": "mcq",
            "options": [
                {"key": "warm_swollen", "label": "जोड़ सूजे हुए और गर्म हैं (Warm & swollen / Amavata)"},
                {"key": "crepitus_cold", "label": "चलने पर कट-कट आवाज़ व ठंड में बढ़ता है (Sandhivata)"},
                {"key": "mild_ache", "label": "केवल हल्का दर्द है (Mild ache)"}
            ],
            "section": "ayush",
            "progress": {"done": 5, "total": 10}
        }
    ],
    "indigestion": [
        {
            "id": "HPI_INDIGESTION_SYMPTOMS",
            "text": "पाचन संबंधी मुख्य तकलीफ़ क्या महसूस हो रही है?",
            "text_en": "What is the primary digestive issue you are facing?",
            "input_type": "mcq",
            "options": [
                {"key": "acidity_heartburn", "label": "खट्टी डकारें व सीने में जलन (Acidity / Heartburn / Amlapitta)"},
                {"key": "bloating_gas", "label": "पेट फूलना व भारीपन (Gas / Bloating / Adhmana)"},
                {"key": "low_appetite", "label": "भूख बिल्कुल न लगना (Loss of appetite / Ajeerna)"},
                {"key": "irregular_bowels", "label": "पेट साफ न होना (Irregular bowel movements)"}
            ],
            "section": "hpi",
            "progress": {"done": 2, "total": 10}
        },
        {
            "id": "HPI_INDIGESTION_DURATION",
            "text": "यह परेशानी कितने समय से बनी हुई है?",
            "text_en": "How long have you had this digestive discomfort?",
            "input_type": "mcq",
            "options": [
                {"key": "recent_days", "label": "पिछले 2-3 दिनों से (Past 2-3 days)"},
                {"key": "weeks", "label": "कुछ हफ़्तों से (Past few weeks)"},
                {"key": "chronic", "label": "लंबे समय से अक्सर रहती है (Chronic / Months)"}
            ],
            "section": "hpi",
            "progress": {"done": 3, "total": 10}
        },
        {
            "id": "AYUSH_AGNI",
            "text": "आपकी भूख (जठराग्नि) की क्या स्थिति है?",
            "text_en": "How is your appetite (Agni)?",
            "input_type": "mcq",
            "options": [
                {"key": "mandagni", "label": "मंदाग्नि — खाना पचता नहीं, भारीपन रहता है"},
                {"key": "tikshnagni", "label": "तीक्ष्णाग्नि — जल्दी भूख लगती है, जलन होती है"},
                {"key": "vishamagni", "label": "विषमाग्नि — कभी बहुत भूख, कभी बिल्कुल नहीं"}
            ],
            "section": "ayush",
            "progress": {"done": 4, "total": 10}
        },
        {
            "id": "AYUSH_KOSHTHA",
            "text": "पेट साफ होने (कोष्ठ) की क्या स्थिति है?",
            "text_en": "What are your bowel habits (Koshtha)?",
            "input_type": "mcq",
            "options": [
                {"key": "krura", "label": "क्रूर कोष्ठ — सख्त मल, कब्ज़ रहती है"},
                {"key": "mrudu", "label": "मृदु कोष्ठ — पतला या बार-बार शौच जाना पड़ता है"},
                {"key": "madhyama", "label": "मध्यम कोष्ठ — दिन में एक बार सामान्य"}
            ],
            "section": "ayush",
            "progress": {"done": 5, "total": 10}
        }
    ],
    "skin_rash": [
        {
            "id": "HPI_SKIN_SITE",
            "text": "त्वचा पर दाने या खुजली शरीर के किस हिस्से में है?",
            "text_en": "Where on your body are the skin rashes or itching located?",
            "input_type": "mcq",
            "options": [
                {"key": "face_neck", "label": "चेहरे या गर्दन पर (Face / Neck)"},
                {"key": "arms_legs", "label": "हाथों या पैरों पर (Arms / Legs)"},
                {"key": "generalized", "label": "पूरे शरीर पर फैले हुए हैं (All over body)"},
                {"key": "folds", "label": "त्वचा की सिलवटों में (Skin folds / Groin)"}
            ],
            "section": "hpi",
            "progress": {"done": 2, "total": 10}
        },
        {
            "id": "HPI_SKIN_ITCH",
            "text": "क्या इनमें खुजली या जलन महसूस होती है?",
            "text_en": "Do you feel itching or burning sensation?",
            "input_type": "mcq",
            "options": [
                {"key": "intense_itch", "label": "बहुत तेज़ खुजली (Severe itching / Kandu)"},
                {"key": "burning", "label": "जलन और लालिमा (Burning & redness / Daha)"},
                {"key": "mild", "label": "हल्की परेशानी है (Mild discomfort)"}
            ],
            "section": "hpi",
            "progress": {"done": 3, "total": 10}
        },
        {
            "id": "HPI_SEVERITY",
            "text": "तकलीफ की तीव्रता 0 से 10 के पैमाने पर कितनी है?",
            "text_en": "Rate severity from 0 to 10",
            "input_type": "slider",
            "options": [],
            "section": "hpi",
            "progress": {"done": 4, "total": 10}
        }
    ],
    "default": [
        {
            "id": "HPI_ONSET",
            "text": "यह समस्या कब और कैसे शुरू हुई?",
            "text_en": "When and how did this issue begin?",
            "input_type": "mcq",
            "options": [
                {"key": "sudden", "label": "अचानक, 1-2 दिन पहले (Suddenly, past 1-2 days)"},
                {"key": "gradual_week", "label": "धीरे-धीरे, लगभग 1 हफ्ते से (Past 1 week)"},
                {"key": "chronic_month", "label": "लंबे समय से, 1 महीने से अधिक (Chronic, >1 month)"}
            ],
            "section": "hpi",
            "progress": {"done": 2, "total": 10}
        },
        {
            "id": "HPI_SEVERITY",
            "text": "तकलीफ की तीव्रता 0 से 10 के पैमाने पर कितनी है?",
            "text_en": "How severe is the discomfort on a scale of 0 to 10?",
            "input_type": "slider",
            "options": [],
            "section": "hpi",
            "progress": {"done": 3, "total": 10}
        },
        {
            "id": "HPI_MODIFIERS",
            "text": "क्या किसी विशेष कार्य, समय या भोजन से यह तकलीफ घटती या बढ़ती है?",
            "text_en": "Does any specific activity, time, or food relieve or worsen it?",
            "input_type": "mcq",
            "options": [
                {"key": "food_worsens", "label": "भोजन के बाद बढ़ती है (Worse after meals)"},
                {"key": "rest_relieves", "label": "आराम से कम होती है (Relieved by rest)"},
                {"key": "constant", "label": "लगातार एक जैसी रहती है (Constant throughout the day)"}
            ],
            "section": "hpi",
            "progress": {"done": 4, "total": 10}
        },
        {
            "id": "AYUSH_AGNI",
            "text": "आयुष मूल्यांकन: आपकी भूख और पाचन शक्ति (अग्नि) कैसी है?",
            "text_en": "AYUSH Assessment: How is your appetite and digestion (Agni)?",
            "input_type": "mcq",
            "options": [
                {"key": "samagni", "label": "सामान्य व संतुलित भूख (Normal / Samagni)"},
                {"key": "mandagni", "label": "भूख कम लगना / भारीपन (Sluggish / Mandagni)"},
                {"key": "tikshnagni", "label": "तेज़ भूख व जलन (Excessive / Tikshnagni)"},
                {"key": "vishamagni", "label": "कभी बहुत भूख, कभी बिल्कुल नहीं (Irregular / Vishamagni)"}
            ],
            "section": "ayush",
            "progress": {"done": 5, "total": 10}
        },
        {
            "id": "AYUSH_KOSHTHA",
            "text": "आपका पेट साफ होने की स्थिति (कोष्ठ) कैसी है?",
            "text_en": "How are your bowel habits (Koshtha)?",
            "input_type": "mcq",
            "options": [
                {"key": "mrudu", "label": "शीघ्र व पतला (Soft / Loose / Mrudu)"},
                {"key": "madhyama", "label": "नियमित व सामान्य (Regular / Madhyama)"},
                {"key": "krura", "label": "कब्ज या कठिनाई से (Constipated / Hard / Krura)"}
            ],
            "section": "ayush",
            "progress": {"done": 6, "total": 10}
        }
    ]
}

def detect_complaint_key(text: Optional[str]) -> str:
    """Normalizes patient complaints into standard clinical ontology branches."""
    if not text:
        return "default"
    t = text.lower()
    if any(k in t for k in ["fever", "bukhar", "बुखार", "jwara", "ज्वर", "tapmaan", "temperature", "chills"]):
        return "fever"
    if any(k in t for k in ["headache", "sir dard", "sar dard", "सिर", "shiroruk", "migraine", "माथा"]):
        return "headache"
    if any(k in t for k in ["joint", "knee", "ghutn", "jodon", "जोड़ों", "sandhi", "sandhivata", "amavata", "arth"]):
        return "joint_pain"
    if any(k in t for k in ["cough", "cold", "khansi", "खांसी", "jukam", "zukam", "जुकाम", "phlegm", "kasa", "shwasa", "saans"]):
        return "cough"
    if any(k in t for k in ["pet dard", "pet", "पेट", "abdom", "stomach", "shool", "उदर", "belly"]):
        return "abdominal_pain"
    if any(k in t for k in ["gas", "apach", "अपच", "indigest", "acidity", "amlapitta", "ajeerna", "bloat", "कब्ज"]):
        return "indigestion"
    if any(k in t for k in ["skin", "rash", "खुजली", "दाने", "kandu", "itch", "त्वचा", "chakatte"]):
        return "skin_rash"
    return "default"

def check_deterministic_red_flags(patient_text: str) -> Optional[RedFlag]:
    """
    Scans patient input string for emergency danger signals using exact pattern lists and regex.
    Always active, completely independent of LLMs.
    """
    text = (patient_text or "").lower()

    # 1. Proximity regex for chest pain / cardiac signs:
    chest_regex = re.compile(r"(chest|seene|chhati|dil|heart).{0,35}(pain|dard|jakdan|pressure|heaviness)", re.IGNORECASE)
    if chest_regex.search(text):
        co_syms = ["saans", "breath", "dyspnea", "sweating", "pasina", "jaw", "left arm", "bazu", "chakkar"]
        if any(cs in text for cs in co_syms):
            return RedFlag(
                code="CHEST_PAIN_DYSPNEA",
                severity="high",
                reason="Severe chest discomfort accompanied by dyspnea or diaphoresis (Possible Acute Coronary Syndrome)"
            )

    for rule in RED_FLAG_PATTERNS:
        # Check primary keywords
        matched_kw = any(kw in text for kw in rule["keywords"])
        if not matched_kw:
            continue

        # Check co-symptoms if defined
        co_syms = rule.get("co_symptoms", [])
        if co_syms:
            has_co = any(cs in text for cs in co_syms)
            if not has_co:
                continue

        return RedFlag(
            code=rule["code"],
            severity=rule["severity"],
            reason=rule["reason"]
        )
    return None

def get_deterministic_fallback_question(
    step_index: int = 0,
    complaint_key: Optional[str] = None,
    user_answer_text: Optional[str] = None
) -> InterviewStep:
    """Generates the next deterministic question from the clinical ontology graph, dynamically grounded on chief complaint."""
    if step_index == 0:
        return InterviewStep(
            type="question",
            question=Question.model_validate(CHIEF_COMPLAINTS_MCQ)
        )

    branch_key = complaint_key or detect_complaint_key(user_answer_text)
    if branch_key not in SOCRATES_QUESTIONS:
        branch_key = "default"

    q_list = SOCRATES_QUESTIONS[branch_key]
    idx = (step_index - 1) % len(q_list)
    raw_q = q_list[idx]

    return InterviewStep(
        type="question",
        question=Question.model_validate(raw_q),
        grounded_on=[f"ontology_{branch_key}"]
    )

