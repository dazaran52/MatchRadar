import "../global.css";
import { Stack } from "expo-router";
import { LinearGradient } from "expo-linear-gradient";
import { View, StyleSheet } from "react-native";
import { StatusBar } from "expo-status-bar";

export default function Layout() {
  return (
    <View style={{ flex: 1 }}>
      <StatusBar style="light" />
      <LinearGradient
        colors={['#2E004E', '#6200EA']}
        style={StyleSheet.absoluteFill}
      />
      <Stack screenOptions={{
          headerShown: false,
          contentStyle: { backgroundColor: 'transparent' },
          animation: 'fade'
      }} />
    </View>
  );
}
