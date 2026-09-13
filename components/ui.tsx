import Ionicons from '@expo/vector-icons/Ionicons';
import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { AppTheme } from '../lib/theme';

export function AppHeader({
  eyebrow,
  title,
  subtitle,
  theme,
  actionIcon,
  onAction,
}: {
  eyebrow: string;
  title: string;
  subtitle?: string;
  theme: AppTheme;
  actionIcon?: keyof typeof Ionicons.glyphMap;
  onAction?: () => void;
}) {
  const { colors } = theme;
  return (
    <View style={styles.header}>
      <View style={styles.headerCopy}>
        <Text style={[styles.eyebrow, { color: colors.primary }]}>{eyebrow.toUpperCase()}</Text>
        <Text style={[styles.title, { color: colors.text }]}>{title}</Text>
        {!!subtitle && <Text style={[styles.subtitle, { color: colors.muted }]}>{subtitle}</Text>}
      </View>
      <Pressable
        accessibilityRole="button"
        accessibilityLabel="Open notifications"
        onPress={onAction}
        style={({ pressed }) => [styles.headerAction, { backgroundColor: colors.surface }, pressed && { opacity: 0.7 }]}
      >
        <Ionicons name={actionIcon ?? 'notifications-outline'} size={22} color={colors.text} />
        <View style={[styles.unreadDot, { borderColor: colors.surface }]} />
      </Pressable>
    </View>
  );
}

export function InitialAvatar({ initials, color, size = 44 }: { initials: string; color: string; size?: number }) {
  return (
    <View style={[styles.avatar, { width: size, height: size, borderRadius: size / 2, backgroundColor: color }]}>
      <Text style={[styles.avatarText, { fontSize: size * 0.34 }]}>{initials}</Text>
    </View>
  );
}

export function SectionTitle({
  title,
  detail,
  theme,
  action,
  onAction,
}: {
  title: string;
  detail?: string;
  theme: AppTheme;
  action?: string;
  onAction?: () => void;
}) {
  return (
    <View style={styles.sectionRow}>
      <View style={styles.sectionCopy}>
        <Text style={[styles.sectionTitle, { color: theme.colors.text }]}>{title}</Text>
        {!!detail && <Text style={[styles.sectionDetail, { color: theme.colors.muted }]}>{detail}</Text>}
      </View>
      {!!action && (
        <Pressable onPress={onAction} hitSlop={10}>
          <Text style={[styles.sectionAction, { color: theme.colors.primary }]}>{action}</Text>
        </Pressable>
      )}
    </View>
  );
}

export function SyncBadge({ theme }: { theme: AppTheme }) {
  return (
    <View style={[styles.syncBadge, { backgroundColor: theme.colors.primarySoft }]}>
      <Ionicons name="cloud-done-outline" size={14} color={theme.colors.primary} />
      <Text style={[styles.syncText, { color: theme.colors.primary }]}>Private & synced</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  header: { flexDirection: 'row', alignItems: 'flex-start', justifyContent: 'space-between', paddingHorizontal: 20, paddingTop: 10, paddingBottom: 18 },
  headerCopy: { flex: 1, paddingRight: 16 },
  eyebrow: { fontSize: 11, letterSpacing: 1.5, fontWeight: '800', marginBottom: 5 },
  title: { fontSize: 30, lineHeight: 36, fontWeight: '800', letterSpacing: -0.8 },
  subtitle: { fontSize: 14, lineHeight: 20, marginTop: 4 },
  headerAction: { width: 44, height: 44, borderRadius: 16, alignItems: 'center', justifyContent: 'center', shadowColor: '#172F29', shadowOpacity: 0.08, shadowRadius: 12, shadowOffset: { width: 0, height: 5 }, elevation: 2 },
  unreadDot: { position: 'absolute', right: 10, top: 9, width: 8, height: 8, borderRadius: 4, backgroundColor: '#E66C55', borderWidth: 2 },
  avatar: { alignItems: 'center', justifyContent: 'center' },
  avatarText: { color: '#FFFFFF', fontWeight: '800' },
  sectionRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 },
  sectionCopy: { flex: 1 },
  sectionTitle: { fontSize: 19, lineHeight: 24, fontWeight: '800', letterSpacing: -0.3 },
  sectionDetail: { fontSize: 12, marginTop: 2 },
  sectionAction: { fontSize: 13, fontWeight: '800' },
  syncBadge: { flexDirection: 'row', alignItems: 'center', alignSelf: 'flex-start', gap: 5, borderRadius: 999, paddingHorizontal: 9, paddingVertical: 6 },
  syncText: { fontSize: 11, fontWeight: '800' },
});
