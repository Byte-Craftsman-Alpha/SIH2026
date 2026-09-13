import Ionicons from '@expo/vector-icons/Ionicons';
import * as ImagePicker from 'expo-image-picker';
import { Image } from 'expo-image';
import React, { useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  FlatList,
  Modal,
  Platform,
  Pressable,
  RefreshControl,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';
import { SafeAreaView } from 'react-native-safe-area-context';
import { AppHeader, SectionTitle, SyncBadge } from '../components/ui';
import { MedicalRecord, useHealthStore } from '../lib/store';
import { useAppTheme } from '../lib/theme';

type AddStage = 'choose' | 'analyzing' | 'confirm';

export default function HistoryScreen() {
  const theme = useAppTheme();
  const { colors } = theme;
  const { records, addRecord, updateRecord } = useHealthStore();
  const [refreshing, setRefreshing] = useState(false);
  const [addVisible, setAddVisible] = useState(false);
  const [stage, setStage] = useState<AddStage>('choose');
  const [documentUri, setDocumentUri] = useState<string | undefined>();
  const [recordTitle, setRecordTitle] = useState('Lipid & blood glucose panel');
  const [provider, setProvider] = useState('Metro Health Diagnostics');
  const [cholesterol, setCholesterol] = useState('228');
  const [bloodSugar, setBloodSugar] = useState('118');
  const [selectedRecord, setSelectedRecord] = useState<MedicalRecord | null>(null);
  const [doctorSummary, setDoctorSummary] = useState('');

  const openAdd = () => {
    setStage('choose');
    setDocumentUri(undefined);
    setRecordTitle('Lipid & blood glucose panel');
    setCholesterol('228');
    setBloodSugar('118');
    setAddVisible(true);
  };

  const openRecord = (record: MedicalRecord) => {
    setSelectedRecord(record);
    setDoctorSummary(record.summary);
  };

  const handleDocument = (uri: string, fileName?: string | null) => {
    setDocumentUri(uri);
    if (fileName?.toLowerCase().includes('prescription')) setRecordTitle('Doctor prescription');
    setStage('analyzing');
    setTimeout(() => setStage('confirm'), 1250);
  };

  const scanCamera = async () => {
    const permission = await ImagePicker.requestCameraPermissionsAsync();
    if (!permission.granted) {
      Alert.alert('Camera access needed', 'Allow camera access to scan a medical document.');
      return;
    }
    const result = await ImagePicker.launchCameraAsync({ mediaTypes: ['images'], quality: 0.9, allowsEditing: false });
    if (!result.canceled) handleDocument(result.assets[0].uri, result.assets[0].fileName);
  };

  const uploadDocument = async () => {
    const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!permission.granted && Platform.OS !== 'web') {
      Alert.alert('Photo access needed', 'Allow photo access to upload a medical document.');
      return;
    }
    const result = await ImagePicker.launchImageLibraryAsync({ mediaTypes: ['images'], quality: 0.9, allowsMultipleSelection: false });
    if (!result.canceled) handleDocument(result.assets[0].uri, result.assets[0].fileName);
  };

  const confirmUpload = () => {
    const timestamp = new Date();
    const date = new Intl.DateTimeFormat('en-IN', { day: '2-digit', month: 'short', year: 'numeric' }).format(timestamp);
    const uploadedAt = `${date} · ${new Intl.DateTimeFormat('en-IN', { hour: 'numeric', minute: '2-digit' }).format(timestamp)}`;
    const structuredSummary = `Structured history: acute chest pain with sweating and breathlessness triggered a red-flag triage alert. Previous lab report shows total cholesterol ${cholesterol} mg/dL and fasting blood sugar ${bloodSugar} mg/dL. Awaiting clinician review and correction.`;
    addRecord({
      id: `record-${Date.now()}`,
      title: recordTitle.trim() || 'Scanned medical record',
      provider: provider.trim() || 'Provider not stated',
      date,
      uploadedAt,
      type: 'OCR · Structured history',
      status: 'Attention',
      summary: structuredSummary,
      findings: [`Total cholesterol · ${cholesterol} mg/dL · high`, `Fasting blood sugar · ${bloodSugar} mg/dL · borderline high`],
      imageUri: documentUri,
      doctorConfirmed: false,
    });
    setAddVisible(false);
    setStage('choose');
    Alert.alert('Structured history created', 'The OCR values are confirmed and the summary is ready for a doctor to review.');
  };

  const confirmDoctorReview = () => {
    if (!selectedRecord) return;
    const reviewed: MedicalRecord = { ...selectedRecord, summary: doctorSummary.trim() || selectedRecord.summary, status: 'Reviewed', doctorConfirmed: true };
    updateRecord(reviewed);
    setSelectedRecord(reviewed);
    Alert.alert('Doctor review confirmed', 'Corrections are saved and the structured history is now clinician-confirmed.');
  };

  const onRefresh = () => {
    setRefreshing(true);
    setTimeout(() => setRefreshing(false), 700);
  };

  const statusStyle = (status: MedicalRecord['status']) => {
    if (status === 'Attention') return { bg: colors.amberSoft, fg: colors.amber, icon: 'alert-circle' as const };
    if (status === 'Healthy') return { bg: colors.primarySoft, fg: colors.primary, icon: 'checkmark-circle' as const };
    return { bg: colors.blueSoft, fg: colors.blue, icon: 'checkmark-done-circle' as const };
  };

  const renderRecord = ({ item, index }: { item: MedicalRecord; index: number }) => {
    const status = statusStyle(item.status);
    return (
      <Animated.View entering={FadeInDown.delay(Math.min(index * 70, 210)).duration(400)}>
        <Pressable
          onPress={() => openRecord(item)}
          style={({ pressed }) => [styles.recordCard, { backgroundColor: colors.surface, borderColor: colors.line, shadowColor: colors.shadow }, pressed && { transform: [{ scale: 0.99 }] }]}
        >
          <View style={styles.cardTop}>
            <View style={[styles.fileIcon, { backgroundColor: status.bg }]}><Ionicons name="document-text-outline" size={22} color={status.fg} /></View>
            <View style={styles.recordCopy}>
              <Text style={[styles.recordType, { color: colors.muted }]}>{item.type.toUpperCase()}</Text>
              <Text style={[styles.recordTitle, { color: colors.text }]} numberOfLines={2}>{item.title}</Text>
              <Text style={[styles.recordProvider, { color: colors.muted }]}>{item.provider}</Text>
            </View>
            <Ionicons name="chevron-forward" size={20} color={colors.subtle} />
          </View>
          <View style={[styles.summaryBox, { backgroundColor: colors.surfaceAlt }]}>
            <Ionicons name="sparkles-outline" size={16} color={colors.primary} />
            <Text numberOfLines={2} style={[styles.summaryText, { color: colors.muted }]}>{item.summary}</Text>
          </View>
          <View style={styles.cardFooter}>
            <View style={styles.dateRow}><Ionicons name="time-outline" size={14} color={colors.subtle} /><Text style={[styles.recordDate, { color: colors.subtle }]}>{item.date}</Text></View>
            <View style={[styles.statusPill, { backgroundColor: status.bg }]}><Ionicons name={status.icon} size={13} color={status.fg} /><Text style={[styles.statusText, { color: status.fg }]}>{item.doctorConfirmed ? 'Doctor confirmed' : item.status === 'Attention' ? 'Doctor review pending' : item.status}</Text></View>
          </View>
        </Pressable>
      </Animated.View>
    );
  };

  const listHeader = (
    <View>
      <View style={[styles.vaultCard, { backgroundColor: colors.primarySoft, borderColor: colors.primary + '22' }]}>
        <View style={[styles.vaultIcon, { backgroundColor: colors.primary }]}><Ionicons name="shield-checkmark" size={22} color="#FFFFFF" /></View>
        <View style={styles.vaultCopy}>
          <Text style={[styles.vaultTitle, { color: colors.text }]}>Your private health vault</Text>
          <Text style={[styles.vaultText, { color: colors.muted }]}>Reports and parsed insights follow your account securely across devices.</Text>
          <SyncBadge theme={theme} />
        </View>
      </View>
      <View style={styles.sectionTop}><SectionTitle title="Medical records" detail={`${records.length} documents · newest first`} theme={theme} /></View>
    </View>
  );

  return (
    <SafeAreaView style={[styles.safe, { backgroundColor: colors.canvas }]} edges={['top']}>
      <AppHeader eyebrow="Health vault" title="History" subtitle="Every record, explained and ready." theme={theme} actionIcon="search-outline" onAction={() => Alert.alert('Search records', 'Search is ready for report names, providers, dates, and findings.')} />
      <FlatList
        data={records}
        renderItem={renderRecord}
        keyExtractor={(item) => item.id}
        ListHeaderComponent={listHeader}
        contentContainerStyle={styles.listContent}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={colors.primary} />}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={<View style={styles.empty}><Ionicons name="documents-outline" size={44} color={colors.subtle} /><Text style={[styles.emptyTitle, { color: colors.text }]}>No records yet</Text><Text style={[styles.emptyText, { color: colors.muted }]}>Scan your first medical document to get a clear summary.</Text></View>}
      />
      <Pressable onPress={openAdd} style={({ pressed }) => [styles.fab, { backgroundColor: colors.primary }, pressed && { transform: [{ scale: 0.96 }] }]}>
        <Ionicons name="scan-outline" size={21} color="#FFFFFF" /><Text style={styles.fabText}>Scan record</Text>
      </Pressable>

      <Modal visible={addVisible} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setAddVisible(false)}>
        <SafeAreaView style={[styles.modalSafe, { backgroundColor: colors.canvas }]}>
          <View style={[styles.modalHeader, { borderColor: colors.line }]}>
            <View><Text style={[styles.modalEyebrow, { color: colors.primary }]}>ADD TO HEALTH VAULT</Text><Text style={[styles.modalTitle, { color: colors.text }]}>{stage === 'confirm' ? 'Confirm details' : stage === 'analyzing' ? 'Reading report' : 'Add a record'}</Text></View>
            <Pressable onPress={() => setAddVisible(false)} style={[styles.closeButton, { backgroundColor: colors.surfaceAlt }]}><Ionicons name="close" size={22} color={colors.text} /></Pressable>
          </View>

          {stage === 'choose' && (
            <View style={styles.chooseContent}>
              <Text style={[styles.chooseIntro, { color: colors.muted }]}>Keep the document flat and well lit. Vitala will extract key details for you to verify before saving.</Text>
              <Pressable onPress={scanCamera} style={[styles.sourceCard, { backgroundColor: colors.primary, borderColor: colors.primary }]}>
                <View style={[styles.sourceIcon, { backgroundColor: '#FFFFFF22' }]}><Ionicons name="camera" size={28} color="#FFFFFF" /></View>
                <View style={styles.sourceCopy}><Text style={styles.sourceTitleLight}>Scan with camera</Text><Text style={styles.sourceTextLight}>Capture a prescription, lab report, or discharge note</Text></View>
                <Ionicons name="arrow-forward" size={22} color="#FFFFFF" />
              </Pressable>
              <Pressable onPress={uploadDocument} style={[styles.sourceCard, { backgroundColor: colors.surface, borderColor: colors.line }]}>
                <View style={[styles.sourceIcon, { backgroundColor: colors.primarySoft }]}><Ionicons name="cloud-upload-outline" size={28} color={colors.primary} /></View>
                <View style={styles.sourceCopy}><Text style={[styles.sourceTitle, { color: colors.text }]}>Upload from device</Text><Text style={[styles.sourceText, { color: colors.muted }]}>Choose an existing document photo</Text></View>
                <Ionicons name="arrow-forward" size={22} color={colors.primary} />
              </Pressable>
              <View style={[styles.privacyNote, { borderColor: colors.line }]}><Ionicons name="lock-closed-outline" size={18} color={colors.primary} /><Text style={[styles.privacyText, { color: colors.muted }]}>Your document is encrypted and only available through your account.</Text></View>
            </View>
          )}

          {stage === 'analyzing' && (
            <View style={styles.analyzingContent}>
              {!!documentUri && <Image source={{ uri: documentUri }} style={styles.documentPreview} contentFit="cover" transition={250} />}
              <View style={[styles.scanningOverlay, { borderColor: colors.primary }]} />
              <ActivityIndicator size="large" color={colors.primary} style={styles.loader} />
              <Text style={[styles.analyzingTitle, { color: colors.text }]}>Extracting health information…</Text>
              <Text style={[styles.analyzingText, { color: colors.muted }]}>OCR is locating cholesterol, blood sugar, report date, units, and reference ranges.</Text>
            </View>
          )}

          {stage === 'confirm' && (
            <FlatList
              data={['Total cholesterol', 'Fasting blood sugar']}
              keyExtractor={(item) => item}
              contentContainerStyle={styles.confirmContent}
              ListHeaderComponent={
                <View>
                  <View style={[styles.confidence, { backgroundColor: colors.primarySoft }]}><Ionicons name="sparkles" size={17} color={colors.primary} /><Text style={[styles.confidenceText, { color: colors.primary }]}>Parsed successfully · 97% confidence</Text></View>
                  {!!documentUri && <Image source={{ uri: documentUri }} style={styles.confirmPreview} contentFit="cover" />}
                  <Text style={[styles.fieldLabel, { color: colors.muted }]}>REPORT TYPE</Text>
                  <TextInput value={recordTitle} onChangeText={setRecordTitle} style={[styles.fieldInput, { backgroundColor: colors.surface, borderColor: colors.line, color: colors.text }]} />
                  <Text style={[styles.fieldLabel, { color: colors.muted }]}>PROVIDER</Text>
                  <TextInput value={provider} onChangeText={setProvider} style={[styles.fieldInput, { backgroundColor: colors.surface, borderColor: colors.line, color: colors.text }]} />
                  <View style={styles.findingsHeader}><Text style={[styles.findingsTitle, { color: colors.text }]}>Key findings</Text><Text style={[styles.editHint, { color: colors.muted }]}>Verify before upload</Text></View>
                </View>
              }
              renderItem={({ item }) => {
                const isCholesterol = item === 'Total cholesterol';
                return (
                  <View style={[styles.ocrValueRow, { backgroundColor: colors.surface, borderColor: colors.line }]}>
                    <View style={[styles.ocrIcon, { backgroundColor: colors.amberSoft }]}><Ionicons name="scan-outline" size={19} color={colors.amber} /></View>
                    <View style={styles.ocrCopy}><Text style={[styles.ocrLabel, { color: colors.muted }]}>{item}</Text><Text style={[styles.ocrStatus, { color: colors.amber }]}>{isCholesterol ? 'Above reference range' : 'Borderline high'}</Text></View>
                    <TextInput value={isCholesterol ? cholesterol : bloodSugar} onChangeText={isCholesterol ? setCholesterol : setBloodSugar} keyboardType="decimal-pad" selectTextOnFocus style={[styles.ocrInput, { color: colors.text, borderColor: colors.line, backgroundColor: colors.canvas }]} />
                    <Text style={[styles.ocrUnit, { color: colors.muted }]}>mg/dL</Text>
                  </View>
                );
              }}
              ListFooterComponent={
                <View>
                  <View style={[styles.parsedSummary, { backgroundColor: colors.amberSoft }]}><Text style={[styles.parsedTitle, { color: colors.text }]}>Structured history preview</Text><Text style={[styles.parsedText, { color: colors.muted }]}>Chest pain with sweating and breathlessness triggered triage. Prior lab: cholesterol {cholesterol} mg/dL; fasting blood sugar {bloodSugar} mg/dL. Doctor review will be requested.</Text></View>
                  <Pressable onPress={confirmUpload} style={[styles.confirmButton, { backgroundColor: colors.primary }]}><Ionicons name="checkmark-done-outline" size={20} color="#FFFFFF" /><Text style={styles.confirmButtonText}>Confirm extracted values</Text></Pressable>
                  <Pressable onPress={() => setStage('choose')} style={styles.rescanButton}><Text style={[styles.rescanText, { color: colors.primary }]}>Scan again</Text></Pressable>
                </View>
              }
            />
          )}
        </SafeAreaView>
      </Modal>

      <Modal visible={!!selectedRecord} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setSelectedRecord(null)}>
        <SafeAreaView style={[styles.modalSafe, { backgroundColor: colors.canvas }]}>
          {!!selectedRecord && (
            <>
              <View style={[styles.modalHeader, { borderColor: colors.line }]}><View><Text style={[styles.modalEyebrow, { color: selectedRecord.doctorConfirmed ? colors.primary : colors.amber }]}>{selectedRecord.doctorConfirmed ? 'DOCTOR CONFIRMED' : 'DOCTOR REVIEW WORKSPACE'}</Text><Text style={[styles.detailTitle, { color: colors.text }]} numberOfLines={1}>{selectedRecord.title}</Text></View><Pressable onPress={() => setSelectedRecord(null)} style={[styles.closeButton, { backgroundColor: colors.surfaceAlt }]}><Ionicons name="close" size={22} color={colors.text} /></Pressable></View>
              <FlatList
                data={selectedRecord.findings}
                keyExtractor={(item) => item}
                contentContainerStyle={styles.detailContent}
                ListHeaderComponent={<View><View style={styles.detailMeta}><View><Text style={[styles.detailProvider, { color: colors.text }]}>{selectedRecord.provider}</Text><Text style={[styles.detailDate, { color: colors.muted }]}>{selectedRecord.date} · uploaded {selectedRecord.uploadedAt}</Text></View><SyncBadge theme={theme} /></View><View style={[styles.detailSummary, { backgroundColor: colors.primarySoft }]}><Ionicons name="sparkles" size={21} color={colors.primary} /><View style={styles.detailSummaryCopy}><Text style={[styles.detailSummaryLabel, { color: colors.primary }]}>VITALA SUMMARY</Text><Text style={[styles.detailSummaryText, { color: colors.text }]}>{selectedRecord.summary}</Text></View></View><Text style={[styles.findingsTitle, { color: colors.text, marginTop: 22, marginBottom: 10 }]}>Extracted findings</Text></View>}
                renderItem={({ item }) => <View style={[styles.findingRow, { backgroundColor: colors.surface, borderColor: colors.line }]}><Ionicons name={item.includes('high') || item.includes('elevated') ? 'alert-circle-outline' : 'checkmark-circle-outline'} size={20} color={item.includes('high') || item.includes('elevated') ? colors.amber : colors.primary} /><Text style={[styles.findingText, { color: colors.text }]}>{item}</Text></View>}
                ListFooterComponent={<View><View style={[styles.clinicianReview, { backgroundColor: colors.surface, borderColor: selectedRecord.doctorConfirmed ? colors.primary + '55' : colors.amber + '55' }]}><View style={styles.reviewHeading}><View style={[styles.reviewIcon, { backgroundColor: selectedRecord.doctorConfirmed ? colors.primarySoft : colors.amberSoft }]}><Ionicons name={selectedRecord.doctorConfirmed ? 'checkmark-done' : 'medkit-outline'} size={19} color={selectedRecord.doctorConfirmed ? colors.primary : colors.amber} /></View><View><Text style={[styles.reviewTitle, { color: colors.text }]}>{selectedRecord.doctorConfirmed ? 'Clinician-confirmed summary' : 'Review, correct & confirm'}</Text><Text style={[styles.reviewSubtitle, { color: colors.muted }]}>Dr. Rohan Kapoor · General Medicine</Text></View></View><TextInput value={doctorSummary} onChangeText={setDoctorSummary} editable={!selectedRecord.doctorConfirmed} multiline style={[styles.reviewInput, { backgroundColor: colors.canvas, borderColor: colors.line, color: colors.text }]} />{!selectedRecord.doctorConfirmed && <Pressable onPress={confirmDoctorReview} style={[styles.reviewButton, { backgroundColor: colors.primary }]}><Ionicons name="checkmark-circle-outline" size={19} color="#FFFFFF" /><Text style={styles.reviewButtonText}>Confirm doctor corrections</Text></Pressable>}</View><View style={[styles.accessNote, { borderColor: colors.line }]}><Ionicons name="globe-outline" size={19} color={colors.blue} /><Text style={[styles.accessText, { color: colors.muted }]}>Available anytime on devices signed in to this account with an audit trail of patient and doctor confirmations.</Text></View></View>}
              />
            </>
          )}
        </SafeAreaView>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1 },
  listContent: { paddingHorizontal: 20, paddingBottom: 100 },
  vaultCard: { borderRadius: 22, borderWidth: 1, padding: 16, flexDirection: 'row' },
  vaultIcon: { width: 44, height: 44, borderRadius: 15, alignItems: 'center', justifyContent: 'center' },
  vaultCopy: { flex: 1, marginLeft: 12 },
  vaultTitle: { fontSize: 16, fontWeight: '900' },
  vaultText: { fontSize: 12, lineHeight: 17, marginTop: 4, marginBottom: 10 },
  sectionTop: { marginTop: 25 },
  recordCard: { borderWidth: 1, borderRadius: 22, padding: 15, marginBottom: 12, shadowOpacity: 0.05, shadowRadius: 14, shadowOffset: { width: 0, height: 6 }, elevation: 1 },
  cardTop: { flexDirection: 'row', alignItems: 'flex-start' },
  fileIcon: { width: 44, height: 44, borderRadius: 15, alignItems: 'center', justifyContent: 'center' },
  recordCopy: { flex: 1, paddingHorizontal: 11 },
  recordType: { fontSize: 9.5, fontWeight: '900', letterSpacing: 0.8 },
  recordTitle: { fontSize: 16, lineHeight: 20, fontWeight: '900', marginTop: 3 },
  recordProvider: { fontSize: 11.5, marginTop: 4 },
  summaryBox: { borderRadius: 13, marginTop: 13, padding: 10, flexDirection: 'row', gap: 8 },
  summaryText: { flex: 1, fontSize: 11.5, lineHeight: 16 },
  cardFooter: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginTop: 12 },
  dateRow: { flexDirection: 'row', alignItems: 'center', gap: 5 },
  recordDate: { fontSize: 10.5 },
  statusPill: { flexDirection: 'row', alignItems: 'center', gap: 4, paddingHorizontal: 8, paddingVertical: 5, borderRadius: 999 },
  statusText: { fontSize: 9.5, fontWeight: '900' },
  fab: { position: 'absolute', right: 20, bottom: 18, height: 50, paddingHorizontal: 18, borderRadius: 18, flexDirection: 'row', alignItems: 'center', gap: 8, shadowColor: '#0A5148', shadowOpacity: 0.28, shadowRadius: 14, shadowOffset: { width: 0, height: 7 }, elevation: 7 },
  fabText: { color: '#FFFFFF', fontSize: 13, fontWeight: '900' },
  empty: { alignItems: 'center', padding: 40 },
  emptyTitle: { fontSize: 18, fontWeight: '900', marginTop: 12 },
  emptyText: { fontSize: 13, lineHeight: 18, textAlign: 'center', marginTop: 6 },
  modalSafe: { flex: 1 },
  modalHeader: { paddingHorizontal: 20, paddingVertical: 14, borderBottomWidth: 1, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  modalEyebrow: { fontSize: 10, fontWeight: '900', letterSpacing: 1.2 },
  modalTitle: { fontSize: 26, fontWeight: '900', marginTop: 3 },
  detailTitle: { fontSize: 21, fontWeight: '900', marginTop: 3, maxWidth: 280 },
  closeButton: { width: 40, height: 40, borderRadius: 15, alignItems: 'center', justifyContent: 'center' },
  chooseContent: { padding: 20 },
  chooseIntro: { fontSize: 14, lineHeight: 20, marginBottom: 22 },
  sourceCard: { borderWidth: 1, borderRadius: 21, padding: 15, flexDirection: 'row', alignItems: 'center', marginBottom: 12 },
  sourceIcon: { width: 52, height: 52, borderRadius: 18, alignItems: 'center', justifyContent: 'center' },
  sourceCopy: { flex: 1, paddingHorizontal: 13 },
  sourceTitle: { fontSize: 15, fontWeight: '900' },
  sourceTitleLight: { color: '#FFFFFF', fontSize: 15, fontWeight: '900' },
  sourceText: { fontSize: 11.5, lineHeight: 16, marginTop: 4 },
  sourceTextLight: { color: '#D9F5EE', fontSize: 11.5, lineHeight: 16, marginTop: 4 },
  privacyNote: { borderTopWidth: 1, marginTop: 15, paddingTop: 16, flexDirection: 'row', gap: 9, alignItems: 'center' },
  privacyText: { flex: 1, fontSize: 11.5, lineHeight: 16 },
  analyzingContent: { padding: 20, alignItems: 'center' },
  documentPreview: { width: '100%', height: 320, borderRadius: 22, opacity: 0.55 },
  scanningOverlay: { position: 'absolute', top: 55, left: 35, right: 35, height: 2, borderTopWidth: 2, shadowColor: '#0E7567', shadowOpacity: 0.9, shadowRadius: 8 },
  loader: { marginTop: 24 },
  analyzingTitle: { fontSize: 20, fontWeight: '900', marginTop: 14 },
  analyzingText: { textAlign: 'center', fontSize: 13, lineHeight: 19, maxWidth: 290, marginTop: 7 },
  confirmContent: { padding: 20, paddingBottom: 40 },
  confidence: { alignSelf: 'flex-start', paddingHorizontal: 10, paddingVertical: 7, borderRadius: 999, flexDirection: 'row', alignItems: 'center', gap: 6, marginBottom: 14 },
  confidenceText: { fontSize: 11, fontWeight: '900' },
  confirmPreview: { height: 125, borderRadius: 18, marginBottom: 18 },
  fieldLabel: { fontSize: 10, fontWeight: '900', letterSpacing: 1, marginBottom: 7 },
  fieldInput: { borderWidth: 1, borderRadius: 15, height: 50, paddingHorizontal: 14, fontSize: 14, fontWeight: '700', marginBottom: 15 },
  findingsHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginTop: 5, marginBottom: 10 },
  findingsTitle: { fontSize: 17, fontWeight: '900' },
  editHint: { fontSize: 10.5 },
  findingRow: { borderWidth: 1, borderRadius: 15, minHeight: 50, padding: 13, flexDirection: 'row', alignItems: 'center', gap: 10, marginBottom: 8 },
  findingText: { flex: 1, fontSize: 13, fontWeight: '600' },
  ocrValueRow: { borderWidth: 1, borderRadius: 16, padding: 11, flexDirection: 'row', alignItems: 'center', marginBottom: 9 },
  ocrIcon: { width: 38, height: 38, borderRadius: 13, alignItems: 'center', justifyContent: 'center' },
  ocrCopy: { flex: 1, marginLeft: 9 },
  ocrLabel: { fontSize: 10.5, fontWeight: '700' },
  ocrStatus: { fontSize: 9.5, fontWeight: '800', marginTop: 3 },
  ocrInput: { width: 58, height: 38, borderWidth: 1, borderRadius: 10, textAlign: 'center', fontSize: 14, fontWeight: '900' },
  ocrUnit: { width: 41, fontSize: 9.5, marginLeft: 5 },
  parsedSummary: { borderRadius: 17, padding: 14, marginTop: 8 },
  parsedTitle: { fontSize: 13, fontWeight: '900' },
  parsedText: { fontSize: 12, lineHeight: 18, marginTop: 5 },
  confirmButton: { height: 52, borderRadius: 17, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, marginTop: 20 },
  confirmButtonText: { color: '#FFFFFF', fontSize: 14, fontWeight: '900' },
  rescanButton: { alignItems: 'center', padding: 16 },
  rescanText: { fontSize: 13, fontWeight: '800' },
  detailContent: { padding: 20, paddingBottom: 40 },
  detailMeta: { gap: 12, marginBottom: 18 },
  detailProvider: { fontSize: 15, fontWeight: '800' },
  detailDate: { fontSize: 11.5, marginTop: 4 },
  detailSummary: { borderRadius: 19, padding: 15, flexDirection: 'row', gap: 11 },
  detailSummaryCopy: { flex: 1 },
  detailSummaryLabel: { fontSize: 9.5, fontWeight: '900', letterSpacing: 1 },
  detailSummaryText: { fontSize: 13, lineHeight: 19, fontWeight: '600', marginTop: 5 },
  clinicianReview: { borderWidth: 1, borderRadius: 19, padding: 14, marginTop: 16 },
  reviewHeading: { flexDirection: 'row', alignItems: 'center' },
  reviewIcon: { width: 38, height: 38, borderRadius: 13, alignItems: 'center', justifyContent: 'center', marginRight: 9 },
  reviewTitle: { fontSize: 13.5, fontWeight: '900' },
  reviewSubtitle: { fontSize: 10.5, marginTop: 2 },
  reviewInput: { minHeight: 108, borderWidth: 1, borderRadius: 14, padding: 12, textAlignVertical: 'top', fontSize: 12, lineHeight: 18, marginTop: 13 },
  reviewButton: { height: 46, borderRadius: 14, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 7, marginTop: 10 },
  reviewButtonText: { color: '#FFFFFF', fontSize: 12, fontWeight: '900' },
  accessNote: { borderTopWidth: 1, marginTop: 18, paddingTop: 15, flexDirection: 'row', alignItems: 'center', gap: 9 },
  accessText: { flex: 1, fontSize: 12 },
});
