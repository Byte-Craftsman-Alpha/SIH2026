"""
MediKiosk — Complete Clinical Question Banks
General (SOCRATES), AYUSH (Vikriti/Agni/Koshtha), Prakriti Assessment, Red-Flag Rules
"""

# ─────────────────────────────────────────────
#  COMPLAINT CHIPS (first question quick-select)
# ─────────────────────────────────────────────
COMPLAINT_CHIPS = [
    {"key": "fever", "label_en": "Fever", "label_hi": "बुखार", "icon": "thermometer"},
    {"key": "headache", "label_en": "Headache", "label_hi": "सर दर्द", "icon": "head"},
    {"key": "abdominal_pain", "label_en": "Stomach pain", "label_hi": "पेट दर्द", "icon": "stomach"},
    {"key": "breathing", "label_en": "Breathing difficulty", "label_hi": "सांस फूलना", "icon": "lungs"},
    {"key": "joint_pain", "label_en": "Joint pain", "label_hi": "जोड़ों का दर्द", "icon": "bone"},
    {"key": "weakness", "label_en": "Weakness", "label_hi": "कमज़ोरी", "icon": "fatigue"},
    {"key": "cough", "label_en": "Cough", "label_hi": "खांसी", "icon": "cough"},
    {"key": "chest_pain", "label_en": "Chest pain", "label_hi": "सीने में दर्द", "icon": "heart"},
    {"key": "skin", "label_en": "Skin problem", "label_hi": "त्वचा की समस्या", "icon": "skin"},
    {"key": "digestion", "label_en": "Digestion issue", "label_hi": "पाचन की समस्या", "icon": "stomach"},
    {"key": "back_pain", "label_en": "Back pain", "label_hi": "कमर दर्द", "icon": "spine"},
    {"key": "other", "label_en": "Something else", "label_hi": "कुछ और", "icon": "plus"},
]

