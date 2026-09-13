import Ionicons from '@expo/vector-icons/Ionicons';
import { LinearGradient } from 'expo-linear-gradient';
import React, { useState } from 'react';
import { FlatList, KeyboardAvoidingView, Platform, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import Animated, { FadeIn, FadeInDown, ZoomIn } from 'react-native-reanimated';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAppTheme } from '../lib/theme';

export type IdentityMethod = 'Mobile OTP' | 'Aadhaar' | 'DigiLocker' | 'ABDM Health ID';

export function SplashScreen() {
  return (
    <LinearGradient colors={['#087368', '#064F48']} style={styles.splash}>
      <Animated.View entering={ZoomIn.duration(650)} style={styles.splashMark}>
        <Ionicons name="leaf" size={38} color="#0E7567" />
        <View style={styles.splashPulse}><Ionicons name="add" size={16} color="#FFFFFF" /></View>
      </Animated.View>
      <Animated.Text entering={FadeIn.delay(300).duration(550)} style={styles.splashName}>Vitala</Animated.Text>
      <Animated.Text entering={FadeIn.delay(500).duration(550)} style={styles.splashTag}>Care that understands the whole you</Animated.Text>
      <View style={styles.splashSecure}><Ionicons name="shield-checkmark-outline" size={14} color="#BEEDE3" /><Text style={styles.splashSecureText}>Private · Connected · Clinician supported</Text></View>
    </LinearGradient>
  );
}

