import Ionicons from '@expo/vector-icons/Ionicons';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { DarkTheme, DefaultTheme, NavigationContainer } from '@react-navigation/native';
import { useFonts } from 'expo-font';
import { StatusBar } from 'expo-status-bar';
import React, { useEffect, useState } from 'react';
import { ActivityIndicator, StyleSheet, View } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { AppProvider } from './lib/store';
import { useAppTheme } from './lib/theme';
import AppointmentsScreen from './screens/AppointmentsScreen';
import ChatScreen from './screens/ChatScreen';
import HistoryScreen from './screens/HistoryScreen';
import { ConsentScreen, IdentityMethod, LoginScreen, SplashScreen } from './screens/OnboardingScreens';

export type RootTabParamList = {
  Chat: undefined;
  History: undefined;
  Appointments: { startBooking?: boolean; urgent?: boolean; nonce?: number } | undefined;
};

const Tab = createBottomTabNavigator<RootTabParamList>();

function AppNavigation() {
  const theme = useAppTheme();
  const { colors } = theme;
  const navigationTheme = {
    ...(theme.dark ? DarkTheme : DefaultTheme),
    colors: {
      ...(theme.dark ? DarkTheme.colors : DefaultTheme.colors),
      primary: colors.primary,
      background: colors.canvas,
      card: colors.surface,
      text: colors.text,
      border: colors.line,
      notification: colors.danger,
    },
  };

  return (
    <NavigationContainer theme={navigationTheme}>
      <StatusBar style={theme.dark ? 'light' : 'dark'} />
      <Tab.Navigator
        initialRouteName="Chat"
        screenOptions={({ route }) => ({
          headerShown: false,
          tabBarHideOnKeyboard: true,
          tabBarActiveTintColor: colors.primary,
          tabBarInactiveTintColor: colors.subtle,
          tabBarStyle: [styles.tabBar, { backgroundColor: colors.surface, borderTopColor: colors.line }],
          tabBarLabelStyle: styles.tabLabel,
          tabBarIcon: ({ color, focused }) => {
            const names: Record<keyof RootTabParamList, { active: keyof typeof Ionicons.glyphMap; idle: keyof typeof Ionicons.glyphMap }> = {
              Chat: { active: 'chatbubble-ellipses', idle: 'chatbubble-ellipses-outline' },
              History: { active: 'folder-open', idle: 'folder-open-outline' },
              Appointments: { active: 'calendar', idle: 'calendar-outline' },
            };
            return (
              <View style={[styles.tabIcon, focused && { backgroundColor: colors.primarySoft }]}>
                <Ionicons name={focused ? names[route.name].active : names[route.name].idle} size={21} color={color} />
              </View>
            );
          },
        })}
      >
        <Tab.Screen name="Chat" component={ChatScreen} options={{ tabBarLabel: 'Chat' }} />
        <Tab.Screen name="History" component={HistoryScreen} options={{ tabBarLabel: 'History' }} />
        <Tab.Screen name="Appointments" component={AppointmentsScreen} options={{ tabBarLabel: 'Appointments' }} />
      </Tab.Navigator>
    </NavigationContainer>
  );
}

function EntryFlow() {
  const [stage, setStage] = useState<'splash' | 'login' | 'consent' | 'app'>('splash');
  const [identityMethod, setIdentityMethod] = useState<IdentityMethod>('Mobile OTP');

  useEffect(() => {
    const timer = setTimeout(() => setStage('login'), 1450);
    return () => clearTimeout(timer);
  }, []);

  if (stage === 'splash') return <SplashScreen />;
  if (stage === 'login') return <LoginScreen onContinue={(method) => { setIdentityMethod(method); setStage('consent'); }} />;
  if (stage === 'consent') return <ConsentScreen method={identityMethod} onBack={() => setStage('login')} onComplete={() => setStage('app')} />;
  return <AppProvider><AppNavigation /></AppProvider>;
}

export default function App() {
  const [fontsLoaded] = useFonts({ ...Ionicons.font });

  if (!fontsLoaded) {
    return (
      <View style={styles.loading}>
        <ActivityIndicator color="#0E7567" size="large" />
      </View>
    );
  }

  return (
    <GestureHandlerRootView style={styles.flex}>
      <SafeAreaProvider>
        <EntryFlow />
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  loading: { flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: '#F6F8F4' },
  tabBar: { height: 72, paddingTop: 7, paddingBottom: 9, borderTopWidth: 1, elevation: 12, shadowColor: '#122D27', shadowOpacity: 0.08, shadowRadius: 16, shadowOffset: { width: 0, height: -5 } },
  tabLabel: { fontSize: 10.5, fontWeight: '800', marginTop: 1 },
  tabIcon: { width: 40, height: 30, borderRadius: 13, alignItems: 'center', justifyContent: 'center' },
});
