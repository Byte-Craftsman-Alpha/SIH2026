import Ionicons from '@expo/vector-icons/Ionicons';
import { BottomTabScreenProps } from '@react-navigation/bottom-tabs';
import { LinearGradient } from 'expo-linear-gradient';
import React, { useEffect, useRef, useState } from 'react';
import {
  Alert,
  FlatList,
  KeyboardAvoidingView,
  Modal,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';
import { SafeAreaView } from 'react-native-safe-area-context';
import { AppHeader, InitialAvatar, SectionTitle, SyncBadge } from '../components/ui';
import type { RootTabParamList } from '../App';
import { Appointment, EmergencyProfile, useHealthStore } from '../lib/store';
import { useAppTheme } from '../lib/theme';

type Props = BottomTabScreenProps<RootTabParamList, 'Appointments'>;

type Doctor = {
  name: string;
  initials: string;
  specialty: string;
  experience: string;
  languages: string;
  color: string;
  available: string;
};

const DOCTORS: Doctor[] = [
  { name: 'Dr. Meera Iyer', initials: 'MI', specialty: 'Ayurveda · BAMS, MD', experience: '14 yrs', languages: 'English, हिंदी, தமிழ்', color: '#8C5EAA', available: '10:30 AM' },
  { name: 'Dr. Priya Sharma', initials: 'PS', specialty: 'Emergency Medicine · MD', experience: '11 yrs', languages: 'English, हिंदी', color: '#D26A58', available: 'Next · ~12 min' },
  { name: 'Dr. Rohan Kapoor', initials: 'RK', specialty: 'General Medicine · MD', experience: '16 yrs', languages: 'English, हिंदी', color: '#467AA0', available: '4:00 PM' },
];

const DATES = [
  { day: 'TODAY', date: '06', month: 'SEP', full: '06 Sep 2026' },
  { day: 'MON', date: '07', month: 'SEP', full: '07 Sep 2026' },
  { day: 'TUE', date: '08', month: 'SEP', full: '08 Sep 2026' },
  { day: 'WED', date: '09', month: 'SEP', full: '09 Sep 2026' },
];
const TIMES = ['9:00 AM', '10:30 AM', '2:00 PM', '4:00 PM'];

export default function AppointmentsScreen({ route }: Props) {
  const theme = useAppTheme();
  const { colors } = theme;
  const { appointments, emergency, addAppointment, updateEmergency } = useHealthStore();
  const [bookVisible, setBookVisible] = useState(false);
  const [emergencyVisible, setEmergencyVisible] = useState(false);
  const [urgent, setUrgent] = useState(false);
  const [selectedDoctor, setSelectedDoctor] = useState(DOCTORS[0]);
  const [selectedDate, setSelectedDate] = useState(DATES[2]);
  const [selectedTime, setSelectedTime] = useState('10:30 AM');
  const [mode, setMode] = useState<Appointment['mode']>('Video');
  const [selectedAppointment, setSelectedAppointment] = useState<Appointment | null>(null);
  const [draftEmergency, setDraftEmergency] = useState<EmergencyProfile>(emergency);
  const handledNonce = useRef<number | undefined>(undefined);

  useEffect(() => {
    const params = route.params;
    if (!params?.startBooking || params.nonce === handledNonce.current) return;
    handledNonce.current = params.nonce;
    const isUrgent = !!params.urgent;
    setUrgent(isUrgent);
    setSelectedDoctor(isUrgent ? DOCTORS[1] : DOCTORS[0]);
    setSelectedDate(isUrgent ? DATES[0] : DATES[2]);
    setSelectedTime(isUrgent ? 'Next · ~12 min' : '10:30 AM');
    setMode('Video');
    setBookVisible(true);
  }, [route.params]);

  const startBooking = (isUrgent = false) => {
    setUrgent(isUrgent);
    setSelectedDoctor(isUrgent ? DOCTORS[1] : DOCTORS[0]);
    setSelectedDate(isUrgent ? DATES[0] : DATES[2]);
    setSelectedTime(isUrgent ? 'Next · ~12 min' : '10:30 AM');
    setMode('Video');
    setBookVisible(true);
  };

  const confirmBooking = () => {
    const appointment: Appointment = {
      id: `appointment-${Date.now()}`,
      doctor: selectedDoctor.name,
      specialty: selectedDoctor.specialty,
      date: selectedDate.full,
      time: selectedTime,
      mode,
      urgent,
      location: mode === 'Video' ? 'Vitala secure video' : 'Vitala Partner Clinic · Bengaluru',
    };
    addAppointment(appointment);
    setBookVisible(false);
    Alert.alert(urgent ? 'Doctor is being connected' : 'Appointment confirmed', urgent ? 'Stay on this screen. Your secure video consultation should begin in about 12 minutes.' : `${selectedDoctor.name} · ${selectedDate.full} at ${selectedTime}`);
  };

  const openEmergency = () => {
    setDraftEmergency(emergency);
    setEmergencyVisible(true);
  };

  const saveEmergency = () => {
    updateEmergency(draftEmergency);
    setEmergencyVisible(false);
    Alert.alert('Emergency profile updated', 'These details will be available during urgent booking and from your signed-in devices.');
  };

  const renderAppointment = ({ item, index }: { item: Appointment; index: number }) => {
    const parts = item.date.split(' ');
    return (
      <Animated.View entering={FadeInDown.delay(Math.min(index * 70, 210)).duration(400)}>
        <Pressable onPress={() => setSelectedAppointment(item)} style={({ pressed }) => [styles.appointmentCard, { backgroundColor: colors.surface, borderColor: item.urgent ? colors.danger + '55' : colors.line, shadowColor: colors.shadow }, pressed && { opacity: 0.84 }]}>
          <View style={[styles.dateBlock, { backgroundColor: item.urgent ? colors.dangerSoft : colors.primarySoft }]}>
            <Text style={[styles.dateMonth, { color: item.urgent ? colors.danger : colors.primary }]}>{parts[1]?.toUpperCase() ?? 'SEP'}</Text>
            <Text style={[styles.dateNumber, { color: colors.text }]}>{parts[0]}</Text>
          </View>
          <View style={styles.appointmentCopy}>
            <View style={styles.appointmentTopline}>
              <Text style={[styles.appointmentDoctor, { color: colors.text }]} numberOfLines={1}>{item.doctor}</Text>
              {item.urgent && <View style={[styles.urgentPill, { backgroundColor: colors.dangerSoft }]}><Text style={[styles.urgentPillText, { color: colors.danger }]}>URGENT</Text></View>}
            </View>
            <Text style={[styles.appointmentSpecialty, { color: colors.muted }]} numberOfLines={1}>{item.specialty}</Text>
            <View style={styles.appointmentMeta}>
              <View style={styles.metaItem}><Ionicons name="time-outline" size={14} color={colors.primary} /><Text style={[styles.metaText, { color: colors.text }]}>{item.time}</Text></View>
              <View style={styles.metaItem}><Ionicons name={item.mode === 'Video' ? 'videocam-outline' : 'location-outline'} size={14} color={colors.primary} /><Text style={[styles.metaText, { color: colors.text }]}>{item.mode}</Text></View>
            </View>
          </View>
          <Ionicons name="chevron-forward" size={19} color={colors.subtle} />
        </Pressable>
      </Animated.View>
    );
  };

  const listHeader = (
    <View>
      <LinearGradient colors={theme.dark ? ['#19483F', '#16352F'] : ['#0F7D6E', '#075D53']} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={styles.heroCard}>
        <View style={styles.heroTop}><View style={styles.heroLabel}><View style={styles.liveDot} /><Text style={styles.heroLabelText}>NEXT APPOINTMENT</Text></View><Ionicons name="videocam-outline" size={22} color="#CFF5EA" /></View>
        <Text style={styles.heroDoctor}>{appointments[0]?.doctor ?? 'No appointment scheduled'}</Text>
        {appointments[0] ? <><Text style={styles.heroSpecialty}>{appointments[0].specialty}</Text><View style={styles.heroDivider} /><View style={styles.heroBottom}><View><Text style={styles.heroDate}>{appointments[0].date}</Text><Text style={styles.heroTime}>{appointments[0].time} · {appointments[0].mode}</Text></View><Pressable onPress={() => setSelectedAppointment(appointments[0])} style={styles.joinButton}><Ionicons name="arrow-forward" size={18} color="#0D685C" /></Pressable></View></> : <Text style={styles.heroSpecialty}>Book a trusted clinician in a few taps.</Text>}
      </LinearGradient>

      <View style={styles.quickRow}>
        <Pressable onPress={() => startBooking(false)} style={[styles.quickCard, { backgroundColor: colors.surface, borderColor: colors.line }]}>
          <View style={[styles.quickIcon, { backgroundColor: colors.primarySoft }]}><Ionicons name="calendar" size={21} color={colors.primary} /></View>
          <Text style={[styles.quickTitle, { color: colors.text }]}>Book a visit</Text><Text style={[styles.quickText, { color: colors.muted }]}>Choose doctor & time</Text>
        </Pressable>
        <Pressable onPress={() => startBooking(true)} style={[styles.quickCard, { backgroundColor: colors.dangerSoft, borderColor: colors.danger + '35' }]}>
          <View style={[styles.quickIcon, { backgroundColor: colors.danger }]}><Ionicons name="flash" size={21} color="#FFFFFF" /></View>
          <Text style={[styles.quickTitle, { color: colors.text }]}>Doctor now</Text><Text style={[styles.quickText, { color: colors.muted }]}>Urgent · ~12 min</Text>
        </Pressable>
      </View>

      <View style={styles.emergencySection}>
        <SectionTitle title="Emergency profile" detail="Shared only when you choose" theme={theme} action="Edit" onAction={openEmergency} />
        <Pressable onPress={openEmergency} style={[styles.emergencyCard, { backgroundColor: colors.surface, borderColor: colors.line }]}>
          <View style={[styles.bloodBadge, { backgroundColor: colors.dangerSoft }]}><Ionicons name="water" size={15} color={colors.danger} /><Text style={[styles.bloodText, { color: colors.danger }]}>{emergency.bloodGroup}</Text></View>
          <View style={styles.emergencyItem}><Text style={[styles.emergencyLabel, { color: colors.subtle }]}>ALLERGIES</Text><Text numberOfLines={1} style={[styles.emergencyValue, { color: colors.text }]}>{emergency.allergies || 'None stated'}</Text></View>
          <View style={[styles.emergencyDivider, { backgroundColor: colors.line }]} />
          <View style={styles.emergencyItem}><Text style={[styles.emergencyLabel, { color: colors.subtle }]}>CONDITIONS</Text><Text numberOfLines={1} style={[styles.emergencyValue, { color: colors.text }]}>{emergency.conditions || emergency.diabetes}</Text></View>
          <Ionicons name="chevron-forward" size={19} color={colors.subtle} />
        </Pressable>
      </View>

      <View style={styles.scheduledTop}><SectionTitle title="Scheduled" detail={`${appointments.length} upcoming appointments`} theme={theme} action="Book new" onAction={() => startBooking(false)} /></View>
    </View>
  );

  const emergencyFields: { key: keyof EmergencyProfile; label: string; placeholder: string; keyboard?: 'default' | 'number-pad' | 'phone-pad' }[] = [
    { key: 'bloodGroup', label: 'Blood group', placeholder: 'e.g. O+' },
    { key: 'allergies', label: 'Allergies', placeholder: 'Medicine, food, or environmental allergies' },
    { key: 'diabetes', label: 'Diabetes', placeholder: 'No, prediabetic, Type 1, Type 2' },
    { key: 'conditions', label: 'Other conditions', placeholder: 'Asthma, hypertension, etc.' },
    { key: 'gender', label: 'Gender', placeholder: 'Gender' },
    { key: 'age', label: 'Age', placeholder: 'Age', keyboard: 'number-pad' },
    { key: 'address', label: 'Address', placeholder: 'Home address' },
    { key: 'emergencyContact', label: 'Emergency contact', placeholder: 'Name and phone', keyboard: 'phone-pad' },
  ];

  return (
    <SafeAreaView style={[styles.safe, { backgroundColor: colors.canvas }]} edges={['top']}>
      <AppHeader eyebrow="Continuity of care" title="Appointments" subtitle="The right care, without the runaround." theme={theme} actionIcon="person-circle-outline" onAction={openEmergency} />
      <FlatList
        data={appointments}
        renderItem={renderAppointment}
        keyExtractor={(item) => item.id}
        ListHeaderComponent={listHeader}
        contentContainerStyle={styles.listContent}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={<View style={styles.empty}><Ionicons name="calendar-outline" size={44} color={colors.subtle} /><Text style={[styles.emptyTitle, { color: colors.text }]}>Your schedule is open</Text><Pressable onPress={() => startBooking(false)}><Text style={[styles.emptyAction, { color: colors.primary }]}>Book your first visit</Text></Pressable></View>}
      />

      <Modal visible={bookVisible} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setBookVisible(false)}>
        <SafeAreaView style={[styles.modalSafe, { backgroundColor: colors.canvas }]}>
          <View style={[styles.modalHeader, { borderColor: colors.line }]}><View><Text style={[styles.modalEyebrow, { color: urgent ? colors.danger : colors.primary }]}>{urgent ? 'URGENT CONSULTATION' : 'BOOK AN APPOINTMENT'}</Text><Text style={[styles.modalTitle, { color: colors.text }]}>{urgent ? 'Connect now' : 'Choose your care'}</Text></View><Pressable onPress={() => setBookVisible(false)} style={[styles.closeButton, { backgroundColor: colors.surfaceAlt }]}><Ionicons name="close" size={22} color={colors.text} /></Pressable></View>
          <FlatList
            data={DOCTORS}
            keyExtractor={(item) => item.name}
            contentContainerStyle={styles.bookingContent}
            ListHeaderComponent={
              <View>
                {urgent && <View style={[styles.urgentNotice, { backgroundColor: colors.dangerSoft, borderColor: colors.danger + '45' }]}><Ionicons name="alert-circle" size={21} color={colors.danger} /><Text style={[styles.urgentNoticeText, { color: colors.text }]}>For life-threatening symptoms call 112. This books the fastest available video doctor.</Text></View>}
                <Text style={[styles.bookingLabel, { color: colors.muted }]}>CONSULTATION TYPE</Text>
                <View style={[styles.modeSwitch, { backgroundColor: colors.surfaceAlt }]}>
                  {(['Video', 'In clinic'] as Appointment['mode'][]).map((item) => <Pressable key={item} disabled={urgent && item === 'In clinic'} onPress={() => setMode(item)} style={[styles.modeOption, mode === item && { backgroundColor: colors.surface }, urgent && item === 'In clinic' && { opacity: 0.35 }]}><Ionicons name={item === 'Video' ? 'videocam-outline' : 'business-outline'} size={18} color={mode === item ? colors.primary : colors.muted} /><Text style={[styles.modeText, { color: mode === item ? colors.text : colors.muted }]}>{item}</Text></Pressable>)}
                </View>
                <Text style={[styles.bookingLabel, { color: colors.muted, marginTop: 20 }]}>DATE</Text>
                <View style={styles.dateChoices}>{DATES.map((item) => { const active = item.full === selectedDate.full; return <Pressable key={item.full} disabled={urgent && item.full !== DATES[0].full} onPress={() => setSelectedDate(item)} style={[styles.dateChoice, { backgroundColor: active ? colors.primary : colors.surface, borderColor: active ? colors.primary : colors.line }, urgent && item.full !== DATES[0].full && { opacity: 0.35 }]}><Text style={[styles.choiceDay, { color: active ? '#D7F5ED' : colors.muted }]}>{item.day}</Text><Text style={[styles.choiceDate, { color: active ? '#FFFFFF' : colors.text }]}>{item.date}</Text><Text style={[styles.choiceMonth, { color: active ? '#D7F5ED' : colors.subtle }]}>{item.month}</Text></Pressable>; })}</View>
                <View style={styles.doctorHeading}><Text style={[styles.bookingLabel, { color: colors.muted }]}>CHOOSE DOCTOR</Text><Text style={[styles.availableText, { color: colors.primary }]}><View style={[styles.tinyDot, { backgroundColor: colors.primary }]} /> 3 available</Text></View>
              </View>
            }
            renderItem={({ item }) => {
              const active = selectedDoctor.name === item.name;
              return <Pressable onPress={() => { setSelectedDoctor(item); if (urgent) setSelectedTime(item.available); }} style={[styles.doctorCard, { backgroundColor: colors.surface, borderColor: active ? (urgent ? colors.danger : colors.primary) : colors.line }, active && { borderWidth: 2 }]}><InitialAvatar initials={item.initials} color={item.color} size={48} /><View style={styles.doctorCopy}><Text style={[styles.doctorName, { color: colors.text }]}>{item.name}</Text><Text style={[styles.doctorSpecialty, { color: colors.muted }]}>{item.specialty} · {item.experience}</Text><View style={styles.languages}><Ionicons name="language-outline" size={13} color={colors.subtle} /><Text style={[styles.languageList, { color: colors.subtle }]}>{item.languages}</Text></View></View><View style={[styles.radio, { borderColor: active ? colors.primary : colors.line }]}>{active && <View style={[styles.radioInner, { backgroundColor: urgent ? colors.danger : colors.primary }]} />}</View></Pressable>;
            }}
            ListFooterComponent={
              <View>
                <Text style={[styles.bookingLabel, { color: colors.muted, marginTop: 18 }]}>TIME</Text>
                {urgent ? <View style={[styles.nextSlot, { backgroundColor: colors.dangerSoft }]}><Ionicons name="flash" size={19} color={colors.danger} /><Text style={[styles.nextSlotText, { color: colors.text }]}>Fastest slot · Next · ~12 min</Text></View> : <View style={styles.timeChoices}>{TIMES.map((item) => { const active = selectedTime === item; return <Pressable key={item} onPress={() => setSelectedTime(item)} style={[styles.timeChoice, { backgroundColor: active ? colors.primarySoft : colors.surface, borderColor: active ? colors.primary : colors.line }]}><Text style={[styles.timeChoiceText, { color: active ? colors.primary : colors.text }]}>{item}</Text></Pressable>; })}</View>}
                <View style={[styles.shareRow, { borderColor: colors.line }]}><Ionicons name="shield-checkmark-outline" size={18} color={colors.primary} /><Text style={[styles.shareText, { color: colors.muted }]}>Relevant health history is shared only with your chosen doctor.</Text></View>
                <Pressable onPress={confirmBooking} style={[styles.confirmButton, { backgroundColor: urgent ? colors.danger : colors.primary }]}><Ionicons name={urgent ? 'videocam' : 'checkmark-circle-outline'} size={21} color="#FFFFFF" /><Text style={styles.confirmButtonText}>{urgent ? 'Connect to doctor now' : 'Confirm appointment'}</Text></Pressable>
              </View>
            }
          />
        </SafeAreaView>
      </Modal>

      <Modal visible={emergencyVisible} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setEmergencyVisible(false)}>
        <SafeAreaView style={[styles.modalSafe, { backgroundColor: colors.canvas }]}>
          <KeyboardAvoidingView style={styles.flex} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
            <View style={[styles.modalHeader, { borderColor: colors.line }]}><View><Text style={[styles.modalEyebrow, { color: colors.danger }]}>CRITICAL INFORMATION</Text><Text style={[styles.modalTitle, { color: colors.text }]}>Emergency profile</Text></View><Pressable onPress={() => setEmergencyVisible(false)} style={[styles.closeButton, { backgroundColor: colors.surfaceAlt }]}><Ionicons name="close" size={22} color={colors.text} /></Pressable></View>
            <FlatList
              data={emergencyFields}
              keyExtractor={(item) => item.key}
              keyboardShouldPersistTaps="handled"
              contentContainerStyle={styles.formContent}
              ListHeaderComponent={<View><View style={[styles.formIntro, { backgroundColor: colors.dangerSoft }]}><Ionicons name="medical" size={22} color={colors.danger} /><Text style={[styles.formIntroText, { color: colors.text }]}>Keep this accurate so a doctor has essential context during urgent care.</Text></View><SyncBadge theme={theme} /></View>}
              renderItem={({ item }) => <View><Text style={[styles.fieldLabel, { color: colors.muted }]}>{item.label.toUpperCase()}</Text><TextInput value={draftEmergency[item.key]} onChangeText={(value) => setDraftEmergency((current) => ({ ...current, [item.key]: value }))} placeholder={item.placeholder} placeholderTextColor={colors.subtle} keyboardType={item.keyboard ?? 'default'} style={[styles.fieldInput, { backgroundColor: colors.surface, borderColor: colors.line, color: colors.text }]} returnKeyType="next" /></View>}
              ListFooterComponent={<Pressable onPress={saveEmergency} style={[styles.confirmButton, { backgroundColor: colors.primary }]}><Ionicons name="shield-checkmark-outline" size={21} color="#FFFFFF" /><Text style={styles.confirmButtonText}>Save emergency profile</Text></Pressable>}
            />
          </KeyboardAvoidingView>
        </SafeAreaView>
      </Modal>

      <Modal visible={!!selectedAppointment} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setSelectedAppointment(null)}>
        <SafeAreaView style={[styles.modalSafe, { backgroundColor: colors.canvas }]}>
          {!!selectedAppointment && <><View style={[styles.modalHeader, { borderColor: colors.line }]}><View><Text style={[styles.modalEyebrow, { color: colors.primary }]}>APPOINTMENT DETAILS</Text><Text style={[styles.detailTitle, { color: colors.text }]}>{selectedAppointment.date}</Text></View><Pressable onPress={() => setSelectedAppointment(null)} style={[styles.closeButton, { backgroundColor: colors.surfaceAlt }]}><Ionicons name="close" size={22} color={colors.text} /></Pressable></View><View style={styles.detailContent}><View style={[styles.detailDoctorCard, { backgroundColor: colors.surface, borderColor: colors.line }]}><InitialAvatar initials={selectedAppointment.doctor.split(' ').slice(-2).map((part) => part[0]).join('')} color="#567D9D" size={58} /><Text style={[styles.detailDoctor, { color: colors.text }]}>{selectedAppointment.doctor}</Text><Text style={[styles.detailSpecialty, { color: colors.muted }]}>{selectedAppointment.specialty}</Text></View><View style={[styles.detailInfoCard, { backgroundColor: colors.surface, borderColor: colors.line }]}>{[[selectedAppointment.date, 'calendar-outline'], [selectedAppointment.time, 'time-outline'], [selectedAppointment.mode, selectedAppointment.mode === 'Video' ? 'videocam-outline' : 'location-outline'], [selectedAppointment.location, 'navigate-outline']].map((row) => <View key={row[0]} style={styles.detailRow}><View style={[styles.detailRowIcon, { backgroundColor: colors.primarySoft }]}><Ionicons name={row[1] as keyof typeof Ionicons.glyphMap} size={18} color={colors.primary} /></View><Text style={[styles.detailRowText, { color: colors.text }]}>{row[0]}</Text></View>)}</View>{selectedAppointment.mode === 'Video' && <Pressable onPress={() => Alert.alert('Video room', 'The secure consultation room opens 10 minutes before your appointment.')} style={[styles.confirmButton, { backgroundColor: colors.primary }]}><Ionicons name="videocam" size={20} color="#FFFFFF" /><Text style={styles.confirmButtonText}>Open video room</Text></Pressable>}<Pressable onPress={() => { setSelectedAppointment(null); startBooking(false); }} style={[styles.manageButton, { borderColor: colors.line }]}><Ionicons name="calendar-outline" size={19} color={colors.primary} /><Text style={[styles.manageText, { color: colors.primary }]}>Reschedule appointment</Text></Pressable></View></>}
        </SafeAreaView>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1 },
  flex: { flex: 1 },
  listContent: { paddingHorizontal: 20, paddingBottom: 40 },
  heroCard: { borderRadius: 24, padding: 18, shadowColor: '#073A33', shadowOpacity: 0.25, shadowRadius: 16, shadowOffset: { width: 0, height: 8 }, elevation: 5 },
  heroTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  heroLabel: { flexDirection: 'row', alignItems: 'center', gap: 7 },
  liveDot: { width: 7, height: 7, borderRadius: 4, backgroundColor: '#9AF0D8' },
  heroLabelText: { color: '#CFF5EA', fontSize: 10, fontWeight: '900', letterSpacing: 1.2 },
  heroDoctor: { color: '#FFFFFF', fontSize: 21, fontWeight: '900', marginTop: 18 },
  heroSpecialty: { color: '#BCE9DE', fontSize: 12, marginTop: 4 },
  heroDivider: { height: 1, backgroundColor: '#FFFFFF2B', marginVertical: 15 },
  heroBottom: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  heroDate: { color: '#FFFFFF', fontSize: 14, fontWeight: '800' },
  heroTime: { color: '#C5EEE5', fontSize: 11.5, marginTop: 3 },
  joinButton: { width: 42, height: 42, borderRadius: 15, backgroundColor: '#FFFFFF', alignItems: 'center', justifyContent: 'center' },
  quickRow: { flexDirection: 'row', gap: 11, marginTop: 14 },
  quickCard: { flex: 1, borderWidth: 1, borderRadius: 19, padding: 13 },
  quickIcon: { width: 38, height: 38, borderRadius: 13, alignItems: 'center', justifyContent: 'center', marginBottom: 11 },
  quickTitle: { fontSize: 14, fontWeight: '900' },
  quickText: { fontSize: 10.5, marginTop: 3 },
  emergencySection: { marginTop: 26 },
  emergencyCard: { borderWidth: 1, borderRadius: 19, padding: 12, flexDirection: 'row', alignItems: 'center' },
  bloodBadge: { width: 46, height: 46, borderRadius: 16, alignItems: 'center', justifyContent: 'center' },
  bloodText: { fontSize: 13, fontWeight: '900' },
  emergencyItem: { flex: 1, paddingHorizontal: 10 },
  emergencyLabel: { fontSize: 8.5, letterSpacing: 0.7, fontWeight: '900' },
  emergencyValue: { fontSize: 11.5, fontWeight: '800', marginTop: 4 },
  emergencyDivider: { width: 1, height: 30 },
  scheduledTop: { marginTop: 27 },
  appointmentCard: { borderWidth: 1, borderRadius: 20, padding: 13, flexDirection: 'row', alignItems: 'center', marginBottom: 11, shadowOpacity: 0.04, shadowRadius: 12, shadowOffset: { width: 0, height: 5 }, elevation: 1 },
  dateBlock: { width: 48, height: 57, borderRadius: 15, alignItems: 'center', justifyContent: 'center' },
  dateMonth: { fontSize: 9, fontWeight: '900', letterSpacing: 0.7 },
  dateNumber: { fontSize: 21, fontWeight: '900', marginTop: 1 },
  appointmentCopy: { flex: 1, marginLeft: 12 },
  appointmentTopline: { flexDirection: 'row', alignItems: 'center', gap: 7 },
  appointmentDoctor: { fontSize: 14.5, fontWeight: '900', maxWidth: '72%' },
  appointmentSpecialty: { fontSize: 10.5, marginTop: 3 },
  appointmentMeta: { flexDirection: 'row', gap: 13, marginTop: 8 },
  metaItem: { flexDirection: 'row', alignItems: 'center', gap: 4 },
  metaText: { fontSize: 10.5, fontWeight: '700' },
  urgentPill: { borderRadius: 999, paddingHorizontal: 6, paddingVertical: 3 },
  urgentPillText: { fontSize: 7.5, fontWeight: '900', letterSpacing: 0.6 },
  empty: { alignItems: 'center', padding: 40 },
  emptyTitle: { fontSize: 18, fontWeight: '900', marginTop: 12 },
  emptyAction: { fontSize: 13, fontWeight: '900', marginTop: 8 },
  modalSafe: { flex: 1 },
  modalHeader: { paddingHorizontal: 20, paddingVertical: 14, borderBottomWidth: 1, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  modalEyebrow: { fontSize: 10, fontWeight: '900', letterSpacing: 1.2 },
  modalTitle: { fontSize: 26, fontWeight: '900', marginTop: 3 },
  detailTitle: { fontSize: 22, fontWeight: '900', marginTop: 3 },
  closeButton: { width: 40, height: 40, borderRadius: 15, alignItems: 'center', justifyContent: 'center' },
  bookingContent: { padding: 20, paddingBottom: 40 },
  urgentNotice: { borderWidth: 1, borderRadius: 16, padding: 12, flexDirection: 'row', gap: 9, alignItems: 'center', marginBottom: 18 },
  urgentNoticeText: { flex: 1, fontSize: 11.5, lineHeight: 16, fontWeight: '600' },
  bookingLabel: { fontSize: 10, fontWeight: '900', letterSpacing: 1 },
  modeSwitch: { flexDirection: 'row', padding: 4, borderRadius: 15, marginTop: 8 },
  modeOption: { flex: 1, height: 42, borderRadius: 12, flexDirection: 'row', gap: 7, alignItems: 'center', justifyContent: 'center' },
  modeText: { fontSize: 12, fontWeight: '800' },
  dateChoices: { flexDirection: 'row', gap: 7, marginTop: 8, marginBottom: 22 },
  dateChoice: { flex: 1, borderWidth: 1, borderRadius: 15, alignItems: 'center', paddingVertical: 9 },
  choiceDay: { fontSize: 8.5, fontWeight: '900' },
  choiceDate: { fontSize: 19, fontWeight: '900', marginTop: 2 },
  choiceMonth: { fontSize: 8.5, fontWeight: '800' },
  doctorHeading: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 9 },
  availableText: { fontSize: 10.5, fontWeight: '800' },
  tinyDot: { width: 6, height: 6, borderRadius: 3 },
  doctorCard: { borderWidth: 1, borderRadius: 19, padding: 13, flexDirection: 'row', alignItems: 'center', marginBottom: 9 },
  doctorCopy: { flex: 1, marginLeft: 11 },
  doctorName: { fontSize: 14, fontWeight: '900' },
  doctorSpecialty: { fontSize: 10.5, marginTop: 3 },
  languages: { flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 6 },
  languageList: { fontSize: 9.5 },
  radio: { width: 21, height: 21, borderWidth: 2, borderRadius: 11, alignItems: 'center', justifyContent: 'center' },
  radioInner: { width: 11, height: 11, borderRadius: 6 },
  timeChoices: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 9 },
  timeChoice: { width: '47.8%', borderWidth: 1, borderRadius: 13, paddingVertical: 11, alignItems: 'center' },
  timeChoiceText: { fontSize: 12, fontWeight: '800' },
  nextSlot: { borderRadius: 15, padding: 14, flexDirection: 'row', gap: 8, marginTop: 9 },
  nextSlotText: { fontSize: 13, fontWeight: '900' },
  shareRow: { borderTopWidth: 1, marginTop: 20, paddingTop: 15, flexDirection: 'row', alignItems: 'center', gap: 8 },
  shareText: { flex: 1, fontSize: 11.5, lineHeight: 16 },
  confirmButton: { height: 52, borderRadius: 17, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, marginTop: 20 },
  confirmButtonText: { color: '#FFFFFF', fontSize: 14, fontWeight: '900' },
  formContent: { padding: 20, paddingBottom: 40 },
  formIntro: { borderRadius: 17, padding: 14, flexDirection: 'row', alignItems: 'center', gap: 10, marginBottom: 12 },
  formIntroText: { flex: 1, fontSize: 12, lineHeight: 17, fontWeight: '600' },
  fieldLabel: { fontSize: 10, fontWeight: '900', letterSpacing: 1, marginTop: 16, marginBottom: 7 },
  fieldInput: { borderWidth: 1, borderRadius: 15, height: 50, paddingHorizontal: 14, fontSize: 14 },
  detailContent: { padding: 20 },
  detailDoctorCard: { borderWidth: 1, borderRadius: 22, padding: 20, alignItems: 'center' },
  detailDoctor: { fontSize: 19, fontWeight: '900', marginTop: 11 },
  detailSpecialty: { fontSize: 12, marginTop: 4 },
  detailInfoCard: { borderWidth: 1, borderRadius: 20, padding: 15, marginTop: 13 },
  detailRow: { flexDirection: 'row', alignItems: 'center', marginVertical: 6 },
  detailRowIcon: { width: 36, height: 36, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  detailRowText: { flex: 1, fontSize: 13, fontWeight: '700', marginLeft: 11 },
  manageButton: { height: 50, borderRadius: 17, borderWidth: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, marginTop: 11 },
  manageText: { fontSize: 13, fontWeight: '900' },
});