export function LoginScreen({ onContinue }: { onContinue: (method: IdentityMethod) => void }) {
  const theme = useAppTheme();
  const { colors } = theme;
  const [mode, setMode] = useState<'Login' | 'Register'>('Login');
  const [name, setName] = useState('Arjun Rao');
  const [mobile, setMobile] = useState('98765 43210');

  const continueWithMobile = () => {
    if (!mobile.trim()) return;
    onContinue('Mobile OTP');
  };

  return (
    <SafeAreaView style={[styles.safe, { backgroundColor: colors.canvas }]}>
      <KeyboardAvoidingView style={styles.flex} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <FlatList
          data={[]}
          renderItem={null}
          keyboardShouldPersistTaps="handled"
          contentContainerStyle={styles.loginContent}
          ListHeaderComponent={
            <Animated.View entering={FadeInDown.duration(450)}>
              <View style={styles.brandRow}>
                <View style={[styles.brandMark, { backgroundColor: colors.primary }]}><Ionicons name="leaf" size={22} color="#FFFFFF" /></View>
                <Text style={[styles.brandName, { color: colors.text }]}>Vitala</Text>
                <View style={[styles.demoBadge, { backgroundColor: colors.primarySoft }]}><Text style={[styles.demoText, { color: colors.primary }]}>PATIENT DEMO</Text></View>
              </View>
              <Text style={[styles.welcomeTitle, { color: colors.text }]}>{mode === 'Login' ? 'Welcome back' : 'Create your account'}</Text>
              <Text style={[styles.welcomeText, { color: colors.muted }]}>One secure account for conversations, reports, AYUSH context, and appointments.</Text>

              <View style={[styles.authSwitch, { backgroundColor: colors.surfaceAlt }]}>
                {(['Login', 'Register'] as const).map((item) => <Pressable key={item} onPress={() => setMode(item)} style={[styles.authOption, mode === item && { backgroundColor: colors.surface }]}><Text style={[styles.authOptionText, { color: mode === item ? colors.text : colors.muted }]}>{item}</Text></Pressable>)}
              </View>

              {mode === 'Register' && <><Text style={[styles.fieldLabel, { color: colors.muted }]}>FULL NAME</Text><View style={[styles.inputShell, { backgroundColor: colors.surface, borderColor: colors.line }]}><Ionicons name="person-outline" size={19} color={colors.muted} /><TextInput value={name} onChangeText={setName} placeholder="Your full name" placeholderTextColor={colors.subtle} style={[styles.loginInput, { color: colors.text }]} returnKeyType="next" /></View></>}
              <Text style={[styles.fieldLabel, { color: colors.muted }]}>MOBILE NUMBER</Text>
              <View style={[styles.inputShell, { backgroundColor: colors.surface, borderColor: colors.line }]}><Text style={[styles.countryCode, { color: colors.text }]}>+91</Text><View style={[styles.inputDivider, { backgroundColor: colors.line }]} /><TextInput value={mobile} onChangeText={setMobile} placeholder="10-digit mobile number" placeholderTextColor={colors.subtle} keyboardType="phone-pad" style={[styles.loginInput, { color: colors.text }]} returnKeyType="done" onSubmitEditing={continueWithMobile} /></View>
              <Pressable disabled={!mobile.trim()} onPress={continueWithMobile} style={[styles.primaryButton, { backgroundColor: colors.primary }, !mobile.trim() && { opacity: 0.45 }]}><Text style={styles.primaryButtonText}>{mode === 'Login' ? 'Continue securely' : 'Register securely'}</Text><Ionicons name="arrow-forward" size={19} color="#FFFFFF" /></Pressable>

              <View style={styles.orRow}><View style={[styles.orLine, { backgroundColor: colors.line }]} /><Text style={[styles.orText, { color: colors.subtle }]}>OR USE A VERIFIED ID</Text><View style={[styles.orLine, { backgroundColor: colors.line }]} /></View>
              {[
                { method: 'Aadhaar' as const, icon: 'finger-print-outline' as const, title: 'Continue with Aadhaar', subtitle: 'Verify using Aadhaar OTP', tint: colors.blueSoft, color: colors.blue },
                { method: 'DigiLocker' as const, icon: 'folder-open-outline' as const, title: 'Continue with DigiLocker', subtitle: 'Import verified health documents', tint: colors.amberSoft, color: colors.amber },
                { method: 'ABDM Health ID' as const, icon: 'medical-outline' as const, title: 'Continue with ABDM', subtitle: 'Use your ABHA health identity', tint: colors.primarySoft, color: colors.primary },
              ].map((item) => <Pressable key={item.method} onPress={() => onContinue(item.method)} style={({ pressed }) => [styles.identityButton, { backgroundColor: colors.surface, borderColor: colors.line }, pressed && { opacity: 0.72 }]}><View style={[styles.identityIcon, { backgroundColor: item.tint }]}><Ionicons name={item.icon} size={21} color={item.color} /></View><View style={styles.identityCopy}><Text style={[styles.identityTitle, { color: colors.text }]}>{item.title}</Text><Text style={[styles.identitySubtitle, { color: colors.muted }]}>{item.subtitle}</Text></View><Ionicons name="chevron-forward" size={19} color={colors.subtle} /></Pressable>)}
              <Text style={[styles.legal, { color: colors.subtle }]}>By continuing, you verify that the account belongs to you. Health-data consent is collected on the next step.</Text>
            </Animated.View>
          }
        />
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const CONSENTS = [
  { id: 'care', title: 'Personalized care & health analysis', text: 'Use symptoms, AYUSH observations, and uploaded records to provide understandable guidance.', required: true },
  { id: 'triage', title: 'Emergency triage sharing', text: 'Share red-flag symptoms and emergency details with authorized triage staff when urgent risk is detected.', required: true },
  { id: 'records', title: 'Connected health records', text: 'Store OCR results and structured summaries so they are available across signed-in devices.', required: false },
] as const;

export function ConsentScreen({ method, onComplete, onBack }: { method: IdentityMethod; onComplete: () => void; onBack: () => void }) {
  const theme = useAppTheme();
  const { colors } = theme;
  const [selected, setSelected] = useState<string[]>([]);
  const requiredReady = CONSENTS.filter((item) => item.required).every((item) => selected.includes(item.id));

  const toggle = (id: string) => setSelected((current) => current.includes(id) ? current.filter((item) => item !== id) : [...current, id]);

  return (
    <SafeAreaView style={[styles.safe, { backgroundColor: colors.canvas }]}>
      <View style={styles.consentHeader}><Pressable onPress={onBack} style={[styles.backButton, { backgroundColor: colors.surface }]}><Ionicons name="arrow-back" size={21} color={colors.text} /></Pressable><View style={styles.stepTrack}><View style={[styles.stepDone, { backgroundColor: colors.primary }]} /><View style={[styles.stepDone, { backgroundColor: colors.primary }]} /></View><Text style={[styles.stepText, { color: colors.muted }]}>STEP 2 OF 2</Text></View>
      <FlatList
        data={CONSENTS}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.consentContent}
        ListHeaderComponent={<View><Text style={[styles.consentTitle, { color: colors.text }]}>Your data, your choice</Text><Text style={[styles.consentIntro, { color: colors.muted }]}>Review how Vitala may use your information. You can change optional permissions later.</Text><View style={[styles.identitySummary, { backgroundColor: colors.primarySoft }]}><Ionicons name="shield-checkmark" size={20} color={colors.primary} /><View><Text style={[styles.identitySummaryTitle, { color: colors.text }]}>Identity verified</Text><Text style={[styles.identitySummaryText, { color: colors.muted }]}>{method} · Arjun Rao</Text></View></View></View>}
        renderItem={({ item }) => {
          const checked = selected.includes(item.id);
          return <Pressable onPress={() => toggle(item.id)} style={[styles.consentCard, { backgroundColor: colors.surface, borderColor: checked ? colors.primary : colors.line }]}><View style={[styles.check, { backgroundColor: checked ? colors.primary : 'transparent', borderColor: checked ? colors.primary : colors.line }]}>{checked && <Ionicons name="checkmark" size={17} color="#FFFFFF" />}</View><View style={styles.consentCopy}><View style={styles.consentTitleRow}><Text style={[styles.consentItemTitle, { color: colors.text }]}>{item.title}</Text>{item.required && <Text style={[styles.required, { color: colors.primary }]}>REQUIRED</Text>}</View><Text style={[styles.consentItemText, { color: colors.muted }]}>{item.text}</Text></View></Pressable>;
        }}
        ListFooterComponent={<View style={[styles.consentNote, { borderColor: colors.line }]}><Ionicons name="information-circle-outline" size={19} color={colors.blue} /><Text style={[styles.consentNoteText, { color: colors.muted }]}>Vitala does not sell health data. Emergency sharing is limited to the active care event and is recorded in your audit trail.</Text></View>}
      />
      <View style={[styles.consentFooter, { backgroundColor: colors.canvas, borderColor: colors.line }]}><Pressable disabled={!requiredReady} onPress={onComplete} style={[styles.primaryButton, { backgroundColor: colors.primary, marginTop: 0 }, !requiredReady && { opacity: 0.4 }]}><Ionicons name="shield-checkmark-outline" size={20} color="#FFFFFF" /><Text style={styles.primaryButtonText}>I understand & give consent</Text></Pressable><Text style={[styles.requiredHint, { color: colors.subtle }]}>{requiredReady ? 'Required permissions accepted' : 'Select both required permissions to continue'}</Text></View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1 },
  flex: { flex: 1 },
  splash: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  splashMark: { width: 92, height: 92, borderRadius: 30, backgroundColor: '#FFFFFF', alignItems: 'center', justifyContent: 'center', shadowColor: '#032F2A', shadowOpacity: 0.3, shadowRadius: 24, shadowOffset: { width: 0, height: 12 } },
  splashPulse: { position: 'absolute', right: -5, bottom: -5, width: 30, height: 30, borderRadius: 15, backgroundColor: '#E06252', alignItems: 'center', justifyContent: 'center', borderWidth: 3, borderColor: '#087368' },
  splashName: { color: '#FFFFFF', fontSize: 38, fontWeight: '900', letterSpacing: -1, marginTop: 22 },
  splashTag: { color: '#C9F3E9', fontSize: 14, marginTop: 7 },
  splashSecure: { position: 'absolute', bottom: 42, flexDirection: 'row', alignItems: 'center', gap: 6 },
  splashSecureText: { color: '#BEEDE3', fontSize: 10.5, fontWeight: '700' },
  loginContent: { paddingHorizontal: 22, paddingTop: 12, paddingBottom: 35 },
  brandRow: { flexDirection: 'row', alignItems: 'center' },
  brandMark: { width: 40, height: 40, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  brandName: { fontSize: 22, fontWeight: '900', marginLeft: 9 },
  demoBadge: { borderRadius: 999, paddingHorizontal: 8, paddingVertical: 5, marginLeft: 'auto' },
  demoText: { fontSize: 8.5, fontWeight: '900', letterSpacing: 0.8 },
  welcomeTitle: { fontSize: 31, lineHeight: 37, fontWeight: '900', letterSpacing: -0.7, marginTop: 30 },
  welcomeText: { fontSize: 13.5, lineHeight: 20, marginTop: 7 },
  authSwitch: { flexDirection: 'row', padding: 4, borderRadius: 16, marginTop: 23, marginBottom: 20 },
  authOption: { flex: 1, height: 41, borderRadius: 13, alignItems: 'center', justifyContent: 'center' },
  authOptionText: { fontSize: 13, fontWeight: '900' },
  fieldLabel: { fontSize: 9.5, fontWeight: '900', letterSpacing: 1, marginBottom: 7 },
  inputShell: { height: 52, borderWidth: 1, borderRadius: 16, flexDirection: 'row', alignItems: 'center', paddingHorizontal: 13, marginBottom: 15 },
  countryCode: { fontSize: 13, fontWeight: '900' },
  inputDivider: { width: 1, height: 24, marginHorizontal: 11 },
  loginInput: { flex: 1, fontSize: 14, paddingVertical: 10 },
  primaryButton: { height: 53, borderRadius: 17, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, marginTop: 3 },
  primaryButtonText: { color: '#FFFFFF', fontSize: 14, fontWeight: '900' },
  orRow: { flexDirection: 'row', alignItems: 'center', gap: 9, marginVertical: 20 },
  orLine: { height: 1, flex: 1 },
  orText: { fontSize: 8.5, fontWeight: '900', letterSpacing: 0.8 },
  identityButton: { minHeight: 62, borderWidth: 1, borderRadius: 18, padding: 10, flexDirection: 'row', alignItems: 'center', marginBottom: 9 },
  identityIcon: { width: 41, height: 41, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  identityCopy: { flex: 1, marginLeft: 11 },
  identityTitle: { fontSize: 13, fontWeight: '900' },
  identitySubtitle: { fontSize: 10.5, marginTop: 3 },
  legal: { fontSize: 10, lineHeight: 15, textAlign: 'center', marginTop: 12, paddingHorizontal: 8 },
  consentHeader: { height: 58, paddingHorizontal: 20, flexDirection: 'row', alignItems: 'center' },
  backButton: { width: 40, height: 40, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  stepTrack: { flex: 1, flexDirection: 'row', gap: 4, marginHorizontal: 17 },
  stepDone: { height: 4, flex: 1, borderRadius: 2 },
  stepText: { fontSize: 9, fontWeight: '900', letterSpacing: 0.8 },
  consentContent: { padding: 20, paddingBottom: 30 },
  consentTitle: { fontSize: 30, lineHeight: 36, fontWeight: '900', letterSpacing: -0.7 },
  consentIntro: { fontSize: 13.5, lineHeight: 20, marginTop: 7 },
  identitySummary: { borderRadius: 17, padding: 13, flexDirection: 'row', alignItems: 'center', gap: 10, marginTop: 19, marginBottom: 16 },
  identitySummaryTitle: { fontSize: 12.5, fontWeight: '900' },
  identitySummaryText: { fontSize: 10.5, marginTop: 2 },
  consentCard: { borderWidth: 1, borderRadius: 19, padding: 14, flexDirection: 'row', marginBottom: 10 },
  check: { width: 25, height: 25, borderRadius: 8, borderWidth: 1.5, alignItems: 'center', justifyContent: 'center' },
  consentCopy: { flex: 1, marginLeft: 11 },
  consentTitleRow: { flexDirection: 'row', alignItems: 'center', gap: 7 },
  consentItemTitle: { flex: 1, fontSize: 13.5, fontWeight: '900' },
  required: { fontSize: 7.5, fontWeight: '900', letterSpacing: 0.6 },
  consentItemText: { fontSize: 11.5, lineHeight: 17, marginTop: 5 },
  consentNote: { borderTopWidth: 1, paddingTop: 15, flexDirection: 'row', gap: 8, marginTop: 8 },
  consentNoteText: { flex: 1, fontSize: 10.5, lineHeight: 15 },
  consentFooter: { padding: 14, paddingHorizontal: 20, borderTopWidth: 1 },
  requiredHint: { fontSize: 9.5, textAlign: 'center', marginTop: 7 },
});