# ─────────────────────────────────────────────
#  GENERAL QUESTIONS (SOCRATES + ROS + History)
# ─────────────────────────────────────────────
GENERAL_QUESTIONS = [
    # HPI — Chief Complaint
    {
        "id": "GEN_CC_01", "section": "HPI",
        "text_en": "What is your main problem today?",
        "text_hi": "आज आपकी मुख्य तकलीफ़ क्या है?",
        "input_type": "complaint_chips",
        "options": [],  # uses COMPLAINT_CHIPS
        "tts_key": "gen_cc_01"
    },
    # SOCRATES — Site
    {
        "id": "HPI_SOCRATES_01", "section": "HPI",
        "text_en": "Where exactly do you feel the problem?",
        "text_hi": "तकलीफ़ शरीर में कहाँ हो रही है?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Head/Neck", "label_hi": "सिर/गर्दन", "icon": "head"},
            {"key": "B", "label_en": "Chest", "label_hi": "छाती", "icon": "chest"},
            {"key": "C", "label_en": "Abdomen", "label_hi": "पेट", "icon": "stomach"},
            {"key": "D", "label_en": "Back", "label_hi": "कमर/पीठ", "icon": "back"},
            {"key": "E", "label_en": "Limbs/Joints", "label_hi": "हाथ-पैर/जोड़", "icon": "limbs"},
            {"key": "F", "label_en": "All over", "label_hi": "पूरे शरीर में", "icon": "body"},
        ],
        "tts_key": "hpi_socrates_01"
    },
    # SOCRATES — Onset
    {
        "id": "HPI_SOCRATES_02", "section": "HPI",
        "text_en": "When did this problem start?",
        "text_hi": "ये तकलीफ़ कब से है?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Today", "label_hi": "आज ही", "icon": "calendar"},
            {"key": "B", "label_en": "2-3 days", "label_hi": "2-3 दिन", "icon": "calendar"},
            {"key": "C", "label_en": "1 week", "label_hi": "1 हफ़्ता", "icon": "calendar"},
            {"key": "D", "label_en": "2-4 weeks", "label_hi": "2-4 हफ़्ते", "icon": "calendar"},
            {"key": "E", "label_en": "1-6 months", "label_hi": "1-6 महीने", "icon": "calendar"},
            {"key": "F", "label_en": "More than 6 months", "label_hi": "6 महीने से ज़्यादा", "icon": "calendar"},
        ],
        "tts_key": "hpi_socrates_02"
    },
    # SOCRATES — Character
    {
        "id": "HPI_SOCRATES_03", "section": "HPI",
        "text_en": "How does the pain/discomfort feel?",
        "text_hi": "दर्द/तकलीफ़ कैसी लगती है?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Sharp/Stabbing", "label_hi": "तेज़/चुभने वाला", "icon": "sharp"},
            {"key": "B", "label_en": "Dull/Aching", "label_hi": "हल्का/टीसता हुआ", "icon": "dull"},
            {"key": "C", "label_en": "Burning", "label_hi": "जलन वाला", "icon": "fire"},
            {"key": "D", "label_en": "Cramping", "label_hi": "ऐंठन वाला", "icon": "cramp"},
            {"key": "E", "label_en": "Pressure/Heavy", "label_hi": "दबाव/भारीपन", "icon": "weight"},
        ],
        "tts_key": "hpi_socrates_03"
    },
    # SOCRATES — Radiation
    {
        "id": "HPI_SOCRATES_04", "section": "HPI",
        "text_en": "Does the pain spread to any other area?",
        "text_hi": "क्या दर्द कहीं और भी जाता है?",
        "input_type": "yes_no_dontknow",
        "options": [
            {"key": "Y", "label_en": "Yes", "label_hi": "हाँ"},
            {"key": "N", "label_en": "No", "label_hi": "नहीं"},
            {"key": "DK", "label_en": "Don't know", "label_hi": "पता नहीं"},
        ],
        "tts_key": "hpi_socrates_04"
    },
    # SOCRATES — Associations
    {
        "id": "HPI_SOCRATES_05", "section": "HPI",
        "text_en": "Do you have any of these along with your main problem?",
        "text_hi": "तकलीफ़ के साथ इनमें से कुछ भी है?",
        "input_type": "multi_select",
        "options": [
            {"key": "A", "label_en": "Fever", "label_hi": "बुखार", "icon": "thermometer"},
            {"key": "B", "label_en": "Nausea/Vomiting", "label_hi": "जी मिचलाना/उल्टी", "icon": "nausea"},
            {"key": "C", "label_en": "Dizziness", "label_hi": "चक्कर आना", "icon": "dizzy"},
            {"key": "D", "label_en": "Sweating", "label_hi": "पसीना आना", "icon": "sweat"},
            {"key": "E", "label_en": "Loss of appetite", "label_hi": "भूख न लगना", "icon": "food"},
            {"key": "F", "label_en": "None of these", "label_hi": "इनमें से कुछ नहीं", "icon": "none"},
        ],
        "tts_key": "hpi_socrates_05"
    },
    # SOCRATES — Timing
    {
        "id": "HPI_SOCRATES_06", "section": "HPI",
        "text_en": "Is the problem constant or does it come and go?",
        "text_hi": "तकलीफ़ लगातार है या आती-जाती है?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Constant", "label_hi": "लगातार", "icon": "constant"},
            {"key": "B", "label_en": "Comes and goes", "label_hi": "आती-जाती है", "icon": "wave"},
            {"key": "C", "label_en": "Only at certain times", "label_hi": "सिर्फ़ कुछ समय पर", "icon": "clock"},
        ],
        "tts_key": "hpi_socrates_06"
    },
    # SOCRATES — Exacerbating/Relieving
    {
        "id": "HPI_SOCRATES_07", "section": "HPI",
        "text_en": "What makes the problem worse?",
        "text_hi": "तकलीफ़ किससे बढ़ती है?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Walking/Movement", "label_hi": "चलने/हिलने से", "icon": "walk"},
            {"key": "B", "label_en": "Eating", "label_hi": "खाने से", "icon": "food"},
            {"key": "C", "label_en": "Lying down", "label_hi": "लेटने से", "icon": "bed"},
            {"key": "D", "label_en": "Stress", "label_hi": "तनाव से", "icon": "stress"},
            {"key": "E", "label_en": "Nothing specific", "label_hi": "कुछ ख़ास नहीं", "icon": "none"},
        ],
        "tts_key": "hpi_socrates_07"
    },
    {
        "id": "HPI_SOCRATES_08", "section": "HPI",
        "text_en": "What helps relieve the problem?",
        "text_hi": "तकलीफ़ किससे कम होती है?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Rest", "label_hi": "आराम करने से", "icon": "rest"},
            {"key": "B", "label_en": "Medicine", "label_hi": "दवाई से", "icon": "pill"},
            {"key": "C", "label_en": "Hot/Cold compress", "label_hi": "गर्म/ठंडी सिकाई", "icon": "compress"},
            {"key": "D", "label_en": "Nothing helps", "label_hi": "कुछ भी नहीं", "icon": "none"},
        ],
        "tts_key": "hpi_socrates_08"
    },
    # SOCRATES — Severity
    {
        "id": "HPI_SOCRATES_09", "section": "HPI",
        "text_en": "On a scale of 0 to 10, how severe is your problem?",
        "text_hi": "0 से 10 में, तकलीफ़ कितनी तेज़ है?",
        "input_type": "severity_slider",
        "options": [],
        "tts_key": "hpi_socrates_09"
    },
    # Past Medical History
    {
        "id": "PMH_01", "section": "PMH",
        "text_en": "Do you have any of these conditions?",
        "text_hi": "क्या आपको इनमें से कोई बीमारी है?",
        "input_type": "multi_select",
        "options": [
            {"key": "A", "label_en": "Diabetes", "label_hi": "शुगर (मधुमेह)", "icon": "diabetes"},
            {"key": "B", "label_en": "Blood Pressure", "label_hi": "ब्लड प्रेशर", "icon": "bp"},
            {"key": "C", "label_en": "Heart disease", "label_hi": "दिल की बीमारी", "icon": "heart"},
            {"key": "D", "label_en": "Asthma/Breathing", "label_hi": "दमा/सांस", "icon": "lungs"},
            {"key": "E", "label_en": "Thyroid", "label_hi": "थायरॉइड", "icon": "thyroid"},
            {"key": "F", "label_en": "None", "label_hi": "कोई नहीं", "icon": "check"},
        ],
        "tts_key": "pmh_01"
    },
    # Past Surgical History
    {
        "id": "PSH_01", "section": "PSH",
        "text_en": "Have you had any surgeries before?",
        "text_hi": "क्या पहले कोई ऑपरेशन हुआ है?",
        "input_type": "yes_no_dontknow",
        "options": [
            {"key": "Y", "label_en": "Yes", "label_hi": "हाँ"},
            {"key": "N", "label_en": "No", "label_hi": "नहीं"},
        ],
        "tts_key": "psh_01"
    },
    # Drug & Allergy History
    {
        "id": "DRUG_01", "section": "DRUG",
        "text_en": "Are you currently taking any medicines?",
        "text_hi": "क्या अभी कोई दवाई चल रही है?",
        "input_type": "yes_no_dontknow",
        "options": [
            {"key": "Y", "label_en": "Yes", "label_hi": "हाँ"},
            {"key": "N", "label_en": "No", "label_hi": "नहीं"},
        ],
        "tts_key": "drug_01"
    },
    {
        "id": "DRUG_02", "section": "DRUG",
        "text_en": "Are you allergic to any medicine or food?",
        "text_hi": "क्या किसी दवाई या खाने से एलर्जी है?",
        "input_type": "yes_no_dontknow",
        "options": [
            {"key": "Y", "label_en": "Yes", "label_hi": "हाँ"},
            {"key": "N", "label_en": "No", "label_hi": "नहीं"},
            {"key": "DK", "label_en": "Don't know", "label_hi": "पता नहीं"},
        ],
        "tts_key": "drug_02"
    },
    # Family History
    {
        "id": "FH_01", "section": "FAMILY",
        "text_en": "Does anyone in your family have diabetes, BP or heart disease?",
        "text_hi": "आपके परिवार में किसी को शुगर, BP या दिल की बीमारी है?",
        "input_type": "multi_select",
        "options": [
            {"key": "A", "label_en": "Diabetes", "label_hi": "शुगर", "icon": "diabetes"},
            {"key": "B", "label_en": "Blood Pressure", "label_hi": "BP", "icon": "bp"},
            {"key": "C", "label_en": "Heart disease", "label_hi": "दिल की बीमारी", "icon": "heart"},
            {"key": "D", "label_en": "Cancer", "label_hi": "कैंसर", "icon": "cancer"},
            {"key": "E", "label_en": "None", "label_hi": "कोई नहीं", "icon": "check"},
        ],
        "tts_key": "fh_01"
    },
    # Personal History
    {
        "id": "PER_01", "section": "PERSONAL",
        "text_en": "Do you have any of these habits?",
        "text_hi": "क्या इनमें से कोई आदत है?",
        "input_type": "multi_select",
        "options": [
            {"key": "A", "label_en": "Smoking", "label_hi": "बीड़ी/सिगरेट", "icon": "smoke"},
            {"key": "B", "label_en": "Tobacco chewing", "label_hi": "गुटखा/तम्बाकू", "icon": "tobacco"},
            {"key": "C", "label_en": "Alcohol", "label_hi": "शराब", "icon": "alcohol"},
            {"key": "D", "label_en": "None", "label_hi": "कोई नहीं", "icon": "check"},
        ],
        "tts_key": "per_01"
    },
    {
        "id": "PER_02", "section": "PERSONAL",
        "text_en": "How is your sleep?",
        "text_hi": "आपकी नींद कैसी है?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Good (6-8 hours)", "label_hi": "अच्छी (6-8 घंटे)", "icon": "sleep_good"},
            {"key": "B", "label_en": "Disturbed", "label_hi": "ख़राब/टूटी हुई", "icon": "sleep_bad"},
            {"key": "C", "label_en": "Insomnia", "label_hi": "नींद नहीं आती", "icon": "insomnia"},
        ],
        "tts_key": "per_02"
    },
    # Review of Systems — quick scan
    {
        "id": "ROS_01", "section": "ROS",
        "text_en": "In the last 2 weeks, have you noticed any of these?",
        "text_hi": "पिछले 2 हफ़्तों में ये कुछ हुआ है?",
        "input_type": "multi_select",
        "options": [
            {"key": "A", "label_en": "Weight loss", "label_hi": "वज़न कम होना", "icon": "weight_loss"},
            {"key": "B", "label_en": "Night sweats", "label_hi": "रात को पसीना", "icon": "sweat"},
            {"key": "C", "label_en": "Blood in stool/urine", "label_hi": "मल/पेशाब में खून", "icon": "blood"},
            {"key": "D", "label_en": "Persistent cough", "label_hi": "लगातार खांसी", "icon": "cough"},
            {"key": "E", "label_en": "Swelling", "label_hi": "सूजन", "icon": "swelling"},
            {"key": "F", "label_en": "None", "label_hi": "कोई नहीं", "icon": "check"},
        ],
        "tts_key": "ros_01"
    },
    {
        "id": "ROS_02", "section": "ROS",
        "text_en": "How is your appetite these days?",
        "text_hi": "आजकल भूख कैसी है?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Normal", "label_hi": "ठीक है", "icon": "food_good"},
            {"key": "B", "label_en": "Reduced", "label_hi": "कम है", "icon": "food_less"},
            {"key": "C", "label_en": "Increased", "label_hi": "ज़्यादा है", "icon": "food_more"},
            {"key": "D", "label_en": "No appetite at all", "label_hi": "बिल्कुल नहीं लगती", "icon": "food_none"},
        ],
        "tts_key": "ros_02"
    },
    # Closing
    {
        "id": "GEN_CLOSE_01", "section": "CLOSE",
        "text_en": "Is there anything else you want to tell the doctor?",
        "text_hi": "क्या कुछ और है जो आप डॉक्टर को बताना चाहते हैं?",
        "input_type": "text",
        "options": [],
        "tts_key": "gen_close_01"
    },
]

