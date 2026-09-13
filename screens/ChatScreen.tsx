import Ionicons from '@expo/vector-icons/Ionicons';
import { BottomTabScreenProps } from '@react-navigation/bottom-tabs';
import { RecordingPresets, requestRecordingPermissionsAsync, setAudioModeAsync, useAudioRecorder, useAudioRecorderState } from 'expo-audio';
import * as Speech from 'expo-speech';
import React, { useCallback, useMemo, useRef, useState } from 'react';
import {
  Alert,
  FlatList,
  KeyboardAvoidingView,
  Linking,
  Modal,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import Animated, { useAnimatedStyle, useSharedValue, withRepeat, withTiming } from 'react-native-reanimated';
import { SafeAreaView } from 'react-native-safe-area-context';
import { AppHeader, InitialAvatar, SectionTitle } from '../components/ui';
import { useAppTheme } from '../lib/theme';
import type { RootTabParamList } from '../App';

type Props = BottomTabScreenProps<RootTabParamList, 'Chat'>;
type Language = 'English' | 'हिंदी' | 'தமிழ்';
type ConversationMode = 'text' | 'voice';
type Message = { id: string; role: 'assistant' | 'user'; text: string; time: string; mode: ConversationMode; critical?: boolean };

const LANGUAGES: { label: Language; code: string }[] = [
  { label: 'English', code: 'en-IN' },
  { label: 'हिंदी', code: 'hi-IN' },
  { label: 'தமிழ்', code: 'ta-IN' },
];

const BASE_AYUSH_FACTORS: [string, string][] = [
  ['Prakriti', 'Vata–Pitta'],
  ['Vikriti', 'Pitta ↑'],
  ['Sara', 'Madhyama'],
  ['Samhanana', 'Madhyama'],
  ['Pramana', 'Balanced'],
  ['Satmya', 'Mixed'],
  ['Sattva', 'Madhyama'],
  ['Ahara Shakti', 'Moderate'],
  ['Vyayama Shakti', 'Moderate'],
  ['Vaya', 'Madhyama'],
  ['Agni', 'Vishama'],
  ['Koshtha', 'Mridu'],
  ['Ahara-Vihara', 'Irregular meals'],
  ['Nidana', 'Spicy food'],
  ['Samprapti', 'Under review'],
];

const INITIAL_MESSAGES: Message[] = [
  {
    id: 'm1',
    role: 'assistant',
    text: 'Namaste, Arjun. Tell me what you are experiencing today. You can tap the microphone and speak naturally; I will ask focused follow-up questions.',
    time: 'Now',
    mode: 'text',
  },
];

function nowTime() {
  return new Intl.DateTimeFormat('en-IN', { hour: 'numeric', minute: '2-digit' }).format(new Date());
}

function isCritical(text: string) {
  return /trouble breathing|difficulty breathing|breathless|faint|unconscious|severe bleeding|suicid|stroke/i.test(text);
}

function getAdaptiveReply(text: string, language: Language): { text: string; critical: boolean } {
  const critical = isCritical(text);
  if (critical) {
    if (language === 'हिंदी') return { text: 'यह आपातकालीन स्थिति हो सकती है। कृपया अभी 112 पर कॉल करें या नज़दीकी इमरजेंसी विभाग जाएँ। क्या आप तुरंत डॉक्टर से जुड़ना चाहेंगे?', critical };
    if (language === 'தமிழ்') return { text: 'இது அவசர நிலையாக இருக்கலாம். இப்போதே 112 ஐ அழைக்கவும் அல்லது அருகிலுள்ள அவசர சிகிச்சைப் பிரிவுக்குச் செல்லவும். உடனடியாக மருத்துவரை இணைக்கவா?', critical };
    return { text: 'This may be an emergency. Please call 112 now or go to the nearest emergency department. Would you like me to connect you to an available doctor immediately?', critical };
  }
  if (/fever|temperature|बुखार|காய்ச்சல்/i.test(text)) {
    if (language === 'हिंदी') return { text: 'आपका सबसे अधिक तापमान कितना रहा और बुखार कब शुरू हुआ? क्या साथ में दाने, गर्दन में अकड़न या साँस लेने में तकलीफ़ है?', critical };
    if (language === 'தமிழ்') return { text: 'அதிகபட்ச வெப்பநிலை என்ன, காய்ச்சல் எப்போது தொடங்கியது? சொறி, கழுத்து விறைப்பு அல்லது மூச்சுத் திணறல் உள்ளதா?', critical };
    return { text: 'What was your highest measured temperature, and when did the fever begin? Do you also have a rash, stiff neck, or breathing difficulty?', critical };
  }
  if (/stomach|burn|acid|पेट|எரிச்சல்/i.test(text)) {
    if (language === 'हिंदी') return { text: 'क्या जलन खाने के बाद या लेटने पर बढ़ती है? आज आपने क्या खाया, और क्या उल्टी, काला मल या तेज़ दर्द भी है?', critical };
    if (language === 'தமிழ்') return { text: 'சாப்பிட்ட பிறகு அல்லது படுத்தால் எரிச்சல் அதிகரிக்கிறதா? இன்று என்ன சாப்பிட்டீர்கள்? வாந்தி, கருப்பு மலம் அல்லது கடுமையான வலி உள்ளதா?', critical };
    return { text: 'Does the burning increase after food or when you lie down? What did you eat today, and is there vomiting, black stool, or severe pain?', critical };
  }
  if (/head|headache|सिर|தலை/i.test(text)) {
    if (language === 'हिंदी') return { text: 'दर्द अचानक शुरू हुआ या धीरे-धीरे? दर्द 0 से 10 में कितना है, और क्या धुंधला दिखना, कमजोरी या उल्टी है?', critical };
    if (language === 'தமிழ்') return { text: 'வலி திடீரென்று தொடங்கியதா? 0 முதல் 10 வரை எவ்வளவு வலி? பார்வை மங்கல், பலவீனம் அல்லது வாந்தி உள்ளதா?', critical };
    return { text: 'Did it begin suddenly or gradually? How severe is it from 0 to 10, and do you have blurred vision, weakness, or vomiting?', critical };
  }
  if (language === 'हिंदी') return { text: 'समझ गया। यह कब शुरू हुआ, इसकी तीव्रता 0 से 10 में कितनी है, और क्या कोई चीज़ इसे बेहतर या बदतर करती है?', critical };
  if (language === 'தமிழ்') return { text: 'புரிகிறது. இது எப்போது தொடங்கியது, 0 முதல் 10 வரை எவ்வளவு தீவிரம், எது இதை குறைக்கிறது அல்லது அதிகரிக்கிறது?', critical };
  return { text: 'I understand. When did this start, how intense is it from 0 to 10, and does anything make it better or worse?', critical };
}

export default function ChatScreen({ navigation }: Props) {
  const theme = useAppTheme();
  const { colors } = theme;
  const [language, setLanguage] = useState<Language>('English');
  const [messages, setMessages] = useState<Message[]>(INITIAL_MESSAGES);
  const [input, setInput] = useState('');
  const [typing, setTyping] = useState(false);
  const [criticalActive, setCriticalActive] = useState(false);
  const [ayushVisible, setAyushVisible] = useState(false);
  const [demoStep, setDemoStep] = useState(0);
  const [responseTab, setResponseTab] = useState<'quick' | 'free'>('quick');
  const listRef = useRef<FlatList<Message>>(null);
  const recorder = useAudioRecorder(RecordingPresets.HIGH_QUALITY);
  const recorderState = useAudioRecorderState(recorder);
  const micScale = useSharedValue(1);
  micScale.value = recorderState.isRecording ? withRepeat(withTiming(1.18, { duration: 550 }), -1, true) : withTiming(1);
  const micAnimated = useAnimatedStyle(() => ({ transform: [{ scale: micScale.value }] }));

  const languageCode = useMemo(() => LANGUAGES.find((item) => item.label === language)?.code ?? 'en-IN', [language]);
  const ayushFactors = useMemo(() => BASE_AYUSH_FACTORS.map(([label, value]) => {
    if (demoStep >= 3 && label === 'Nidana') return [label, 'Chest pain + diaphoresis'];
    if (demoStep >= 3 && label === 'Samprapti') return [label, 'Red-flag triage active'];
    if (demoStep >= 2 && label === 'Sattva') return [label, 'Alert · responsive'];
    if (demoStep >= 2 && label === 'Vyayama Shakti') return [label, 'Exertion not advised'];
    if (demoStep >= 1 && label === 'Vikriti') return [label, 'Acute change detected'];
    if (demoStep >= 1 && label === 'Ahara-Vihara') return [label, 'Live intake pending'];
    return [label, value];
  }), [demoStep]);
  const quickOptions = demoStep === 1
    ? ['Pressure / tightness · 8/10', 'Burning discomfort · 5/10', 'Sharp pain · 6/10', 'Not sure']
    : demoStep === 2
      ? ['Sweating and breathlessness', 'Sweating only', 'Breathlessness only', 'Neither']
      : [];
  const timelineItems = useMemo(() => {
    const items = [['Now', 'Secure conversation started']];
    if (demoStep >= 1) items.push(['Voice', 'Chest pain reported']);
    if (demoStep >= 2) items.push(['MCQ', 'Pain pattern captured']);
    if (demoStep >= 3) items.push(['Alert', 'Red flag received by triage']);
    return items.slice(-3);
  }, [demoStep]);

  const submitMessage = useCallback(
    (raw: string, mode: ConversationMode) => {
      const text = raw.trim();
      if (!text || typing) return;
      const userMessage: Message = { id: `u-${Date.now()}`, role: 'user', text, time: nowTime(), mode };
      setMessages((current) => [...current, userMessage]);
      setInput('');
      setTyping(true);
      setTimeout(() => {
        let reply = getAdaptiveReply(text, language);
        let nextStep = demoStep;
        if (demoStep === 0 && /chest|सीने|நெஞ்சு/i.test(text)) {
          nextStep = 1;
          reply = language === 'हिंदी'
            ? { text: 'मैं समझता हूँ। दर्द कब शुरू हुआ? क्या यह दबाव, जलन या चुभन जैसा है, और 0 से 10 में कितना तेज़ है?', critical: false }
            : language === 'தமிழ்'
              ? { text: 'புரிகிறது. வலி எப்போது தொடங்கியது? அழுத்தம், எரிச்சல் அல்லது கூர்மையான வலி போல உள்ளதா? 0 முதல் 10 வரை எவ்வளவு?', critical: false }
              : { text: 'I understand. When did it start? Does it feel like pressure, burning, or a sharp pain, and how severe is it from 0 to 10?', critical: false };
        } else if (demoStep === 1) {
          nextStep = 2;
          reply = language === 'हिंदी'
            ? { text: 'धन्यवाद। क्या आपको पसीना, साँस फूलना, मतली, या दर्द का बाँह या जबड़े तक फैलना महसूस हो रहा है?', critical: false }
            : language === 'தமிழ்'
              ? { text: 'நன்றி. வியர்வை, மூச்சுத் திணறல், குமட்டல், அல்லது கை அல்லது தாடைக்கு பரவும் வலி உள்ளதா?', critical: false }
              : { text: 'Thank you. Are you also sweating, short of breath, nauseated, or feeling pain spreading to your arm or jaw?', critical: false };
        } else if (demoStep === 2 && /sweat|breath|पसीना|साँस|வியர்வை|மூச்சு/i.test(text)) {
          nextStep = 3;
          reply = language === 'हिंदी'
            ? { text: 'रेड-फ्लैग चेतावनी: सीने में दर्द, पसीना और साँस फूलना आपात स्थिति के संकेत हो सकते हैं। 112 पर कॉल करें। आपकी सहमति के अनुसार ट्रायेज टीम को अलर्ट भेज दिया गया है।', critical: true }
            : language === 'தமிழ்'
              ? { text: 'சிவப்பு எச்சரிக்கை: நெஞ்சுவலி, வியர்வை மற்றும் மூச்சுத் திணறல் அவசர அறிகுறிகளாக இருக்கலாம். 112 ஐ அழைக்கவும். உங்கள் ஒப்புதலின்படி triage குழுவிற்கு எச்சரிக்கை அனுப்பப்பட்டது.', critical: true }
              : { text: 'Red-flag alert: chest pain with sweating and breathlessness can signal an emergency. Call 112 now. With your consent, the triage team has been alerted.', critical: true };
        }
        const assistant: Message = { id: `a-${Date.now()}`, role: 'assistant', text: reply.text, time: nowTime(), mode, critical: reply.critical };
        setMessages((current) => [...current, assistant]);
        setDemoStep(nextStep);
        setResponseTab('quick');
        setTyping(false);
        setCriticalActive(reply.critical);
        if (mode === 'voice') Speech.speak(reply.text, { language: languageCode, rate: 0.92 });
        setTimeout(() => listRef.current?.scrollToEnd({ animated: true }), 120);
      }, 750);
      setTimeout(() => listRef.current?.scrollToEnd({ animated: true }), 120);
    },
    [demoStep, language, languageCode, typing],
  );

  const handleVoice = async () => {
    if (recorderState.isRecording) {
      await recorder.stop();
      const transcript = demoStep === 0
        ? language === 'हिंदी' ? 'मेरे सीने में तेज़ दर्द हो रहा है।' : language === 'தமிழ்' ? 'எனக்கு கடுமையான நெஞ்சுவலி உள்ளது.' : 'I am having crushing chest pain.'
        : demoStep === 1
          ? language === 'हिंदी' ? 'दबाव जैसा दर्द है, आठ में से दस।' : language === 'தமிழ்' ? 'அழுத்தம் போல உள்ளது, பத்தில் எட்டு.' : 'It feels like heavy pressure, about 8 out of 10.'
          : language === 'हिंदी' ? 'मुझे पसीना आ रहा है और साँस फूल रही है।' : language === 'தமிழ்' ? 'எனக்கு வியர்வையும் மூச்சுத் திணறலும் உள்ளது.' : 'I am sweating and feeling breathless.';
      submitMessage(transcript, 'voice');
      return;
    }
    const permission = await requestRecordingPermissionsAsync();
    if (!permission.granted) {
      Alert.alert('Microphone access needed', 'Allow microphone access to continue a voice conversation.');
      return;
    }
    await setAudioModeAsync({ allowsRecording: true, playsInSilentMode: true });
    await recorder.prepareToRecordAsync();
    recorder.record();
  };

  const bookUrgent = () => navigation.navigate('Appointments', { startBooking: true, urgent: true, nonce: Date.now() });
  const bookRegular = () => navigation.navigate('Appointments', { startBooking: true, urgent: false, nonce: Date.now() });

  const openEmergencyCall = async () => {
    const url = 'tel:112';
    if (await Linking.canOpenURL(url)) await Linking.openURL(url);
    else Alert.alert('Emergency number', 'Call 112 now for emergency help.');
  };

  const renderHeader = () => (
    <View>
      <View style={[styles.assistantCard, { backgroundColor: colors.surface, borderColor: colors.line, shadowColor: colors.shadow }]}>
        <View style={styles.assistantTop}>
          <InitialAvatar initials="VA" color={colors.primary} size={46} />
          <View style={styles.assistantCopy}>
            <View style={styles.onlineRow}>
              <Text style={[styles.assistantName, { color: colors.text }]}>Vitala Health Guide</Text>
              <View style={[styles.onlineDot, { backgroundColor: colors.primary }]} />
            </View>
            <Text style={[styles.assistantMeta, { color: colors.muted }]}>Clinical + AYUSH guidance · available now</Text>
          </View>
        </View>
        <View style={[styles.disclaimer, { backgroundColor: colors.surfaceAlt }]}>
          <Ionicons name="shield-checkmark-outline" size={16} color={colors.primary} />
          <Text style={[styles.disclaimerText, { color: colors.muted }]}>Guidance supports—not replaces—care from a qualified clinician.</Text>
        </View>
      </View>

      <View style={styles.languageRow}>
        <Text style={[styles.controlLabel, { color: colors.muted }]}>CONVERSATION LANGUAGE</Text>
        <View style={styles.pillRow}>
          {LANGUAGES.map((item) => {
            const active = item.label === language;
            return (
              <Pressable
                key={item.label}
                onPress={() => setLanguage(item.label)}
                style={[styles.languagePill, { backgroundColor: active ? colors.primary : colors.surface, borderColor: active ? colors.primary : colors.line }]}
              >
                <Text style={[styles.languageText, { color: active ? '#FFFFFF' : colors.text }]}>{item.label}</Text>
              </Pressable>
            );
          })}
        </View>
      </View>

      <View style={styles.sectionWrap}>
        <SectionTitle title="Your AYUSH lens" detail={demoStep ? 'Live context · updated just now' : '15-point baseline · listening for changes'} theme={theme} action="View all" onAction={() => setAyushVisible(true)} />
        <Pressable onPress={() => setAyushVisible(true)} style={[styles.ayushCard, { backgroundColor: colors.primarySoft, borderColor: colors.primary + '25' }]}>
          <View style={styles.ayushSummary}>
            <View>
              <Text style={[styles.ayushType, { color: colors.primary }]}>VATA–PITTA PRAKRITI</Text>
              <Text style={[styles.ayushTitle, { color: colors.text }]}>{demoStep >= 3 ? 'Acute pattern sent to triage' : demoStep >= 1 ? 'Live symptom context updating' : 'Pitta is currently elevated'}</Text>
            </View>
            <View style={[styles.leafIcon, { backgroundColor: colors.surface }]}><Ionicons name="leaf-outline" size={20} color={colors.primary} /></View>
          </View>
          <FlatList
            data={ayushFactors}
            horizontal
            showsHorizontalScrollIndicator={false}
            keyExtractor={(item) => item[0]}
            renderItem={({ item }) => (
              <View style={[styles.factorChip, { backgroundColor: colors.surface, borderColor: colors.line }]}>
                <Text style={[styles.factorLabel, { color: colors.muted }]}>{item[0]}</Text>
                <Text style={[styles.factorValue, { color: colors.text }]}>{item[1]}</Text>
              </View>
            )}
          />
          <View style={styles.viewAllRow}>
            <Text style={[styles.viewAllText, { color: colors.primary }]}>{demoStep ? 'Live · conversation signals merged with baseline' : 'Prakriti to Samprapti · baseline captured'}</Text>
            <Ionicons name="chevron-forward" size={16} color={colors.primary} />
          </View>
        </Pressable>
      </View>

      <View style={styles.sectionWrap}>
        <SectionTitle title="Conversation" detail="Today · 7 min" theme={theme} />
        <View style={[styles.timelineCard, { borderColor: colors.line, backgroundColor: colors.surface }]}>
          {timelineItems.map((item, index) => (
            <View key={item[0]} style={styles.timelineRow}>
              <View style={styles.timelineRail}>
                <View style={[styles.timelineDot, { backgroundColor: index === 2 ? colors.primary : colors.line }]} />
                {index < timelineItems.length - 1 && <View style={[styles.timelineLine, { backgroundColor: colors.line }]} />}
              </View>
              <Text style={[styles.timelineTime, { color: colors.subtle }]}>{item[0]}</Text>
              <Text style={[styles.timelineText, { color: colors.text }]}>{item[1]}</Text>
            </View>
          ))}
        </View>
      </View>
      <View style={[styles.dayDivider, { backgroundColor: colors.canvas }]}><Text style={[styles.dayText, { color: colors.subtle }]}>TODAY</Text></View>
    </View>
  );

  const renderMessage = ({ item }: { item: Message }) => {
    const mine = item.role === 'user';
    return (
      <View style={[styles.messageRow, mine && styles.messageRowMine]}>
        {!mine && <View style={[styles.botMini, { backgroundColor: colors.primarySoft }]}><Ionicons name="sparkles" size={14} color={colors.primary} /></View>}
        <View style={styles.messageContent}>
          <View
            style={[
              styles.bubble,
              mine ? { backgroundColor: colors.primary } : { backgroundColor: item.critical ? colors.dangerSoft : colors.surface, borderColor: item.critical ? colors.danger + '45' : colors.line, borderWidth: 1 },
            ]}
          >
            <Text style={[styles.bubbleText, { color: mine ? '#FFFFFF' : colors.text }]}>{item.text}</Text>
            {item.mode === 'voice' && (
              <View style={styles.voiceMeta}>
                <Ionicons name="volume-medium" size={14} color={mine ? '#D8F7EF' : colors.primary} />
                <Text style={[styles.voiceMetaText, { color: mine ? '#D8F7EF' : colors.primary }]}>Voice</Text>
              </View>
            )}
          </View>
          <View style={[styles.messageMeta, mine && { justifyContent: 'flex-end' }]}>
            <Text style={[styles.messageTime, { color: colors.subtle }]}>{item.time}</Text>
            {!mine && (
              <Pressable onPress={() => Speech.speak(item.text, { language: languageCode, rate: 0.92 })} hitSlop={8}>
                <Ionicons name="volume-low-outline" size={17} color={colors.subtle} />
              </Pressable>
            )}
          </View>
        </View>
      </View>
    );
  };

  return (
    <SafeAreaView style={[styles.safe, { backgroundColor: colors.canvas }]} edges={['top']}>
      <KeyboardAvoidingView style={styles.flex} behavior={Platform.OS === 'ios' ? 'padding' : undefined} keyboardVerticalOffset={0}>
        <AppHeader eyebrow="Vitala Care" title="Chat & analysis" subtitle="Ask naturally. Understand clearly." theme={theme} onAction={() => Alert.alert('You’re all caught up', 'No new health alerts or care reminders.')} />
        <FlatList
          ref={listRef}
          data={messages}
          renderItem={renderMessage}
          keyExtractor={(item) => item.id}
          ListHeaderComponent={renderHeader}
          ListFooterComponent={
            <View>
              {typing && (
                <View style={styles.typingRow}>
                  <View style={[styles.botMini, { backgroundColor: colors.primarySoft }]}><Ionicons name="sparkles" size={14} color={colors.primary} /></View>
                  <View style={[styles.typingBubble, { backgroundColor: colors.surface, borderColor: colors.line }]}>
                    <View style={[styles.typingDot, { backgroundColor: colors.subtle }]} /><View style={[styles.typingDot, { backgroundColor: colors.subtle }]} /><View style={[styles.typingDot, { backgroundColor: colors.subtle }]} />
                  </View>
                </View>
              )}
              {criticalActive && (
                <View style={[styles.urgentCard, { backgroundColor: colors.dangerSoft, borderColor: colors.danger + '55' }]}>
                  <View style={styles.urgentHeading}>
                    <View style={[styles.urgentIcon, { backgroundColor: colors.danger }]}><Ionicons name="alert" size={20} color="#FFFFFF" /></View>
                    <View style={styles.urgentCopy}>
                      <Text style={[styles.urgentTitle, { color: colors.text }]}>Urgent help recommended</Text>
                      <Text style={[styles.urgentText, { color: colors.muted }]}>Do not wait for an app response if symptoms are severe.</Text>
                    </View>
                  </View>
                  <View style={[styles.triageReceipt, { backgroundColor: colors.surface, borderColor: colors.danger + '35' }]}>
                    <View style={[styles.receivedIcon, { backgroundColor: colors.primarySoft }]}><Ionicons name="checkmark-done" size={16} color={colors.primary} /></View>
                    <View style={styles.receivedCopy}><Text style={[styles.receivedTitle, { color: colors.text }]}>Received by triage staff</Text><Text style={[styles.receivedText, { color: colors.muted }]}>Nurse A. Singh · Alert VF-2048 · just now</Text></View>
                    <View style={[styles.liveBadge, { backgroundColor: colors.danger }]}><Text style={styles.liveBadgeText}>LIVE</Text></View>
                  </View>
                  <View style={styles.urgentActions}>
                    <Pressable onPress={openEmergencyCall} style={[styles.urgentButton, { backgroundColor: colors.danger }]}><Ionicons name="call" size={17} color="#FFF" /><Text style={styles.urgentButtonText}>Call 112</Text></Pressable>
                    <Pressable onPress={bookUrgent} style={[styles.urgentButton, { backgroundColor: colors.surface, borderColor: colors.danger, borderWidth: 1 }]}><Ionicons name="videocam" size={17} color={colors.danger} /><Text style={[styles.urgentButtonText, { color: colors.danger }]}>Doctor now</Text></Pressable>
                  </View>
                  <Pressable onPress={() => navigation.navigate('History')} style={[styles.addReportButton, { borderColor: colors.danger + '45' }]}><Ionicons name="scan-outline" size={17} color={colors.danger} /><Text style={[styles.addReportText, { color: colors.danger }]}>Scan previous lab report for triage</Text><Ionicons name="chevron-forward" size={16} color={colors.danger} /></Pressable>
                </View>
              )}
              <Pressable onPress={bookRegular} style={[styles.bookInline, { borderColor: colors.line, backgroundColor: colors.surface }]}>
                <View style={[styles.calendarIcon, { backgroundColor: colors.primarySoft }]}><Ionicons name="calendar-outline" size={18} color={colors.primary} /></View>
                <View style={styles.bookInlineCopy}><Text style={[styles.bookInlineTitle, { color: colors.text }]}>Want to speak with a doctor?</Text><Text style={[styles.bookInlineText, { color: colors.muted }]}>Book without leaving the conversation</Text></View>
                <Ionicons name="chevron-forward" size={20} color={colors.primary} />
              </Pressable>
            </View>
          }
          contentContainerStyle={styles.listContent}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        />

        {quickOptions.length > 0 && !criticalActive && (
          <View style={[styles.responsePanel, { backgroundColor: colors.surface, borderColor: colors.line }]}>
            <View style={[styles.responseTabs, { backgroundColor: colors.surfaceAlt }]}>
              <Pressable onPress={() => setResponseTab('quick')} style={[styles.responseTab, responseTab === 'quick' && { backgroundColor: colors.surface }]}><Ionicons name="list-outline" size={15} color={responseTab === 'quick' ? colors.primary : colors.muted} /><Text style={[styles.responseTabText, { color: responseTab === 'quick' ? colors.text : colors.muted }]}>Quick answers · MCQ</Text></Pressable>
              <Pressable onPress={() => setResponseTab('free')} style={[styles.responseTab, responseTab === 'free' && { backgroundColor: colors.surface }]}><Ionicons name="create-outline" size={15} color={responseTab === 'free' ? colors.primary : colors.muted} /><Text style={[styles.responseTabText, { color: responseTab === 'free' ? colors.text : colors.muted }]}>Type / voice</Text></Pressable>
            </View>
            {responseTab === 'quick' && <View style={styles.quickAnswerGrid}>{quickOptions.map((option) => <Pressable key={option} onPress={() => submitMessage(option, 'text')} style={[styles.quickAnswer, { backgroundColor: colors.primarySoft, borderColor: colors.primary + '35' }]}><Text style={[styles.quickAnswerText, { color: colors.text }]}>{option}</Text><Ionicons name="chevron-forward" size={15} color={colors.primary} /></Pressable>)}</View>}
            {responseTab === 'free' && <Text style={[styles.freeHint, { color: colors.muted }]}>Use the field below, or tap the microphone to answer in your selected language.</Text>}
          </View>
        )}

        {recorderState.isRecording && (
          <View style={[styles.recordingBar, { backgroundColor: colors.dangerSoft }]}>
            <View style={[styles.recordDot, { backgroundColor: colors.danger }]} />
            <Text style={[styles.recordingText, { color: colors.danger }]}>Listening · {Math.max(1, Math.round(recorderState.durationMillis / 1000))}s</Text>
            <Text style={[styles.recordingHint, { color: colors.muted }]}>Tap mic to send</Text>
          </View>
        )}
        <View style={[styles.composer, { backgroundColor: colors.surface, borderColor: colors.line }]}>
          <Pressable accessibilityLabel="Attach a medical record" onPress={() => navigation.navigate('History')} style={styles.attachButton}>
            <Ionicons name="attach-outline" size={25} color={colors.muted} />
          </Pressable>
          <TextInput
            value={input}
            onChangeText={setInput}
            onSubmitEditing={() => submitMessage(input, 'text')}
            placeholder={`Message in ${language}`}
            placeholderTextColor={colors.subtle}
            style={[styles.input, { color: colors.text }]}
            returnKeyType="send"
            multiline
          />
          {!!input.trim() ? (
            <Pressable onPress={() => submitMessage(input, 'text')} style={[styles.sendButton, { backgroundColor: colors.primary }]}><Ionicons name="arrow-up" size={21} color="#FFFFFF" /></Pressable>
          ) : (
            <Animated.View style={micAnimated}>
              <Pressable onPress={handleVoice} style={[styles.sendButton, { backgroundColor: recorderState.isRecording ? colors.danger : colors.primarySoft }]}>
                <Ionicons name={recorderState.isRecording ? 'stop' : 'mic'} size={21} color={recorderState.isRecording ? '#FFFFFF' : colors.primary} />
              </Pressable>
            </Animated.View>
          )}
        </View>
      </KeyboardAvoidingView>

      <Modal visible={ayushVisible} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setAyushVisible(false)}>
        <SafeAreaView style={[styles.modalSafe, { backgroundColor: colors.canvas }]}>
          <View style={[styles.modalHeader, { borderColor: colors.line }]}>
            <View><Text style={[styles.modalEyebrow, { color: colors.primary }]}>AYUSH ASSESSMENT</Text><Text style={[styles.modalTitle, { color: colors.text }]}>Your health lens</Text></View>
            <Pressable onPress={() => setAyushVisible(false)} style={[styles.closeButton, { backgroundColor: colors.surfaceAlt }]}><Ionicons name="close" size={22} color={colors.text} /></Pressable>
          </View>
          <FlatList
            data={ayushFactors}
            keyExtractor={(item) => item[0]}
            numColumns={2}
            columnWrapperStyle={styles.factorGridRow}
            contentContainerStyle={styles.factorGrid}
            ListHeaderComponent={<View style={[styles.ayushIntro, { backgroundColor: colors.primarySoft }]}><Ionicons name="pulse" size={24} color={colors.primary} /><Text style={[styles.ayushIntroText, { color: colors.text }]}>{demoStep ? 'Live symptom signals are updating Nidana, Sattva, Vikriti, Vyayama Shakti, and Samprapti in real time.' : 'Baseline clinician observations are ready to merge with the live conversation. This is not a diagnosis.'}</Text></View>}
            renderItem={({ item }) => (
              <View style={[styles.factorTile, { backgroundColor: colors.surface, borderColor: colors.line }]}>
                <Text style={[styles.factorTileLabel, { color: colors.muted }]}>{item[0]}</Text>
                <Text style={[styles.factorTileValue, { color: colors.text }]}>{item[1]}</Text>
                <Text style={[styles.factorSource, { color: colors.subtle }]}>{demoStep && ['Nidana', 'Samprapti', 'Sattva', 'Vikriti', 'Vyayama Shakti', 'Ahara-Vihara'].includes(item[0]) ? 'Live conversation signal' : 'Clinician-reviewed baseline'}</Text>
              </View>
            )}
          />
        </SafeAreaView>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1 },
  flex: { flex: 1 },
  listContent: { paddingHorizontal: 20, paddingBottom: 14 },
  assistantCard: { borderRadius: 22, padding: 16, borderWidth: 1, shadowOpacity: 0.07, shadowRadius: 16, shadowOffset: { width: 0, height: 8 }, elevation: 2 },
  assistantTop: { flexDirection: 'row', alignItems: 'center' },
  assistantCopy: { flex: 1, marginLeft: 12 },
  onlineRow: { flexDirection: 'row', alignItems: 'center', gap: 7 },
  onlineDot: { width: 7, height: 7, borderRadius: 4 },
  assistantName: { fontSize: 16, fontWeight: '800' },
  assistantMeta: { fontSize: 12, marginTop: 3 },
  disclaimer: { marginTop: 14, padding: 10, borderRadius: 12, flexDirection: 'row', alignItems: 'center', gap: 8 },
  disclaimerText: { flex: 1, fontSize: 11.5, lineHeight: 16 },
  languageRow: { marginTop: 20 },
  controlLabel: { fontSize: 10, letterSpacing: 1.2, fontWeight: '800', marginBottom: 9 },
  pillRow: { flexDirection: 'row', gap: 8 },
  languagePill: { borderRadius: 999, borderWidth: 1, paddingHorizontal: 14, paddingVertical: 9 },
  languageText: { fontSize: 12, fontWeight: '800' },
  sectionWrap: { marginTop: 26 },
  ayushCard: { borderRadius: 22, padding: 16, borderWidth: 1 },
  ayushSummary: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 },
  ayushType: { fontSize: 10, fontWeight: '900', letterSpacing: 1 },
  ayushTitle: { fontSize: 17, fontWeight: '800', marginTop: 4 },
  leafIcon: { width: 38, height: 38, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  factorChip: { borderWidth: 1, borderRadius: 14, paddingHorizontal: 12, paddingVertical: 9, marginRight: 8, minWidth: 105 },
  factorLabel: { fontSize: 10, fontWeight: '700' },
  factorValue: { fontSize: 13, fontWeight: '800', marginTop: 3 },
  viewAllRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginTop: 13 },
  viewAllText: { fontSize: 11.5, fontWeight: '700' },
  timelineCard: { borderWidth: 1, borderRadius: 18, paddingHorizontal: 14, paddingVertical: 12 },
  timelineRow: { minHeight: 34, flexDirection: 'row', alignItems: 'flex-start' },
  timelineRail: { width: 16, height: 34, alignItems: 'center' },
  timelineDot: { width: 8, height: 8, borderRadius: 4, marginTop: 4, zIndex: 2 },
  timelineLine: { position: 'absolute', width: 1.5, height: 28, top: 9 },
  timelineTime: { width: 46, fontSize: 11, paddingTop: 1 },
  timelineText: { flex: 1, fontSize: 12.5, fontWeight: '600' },
  dayDivider: { alignItems: 'center', marginTop: 22, marginBottom: 14 },
  dayText: { fontSize: 10, fontWeight: '900', letterSpacing: 1.4 },
  messageRow: { flexDirection: 'row', alignItems: 'flex-start', marginBottom: 15, paddingRight: 36 },
  messageRowMine: { justifyContent: 'flex-end', paddingRight: 0, paddingLeft: 54 },
  botMini: { width: 30, height: 30, borderRadius: 11, alignItems: 'center', justifyContent: 'center', marginRight: 8 },
  messageContent: { maxWidth: '92%' },
  bubble: { borderRadius: 18, borderTopLeftRadius: 6, paddingHorizontal: 14, paddingVertical: 11 },
  bubbleText: { fontSize: 14, lineHeight: 20 },
  voiceMeta: { flexDirection: 'row', gap: 4, alignItems: 'center', marginTop: 7 },
  voiceMetaText: { fontSize: 10, fontWeight: '800' },
  messageMeta: { flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 5 },
  messageTime: { fontSize: 10 },
  typingRow: { flexDirection: 'row', marginBottom: 14 },
  typingBubble: { flexDirection: 'row', gap: 4, paddingHorizontal: 14, paddingVertical: 13, borderRadius: 16, borderTopLeftRadius: 6, borderWidth: 1 },
  typingDot: { width: 5, height: 5, borderRadius: 3 },
  urgentCard: { borderWidth: 1, borderRadius: 20, padding: 15, marginTop: 3, marginBottom: 14 },
  urgentHeading: { flexDirection: 'row', alignItems: 'center' },
  urgentIcon: { width: 38, height: 38, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  urgentCopy: { flex: 1, marginLeft: 10 },
  urgentTitle: { fontSize: 15, fontWeight: '900' },
  urgentText: { fontSize: 11.5, lineHeight: 16, marginTop: 2 },
  triageReceipt: { borderWidth: 1, borderRadius: 14, padding: 10, marginTop: 13, flexDirection: 'row', alignItems: 'center' },
  receivedIcon: { width: 30, height: 30, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
  receivedCopy: { flex: 1, marginLeft: 8 },
  receivedTitle: { fontSize: 11.5, fontWeight: '900' },
  receivedText: { fontSize: 9.5, marginTop: 2 },
  liveBadge: { borderRadius: 999, paddingHorizontal: 6, paddingVertical: 4 },
  liveBadgeText: { color: '#FFFFFF', fontSize: 7.5, fontWeight: '900', letterSpacing: 0.7 },
  urgentActions: { flexDirection: 'row', gap: 9, marginTop: 13 },
  urgentButton: { flex: 1, height: 42, borderRadius: 13, alignItems: 'center', justifyContent: 'center', flexDirection: 'row', gap: 7 },
  urgentButtonText: { color: '#FFFFFF', fontSize: 12, fontWeight: '900' },
  addReportButton: { height: 40, borderTopWidth: 1, marginTop: 10, paddingTop: 9, flexDirection: 'row', alignItems: 'center', gap: 7 },
  addReportText: { flex: 1, fontSize: 11, fontWeight: '900' },
  bookInline: { borderWidth: 1, borderRadius: 17, padding: 12, flexDirection: 'row', alignItems: 'center', marginTop: 4 },
  calendarIcon: { width: 38, height: 38, borderRadius: 13, alignItems: 'center', justifyContent: 'center' },
  bookInlineCopy: { flex: 1, marginLeft: 10 },
  bookInlineTitle: { fontSize: 13, fontWeight: '800' },
  bookInlineText: { fontSize: 11, marginTop: 2 },
  responsePanel: { marginHorizontal: 12, marginBottom: 3, borderRadius: 18, borderWidth: 1, padding: 7 },
  responseTabs: { flexDirection: 'row', padding: 3, borderRadius: 12 },
  responseTab: { flex: 1, height: 33, borderRadius: 10, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 5 },
  responseTabText: { fontSize: 10.5, fontWeight: '800' },
  quickAnswerGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 6, paddingTop: 8 },
  quickAnswer: { width: '49%', minHeight: 40, borderWidth: 1, borderRadius: 12, paddingHorizontal: 9, paddingVertical: 7, flexDirection: 'row', alignItems: 'center' },
  quickAnswerText: { flex: 1, fontSize: 10.5, lineHeight: 14, fontWeight: '700' },
  freeHint: { fontSize: 10.5, lineHeight: 15, paddingHorizontal: 7, paddingTop: 9, paddingBottom: 4 },
  recordingBar: { marginHorizontal: 20, borderRadius: 12, paddingHorizontal: 12, paddingVertical: 8, flexDirection: 'row', alignItems: 'center' },
  recordDot: { width: 7, height: 7, borderRadius: 4, marginRight: 7 },
  recordingText: { fontSize: 12, fontWeight: '800' },
  recordingHint: { fontSize: 11, marginLeft: 'auto' },
  composer: { margin: 12, marginTop: 8, minHeight: 56, borderRadius: 20, borderWidth: 1, flexDirection: 'row', alignItems: 'center', paddingHorizontal: 8, paddingVertical: 6, shadowColor: '#163D34', shadowOpacity: 0.08, shadowRadius: 14, shadowOffset: { width: 0, height: 5 }, elevation: 4 },
  attachButton: { width: 38, alignItems: 'center', justifyContent: 'center' },
  input: { flex: 1, maxHeight: 90, minHeight: 40, paddingHorizontal: 5, paddingVertical: 9, fontSize: 14 },
  sendButton: { width: 42, height: 42, borderRadius: 15, alignItems: 'center', justifyContent: 'center' },
  modalSafe: { flex: 1 },
  modalHeader: { paddingHorizontal: 20, paddingVertical: 14, borderBottomWidth: 1, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  modalEyebrow: { fontSize: 10, fontWeight: '900', letterSpacing: 1.2 },
  modalTitle: { fontSize: 26, fontWeight: '900', marginTop: 3 },
  closeButton: { width: 40, height: 40, borderRadius: 15, alignItems: 'center', justifyContent: 'center' },
  factorGrid: { padding: 20, paddingBottom: 40 },
  factorGridRow: { gap: 10 },
  ayushIntro: { borderRadius: 18, padding: 15, flexDirection: 'row', gap: 12, marginBottom: 16, alignItems: 'center' },
  ayushIntroText: { flex: 1, fontSize: 13, lineHeight: 19, fontWeight: '600' },
  factorTile: { width: '48.5%', borderWidth: 1, borderRadius: 17, padding: 14, marginBottom: 10 },
  factorTileLabel: { fontSize: 11, fontWeight: '700' },
  factorTileValue: { fontSize: 15, fontWeight: '900', marginTop: 5 },
  factorSource: { fontSize: 9.5, marginTop: 9 },
});