# ─────────────────────────────────────────────
#  AYUSH QUESTIONS (Vikriti, Agni, Koshtha, Ahara-Vihara, Nidana)
# ─────────────────────────────────────────────
AYUSH_QUESTIONS = [
    # Vikriti (Current Imbalance)
    {
        "id": "AY_VIK_01", "section": "Vikriti",
        "text_en": "How do you feel overall right now?",
        "text_hi": "अभी आपको कैसा महसूस हो रहा है?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Anxious / Restless", "label_hi": "बेचैनी / घबराहट", "dosha": "vata"},
            {"key": "B", "label_en": "Irritable / Heated", "label_hi": "चिड़चिड़ापन / गर्मी", "dosha": "pitta"},
            {"key": "C", "label_en": "Heavy / Sluggish", "label_hi": "भारीपन / सुस्ती", "dosha": "kapha"},
        ],
        "tts_key": "ay_vik_01"
    },
    {
        "id": "AY_VIK_02", "section": "Vikriti",
        "text_en": "How is your skin currently?",
        "text_hi": "आजकल आपकी त्वचा कैसी है?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Dry / Rough", "label_hi": "रूखी / खुरदरी", "dosha": "vata"},
            {"key": "B", "label_en": "Oily / Rashes", "label_hi": "तैलीय / दाने", "dosha": "pitta"},
            {"key": "C", "label_en": "Moist / Swollen", "label_hi": "नम / सूजी हुई", "dosha": "kapha"},
        ],
        "tts_key": "ay_vik_02"
    },
    {
        "id": "AY_VIK_03", "section": "Vikriti",
        "text_en": "How is your energy level?",
        "text_hi": "आपकी ऊर्जा/ताकत कैसी है?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Fluctuating / Tired quickly", "label_hi": "ऊपर-नीचे / जल्दी थक जाते हैं", "dosha": "vata"},
            {"key": "B", "label_en": "Good but get hot/angry", "label_hi": "अच्छी है पर गुस्सा/गर्मी आती है", "dosha": "pitta"},
            {"key": "C", "label_en": "Low / Lazy feeling", "label_hi": "कम है / आलस लगता है", "dosha": "kapha"},
        ],
        "tts_key": "ay_vik_03"
    },
    # Agni (Digestive Fire)
    {
        "id": "AY_AGNI_01", "section": "Agni",
        "text_en": "How is your appetite? (Agni means digestive strength)",
        "text_hi": "भूख कैसी है? (अग्नि मतलब आपकी पाचन शक्ति)",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Irregular — sometimes hungry, sometimes not", "label_hi": "कभी लगती है कभी नहीं", "dosha": "vata"},
            {"key": "B", "label_en": "Strong — always hungry, can't skip meals", "label_hi": "तेज़ है — खाना छूटे तो दिक्कत", "dosha": "pitta"},
            {"key": "C", "label_en": "Low — can skip meals easily", "label_hi": "कम है — बिना खाए भी चल जाता है", "dosha": "kapha"},
        ],
        "tts_key": "ay_agni_01"
    },
    {
        "id": "AY_AGNI_02", "section": "Agni",
        "text_en": "How do you feel after eating?",
        "text_hi": "खाना खाने के बाद कैसा लगता है?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Bloated / Gas", "label_hi": "पेट फूलना / गैस", "dosha": "vata"},
            {"key": "B", "label_en": "Acidity / Burning", "label_hi": "एसिडिटी / जलन", "dosha": "pitta"},
            {"key": "C", "label_en": "Heavy / Sleepy", "label_hi": "भारी / नींद आना", "dosha": "kapha"},
            {"key": "D", "label_en": "Fine", "label_hi": "ठीक लगता है", "dosha": "none"},
        ],
        "tts_key": "ay_agni_02"
    },
    # Koshtha (Bowel Nature)
    {
        "id": "AY_KOSH_01", "section": "Koshtha",
        "text_en": "How is your bowel habit? (Koshtha means bowel nature)",
        "text_hi": "पेट कैसा साफ़ होता है? (कोष्ठ मतलब पेट की प्रकृति)",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Constipated / Hard stool", "label_hi": "कब्ज़ / सख़्त", "dosha": "vata"},
            {"key": "B", "label_en": "Loose / Frequent", "label_hi": "ढीला / बार-बार", "dosha": "pitta"},
            {"key": "C", "label_en": "Normal / Regular", "label_hi": "सामान्य / नियमित", "dosha": "kapha"},
        ],
        "tts_key": "ay_kosh_01"
    },
    # Ahara-Vihara (Diet & Lifestyle)
    {
        "id": "AY_AH_01", "section": "Ahara-Vihara",
        "text_en": "What type of food do you usually eat?",
        "text_hi": "आमतौर पर कैसा खाना खाते हैं?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Vegetarian", "label_hi": "शाकाहारी", "icon": "veg"},
            {"key": "B", "label_en": "Non-vegetarian", "label_hi": "मांसाहारी", "icon": "nonveg"},
            {"key": "C", "label_en": "Mixed", "label_hi": "दोनों", "icon": "mixed"},
        ],
        "tts_key": "ay_ah_01"
    },
    {
        "id": "AY_AH_02", "section": "Ahara-Vihara",
        "text_en": "What tastes do you prefer?",
        "text_hi": "कौन सा स्वाद ज़्यादा पसंद है?",
        "input_type": "multi_select",
        "options": [
            {"key": "A", "label_en": "Sweet", "label_hi": "मीठा", "dosha": "kapha"},
            {"key": "B", "label_en": "Sour", "label_hi": "खट्टा", "dosha": "pitta"},
            {"key": "C", "label_en": "Salty", "label_hi": "नमकीन", "dosha": "vata"},
            {"key": "D", "label_en": "Spicy", "label_hi": "तीखा", "dosha": "pitta"},
            {"key": "E", "label_en": "Bitter", "label_hi": "कड़वा", "dosha": "vata"},
        ],
        "tts_key": "ay_ah_02"
    },
    {
        "id": "AY_AH_03", "section": "Ahara-Vihara",
        "text_en": "How much water do you drink daily?",
        "text_hi": "दिन में कितना पानी पीते हैं?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Less than 4 glasses", "label_hi": "4 गिलास से कम", "icon": "water_low"},
            {"key": "B", "label_en": "4-8 glasses", "label_hi": "4-8 गिलास", "icon": "water_mid"},
            {"key": "C", "label_en": "More than 8 glasses", "label_hi": "8 गिलास से ज़्यादा", "icon": "water_high"},
        ],
        "tts_key": "ay_ah_03"
    },
    {
        "id": "AY_VIH_01", "section": "Ahara-Vihara",
        "text_en": "How much physical activity do you do?",
        "text_hi": "कितना शारीरिक काम/व्यायाम करते हैं?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Sedentary (sitting job)", "label_hi": "बैठे रहते हैं (ऑफ़िस)", "icon": "sit"},
            {"key": "B", "label_en": "Moderate (walking/housework)", "label_hi": "थोड़ा-बहुत (चलना/घर का काम)", "icon": "walk"},
            {"key": "C", "label_en": "Active (exercise/physical labor)", "label_hi": "ज़्यादा (मेहनत/व्यायाम)", "icon": "run"},
        ],
        "tts_key": "ay_vih_01"
    },
    # Nidana (Causative Factors)
    {
        "id": "AY_NID_01", "section": "Nidana",
        "text_en": "What do you think triggered this problem?",
        "text_hi": "आपको क्या लगता है ये तकलीफ़ किस वजह से हुई?",
        "input_type": "multi_select",
        "options": [
            {"key": "A", "label_en": "Food/Diet change", "label_hi": "खाने में बदलाव", "icon": "food"},
            {"key": "B", "label_en": "Weather change", "label_hi": "मौसम बदलने से", "icon": "weather"},
            {"key": "C", "label_en": "Stress/Tension", "label_hi": "तनाव/चिंता", "icon": "stress"},
            {"key": "D", "label_en": "Physical strain", "label_hi": "ज़्यादा मेहनत", "icon": "strain"},
            {"key": "E", "label_en": "Travel", "label_hi": "यात्रा", "icon": "travel"},
            {"key": "F", "label_en": "Don't know", "label_hi": "पता नहीं", "icon": "question"},
        ],
        "tts_key": "ay_nid_01"
    },
    # Samprapti hints
    {
        "id": "AY_SAMP_01", "section": "Nidana",
        "text_en": "How did the problem begin?",
        "text_hi": "तकलीफ़ कैसे शुरू हुई?",
        "input_type": "mcq",
        "options": [
            {"key": "A", "label_en": "Suddenly", "label_hi": "अचानक", "icon": "sudden"},
            {"key": "B", "label_en": "Gradually over days", "label_hi": "धीरे-धीरे कई दिनों में", "icon": "gradual"},
            {"key": "C", "label_en": "After a specific event", "label_hi": "किसी घटना के बाद", "icon": "event"},
        ],
        "tts_key": "ay_samp_01"
    },
    {
        "id": "AY_CLOSE_01", "section": "CLOSE",
        "text_en": "Have you taken any Ayurvedic treatment before for this?",
        "text_hi": "क्या इसके लिए पहले कोई आयुर्वेदिक इलाज लिया है?",
        "input_type": "yes_no_dontknow",
        "options": [
            {"key": "Y", "label_en": "Yes", "label_hi": "हाँ"},
            {"key": "N", "label_en": "No", "label_hi": "नहीं"},
        ],
        "tts_key": "ay_close_01"
    },
]

# ─────────────────────────────────────────────
#  PRAKRITI ASSESSMENT QUESTIONS (18 MCQs)
#  Scoring: A=Vata, B=Pitta, C=Kapha (weighted 1.0)
# ─────────────────────────────────────────────
PRAKRITI_QUESTIONS = [
    {
        "id": "PRAK_01", "section": "Physical",
        "text_en": "What is your body frame?",
        "text_hi": "आपके शरीर की बनावट कैसी है?",
        "options": [
            {"key": "A", "label_en": "Thin, light, tall/short", "label_hi": "पतला, हल्का, लंबा/छोटा", "dosha": "vata"},
            {"key": "B", "label_en": "Medium, proportionate", "label_hi": "मध्यम, सुडौल", "dosha": "pitta"},
            {"key": "C", "label_en": "Large, heavy, broad", "label_hi": "भारी, मोटा, चौड़ा", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_02", "section": "Physical",
        "text_en": "What is your body weight tendency?",
        "text_hi": "आपके वज़न का रुझान कैसा है?",
        "options": [
            {"key": "A", "label_en": "Hard to gain weight", "label_hi": "वज़न बढ़ाना मुश्किल", "dosha": "vata"},
            {"key": "B", "label_en": "Can gain or lose easily", "label_hi": "आसानी से बढ़ता-घटता है", "dosha": "pitta"},
            {"key": "C", "label_en": "Gains weight easily, hard to lose", "label_hi": "जल्दी बढ़ता है, घटाना मुश्किल", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_03", "section": "Physical",
        "text_en": "How is your skin naturally?",
        "text_hi": "आपकी त्वचा कुदरती तौर पर कैसी है?",
        "options": [
            {"key": "A", "label_en": "Dry, rough, thin", "label_hi": "सूखी, खुरदरी, पतली", "dosha": "vata"},
            {"key": "B", "label_en": "Warm, oily, sensitive", "label_hi": "गर्म, तैलीय, संवेदनशील", "dosha": "pitta"},
            {"key": "C", "label_en": "Thick, smooth, moist", "label_hi": "मोटी, चिकनी, नम", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_04", "section": "Physical",
        "text_en": "How is your hair?",
        "text_hi": "आपके बाल कैसे हैं?",
        "options": [
            {"key": "A", "label_en": "Dry, curly, frizzy", "label_hi": "सूखे, घुंघराले", "dosha": "vata"},
            {"key": "B", "label_en": "Fine, straight, early greying", "label_hi": "पतले, सीधे, जल्दी सफ़ेद", "dosha": "pitta"},
            {"key": "C", "label_en": "Thick, wavy, oily", "label_hi": "घने, लहरदार, तेलीय", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_05", "section": "Physical",
        "text_en": "How are your joints?",
        "text_hi": "आपके जोड़ कैसे हैं?",
        "options": [
            {"key": "A", "label_en": "Crackling, prominent", "label_hi": "चटकते हैं, उभरे हुए", "dosha": "vata"},
            {"key": "B", "label_en": "Flexible, moderate", "label_hi": "लचीले, सामान्य", "dosha": "pitta"},
            {"key": "C", "label_en": "Large, well-padded", "label_hi": "बड़े, भरे हुए", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_06", "section": "Physical",
        "text_en": "How do you feel about cold weather?",
        "text_hi": "ठंड के मौसम में कैसा लगता है?",
        "options": [
            {"key": "A", "label_en": "Always feel cold, hate winter", "label_hi": "हमेशा ठंड लगती है", "dosha": "vata"},
            {"key": "B", "label_en": "Prefer cool weather", "label_hi": "ठंडा मौसम अच्छा लगता है", "dosha": "pitta"},
            {"key": "C", "label_en": "Can tolerate cold well", "label_hi": "ठंड सह लेते हैं", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_07", "section": "Physiological",
        "text_en": "How is your appetite pattern?",
        "text_hi": "भूख का क्या पैटर्न है?",
        "options": [
            {"key": "A", "label_en": "Irregular — sometimes good, sometimes poor", "label_hi": "अनियमित — कभी अच्छी कभी ख़राब", "dosha": "vata"},
            {"key": "B", "label_en": "Strong — can't miss meals", "label_hi": "तेज़ — खाना छूटे नहीं सकता", "dosha": "pitta"},
            {"key": "C", "label_en": "Low but steady", "label_hi": "कम पर एक जैसी", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_08", "section": "Physiological",
        "text_en": "How do you sweat?",
        "text_hi": "पसीना कैसा आता है?",
        "options": [
            {"key": "A", "label_en": "Very little", "label_hi": "बहुत कम", "dosha": "vata"},
            {"key": "B", "label_en": "Profuse, strong smell", "label_hi": "ज़्यादा, तेज़ महक", "dosha": "pitta"},
            {"key": "C", "label_en": "Moderate, cold sweat", "label_hi": "सामान्य, ठंडा पसीना", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_09", "section": "Physiological",
        "text_en": "How are your sleep patterns?",
        "text_hi": "नींद कैसी आती है?",
        "options": [
            {"key": "A", "label_en": "Light, disturbed, difficulty falling asleep", "label_hi": "हल्की, टूटती है, आने में देर", "dosha": "vata"},
            {"key": "B", "label_en": "Moderate, wake up once/twice", "label_hi": "ठीक, बीच में 1-2 बार उठते हैं", "dosha": "pitta"},
            {"key": "C", "label_en": "Deep, heavy, hard to wake up", "label_hi": "गहरी, भारी, उठने में मुश्किल", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_10", "section": "Physiological",
        "text_en": "How fast do you walk/move?",
        "text_hi": "चलने/काम करने की रफ़्तार कैसी है?",
        "options": [
            {"key": "A", "label_en": "Fast, restless", "label_hi": "तेज़, बेचैन", "dosha": "vata"},
            {"key": "B", "label_en": "Moderate, purposeful", "label_hi": "मध्यम, निश्चित", "dosha": "pitta"},
            {"key": "C", "label_en": "Slow, steady", "label_hi": "धीमी, स्थिर", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_11", "section": "Physiological",
        "text_en": "How is your thirst?",
        "text_hi": "प्यास कैसी लगती है?",
        "options": [
            {"key": "A", "label_en": "Variable", "label_hi": "कभी कम कभी ज़्यादा", "dosha": "vata"},
            {"key": "B", "label_en": "Strong, frequent", "label_hi": "तेज़, बार-बार", "dosha": "pitta"},
            {"key": "C", "label_en": "Low, rarely thirsty", "label_hi": "कम लगती है", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_12", "section": "Psychological",
        "text_en": "How do you learn new things?",
        "text_hi": "नई चीज़ें कैसे सीखते हैं?",
        "options": [
            {"key": "A", "label_en": "Learn fast but forget fast", "label_hi": "जल्दी सीखते हैं, जल्दी भूलते हैं", "dosha": "vata"},
            {"key": "B", "label_en": "Sharp, focused learning", "label_hi": "तेज़, ध्यान लगाकर सीखते हैं", "dosha": "pitta"},
            {"key": "C", "label_en": "Slow to learn but remember long", "label_hi": "धीरे सीखते हैं पर लंबे समय याद रहता है", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_13", "section": "Psychological",
        "text_en": "How do you handle stress?",
        "text_hi": "तनाव/परेशानी में क्या होता है?",
        "options": [
            {"key": "A", "label_en": "Become anxious/fearful", "label_hi": "घबराहट/डर लगता है", "dosha": "vata"},
            {"key": "B", "label_en": "Become angry/irritated", "label_hi": "गुस्सा/चिड़चिड़ापन", "dosha": "pitta"},
            {"key": "C", "label_en": "Withdraw/become quiet", "label_hi": "चुप हो जाते हैं/अकेले रहते हैं", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_14", "section": "Psychological",
        "text_en": "How do you make decisions?",
        "text_hi": "फ़ैसले कैसे लेते हैं?",
        "options": [
            {"key": "A", "label_en": "Quick but change mind often", "label_hi": "जल्दी, पर बार-बार बदलते हैं", "dosha": "vata"},
            {"key": "B", "label_en": "Decisive, rarely change", "label_hi": "पक्का, शायद ही बदलें", "dosha": "pitta"},
            {"key": "C", "label_en": "Slow, think a lot before deciding", "label_hi": "धीरे, बहुत सोचकर", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_15", "section": "Psychological",
        "text_en": "How is your speaking pattern?",
        "text_hi": "बोलने का तरीक़ा कैसा है?",
        "options": [
            {"key": "A", "label_en": "Fast, talkative", "label_hi": "तेज़, बहुत बोलते हैं", "dosha": "vata"},
            {"key": "B", "label_en": "Sharp, convincing", "label_hi": "तीखा, प्रभावशाली", "dosha": "pitta"},
            {"key": "C", "label_en": "Slow, measured", "label_hi": "धीमा, सोच-समझकर", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_16", "section": "Psychological",
        "text_en": "What are your dreams usually like?",
        "text_hi": "सपने कैसे आते हैं?",
        "options": [
            {"key": "A", "label_en": "Flying, running, fearful", "label_hi": "उड़ना, भागना, डरावने", "dosha": "vata"},
            {"key": "B", "label_en": "Vivid, colorful, fire/fighting", "label_hi": "रंगीन, आग, लड़ाई", "dosha": "pitta"},
            {"key": "C", "label_en": "Calm, water, romantic", "label_hi": "शांत, पानी, प्यार", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_17", "section": "Sattva",
        "text_en": "How would you describe your nature?",
        "text_hi": "अपना स्वभाव कैसे बताएंगे?",
        "options": [
            {"key": "A", "label_en": "Creative, enthusiastic, changeable", "label_hi": "रचनात्मक, उत्साही, बदलते रहते हैं", "dosha": "vata"},
            {"key": "B", "label_en": "Leader, ambitious, competitive", "label_hi": "नेता, महत्वाकांक्षी, प्रतिस्पर्धी", "dosha": "pitta"},
            {"key": "C", "label_en": "Calm, caring, loyal", "label_hi": "शांत, देखभाल करने वाले, वफ़ादार", "dosha": "kapha"},
        ]
    },
    {
        "id": "PRAK_18", "section": "Samhanana",
        "text_en": "How is your physical stamina / endurance?",
        "text_hi": "शारीरिक सहनशक्ति कैसी है?",
        "options": [
            {"key": "A", "label_en": "Low — tire quickly", "label_hi": "कम — जल्दी थक जाते हैं", "dosha": "vata"},
            {"key": "B", "label_en": "Moderate — good in short bursts", "label_hi": "मध्यम — थोड़ी देर अच्छी रहती है", "dosha": "pitta"},
            {"key": "C", "label_en": "High — can endure long activities", "label_hi": "ज़्यादा — लंबे समय तक कर सकते हैं", "dosha": "kapha"},
        ]
    },
]

# ─────────────────────────────────────────────
#  RED FLAG RULES
# ─────────────────────────────────────────────
RED_FLAG_RULES = [
    {
        "code": "CHEST_PAIN_DYSPNEA",
        "severity": "high",
        "description": "Chest pain with breathing difficulty — possible cardiac emergency",
        "triggers": [
            {"type": "combination", "keywords": ["chest_pain", "breathing", "saans"]},
            {"type": "answer_pattern", "question_ids": ["GEN_CC_01"], "values": ["chest_pain"]},
        ],
        "instruction": "emergency_screen",
        "message_hi": "⚠️ छाती में दर्द और सांस फूलना गंभीर हो सकता है",
        "message_en": "⚠️ Chest pain with breathing difficulty can be serious"
    },
    {
        "code": "STROKE_FAST",
        "severity": "high",
        "description": "Sudden weakness one side, speech slur, face droop — stroke signs",
        "triggers": [
            {"type": "keywords", "keywords": ["face_droop", "arm_weakness", "speech_slur", "sudden_numbness"]},
        ],
        "instruction": "emergency_screen",
        "message_hi": "⚠️ ये stroke (लकवा) के लक्षण हो सकते हैं",
        "message_en": "⚠️ These could be signs of a stroke"
    },
    {
        "code": "HEMATEMESIS",
        "severity": "high",
        "description": "Vomiting blood or blood in stool",
        "triggers": [
            {"type": "keywords", "keywords": ["blood_vomit", "khoon_ulti", "blood_stool"]},
        ],
        "instruction": "emergency_screen",
        "message_hi": "⚠️ उल्टी/मल में खून गंभीर हो सकता है",
        "message_en": "⚠️ Blood in vomit/stool can be serious"
    },
    {
        "code": "ALTERED_SENSORIUM",
        "severity": "high",
        "description": "Confusion, unconsciousness, seizure",
        "triggers": [
            {"type": "keywords", "keywords": ["unconscious", "behosh", "seizure", "mirgi", "confusion"]},
        ],
        "instruction": "emergency_screen",
        "message_hi": "⚠️ बेहोशी/दौरे को तुरंत इलाज चाहिए",
        "message_en": "⚠️ Unconsciousness/seizures need immediate attention"
    },
    {
        "code": "SEVERE_DEHYDRATION",
        "severity": "medium",
        "description": "Severe vomiting + diarrhea with weakness, especially in children/elderly",
        "triggers": [
            {"type": "combination", "keywords": ["vomiting", "diarrhea", "weakness"]},
            {"type": "combination", "keywords": ["ulti", "dast", "kamzori"]},
        ],
        "instruction": "emergency_screen",
        "message_hi": "⚠️ ज़्यादा उल्टी-दस्त से पानी की कमी हो सकती है",
        "message_en": "⚠️ Severe vomiting and diarrhea can cause dangerous dehydration"
    },
]

# ─────────────────────────────────────────────
#  SEEDED DOCUMENT PARSED DATA (for demo)
# ─────────────────────────────────────────────
DEMO_PARSED_PRESCRIPTION = {
    "doc_type": "prescription",
    "doc_date": "2026-02-14",
    "ocr_lang": ["hi", "en"],
    "overall_confidence": 0.86,
    "extracted": {
        "doctor": {"name": "Dr. A. Verma", "specialty": "Kayachikitsa", "confidence": 0.94},
        "medicines": [
            {"name": "Metformin 500mg", "dosage": "500 mg", "frequency": "2x/day", "duration": "30 days", "instructions": "खाने के बाद", "confidence": 0.88},
            {"name": "Amlodipine 5mg", "dosage": "5 mg", "frequency": "1x/day", "duration": "30 days", "instructions": "सुबह खाली पेट", "confidence": 0.91},
            {"name": "Triphala Churna", "dosage": "5 gm", "frequency": "1x/day", "duration": "15 days", "instructions": "रात को गुनगुने पानी के साथ", "confidence": 0.79},
        ],
        "diagnosis_hints": [{"text": "Madhumeha (Type 2 DM)", "confidence": 0.72}],
    },
    "flags": {
        "abnormal_values": [],
        "drug_interactions": [
            {"drugs": ["Metformin", "Triphala"], "severity": "low", "note": "Monitor blood sugar — Triphala may enhance hypoglycemic effect"}
        ]
    }
}

DEMO_PARSED_LAB_REPORT = {
    "doc_type": "lab_report",
    "doc_date": "2026-08-20",
    "ocr_lang": ["en"],
    "overall_confidence": 0.92,
    "extracted": {
        "lab_name": "SRL Diagnostics",
        "patient_name_extracted": "Ramesh Kumar",
        "tests": [
            {"name": "Fasting Blood Sugar", "value": "186", "unit": "mg/dL", "ref_range": "70-100", "is_abnormal": True, "confidence": 0.95},
            {"name": "HbA1c", "value": "8.2", "unit": "%", "ref_range": "4-5.6", "is_abnormal": True, "confidence": 0.93},
            {"name": "Total Cholesterol", "value": "220", "unit": "mg/dL", "ref_range": "< 200", "is_abnormal": True, "confidence": 0.90},
            {"name": "Hemoglobin", "value": "13.5", "unit": "g/dL", "ref_range": "13-17", "is_abnormal": False, "confidence": 0.96},
            {"name": "Creatinine", "value": "0.9", "unit": "mg/dL", "ref_range": "0.7-1.2", "is_abnormal": False, "confidence": 0.94},
        ],
    },
    "flags": {
        "abnormal_values": ["Fasting Blood Sugar", "HbA1c", "Total Cholesterol"],
        "drug_interactions": []
    }
}

DEMO_PARSED_DISCHARGE = {
    "doc_type": "discharge_summary",
    "doc_date": "2025-12-10",
    "ocr_lang": ["en"],
    "overall_confidence": 0.78,
    "extracted": {
        "hospital": "AIIMS New Delhi",
        "admission_date": "2025-12-05",
        "discharge_date": "2025-12-10",
        "diagnosis": ["Acute Gastroenteritis", "Dehydration Grade II"],
        "procedures": ["IV Fluid Resuscitation"],
        "discharge_medicines": [
            {"name": "ORS", "instructions": "After every loose stool"},
            {"name": "Racecadotril 100mg", "instructions": "3x/day for 3 days"},
        ],
        "follow_up": "Review after 7 days at OPD",
        "advice": ["Avoid spicy/oily food for 2 weeks", "Drink boiled water only"],
    },
    "flags": {"abnormal_values": [], "drug_interactions": []}
}
