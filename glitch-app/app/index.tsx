import React, { useState } from 'react';
import { View, TextInput, TouchableOpacity, Text, Alert, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { BlurView } from 'expo-blur';
import { LinearGradient } from 'expo-linear-gradient';
import GlitchText from '../components/GlitchText';
import { checkCredentials } from '../db';

export default function LoginScreen() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    // For demo purposes, we can allow empty login or check DB.
    // If the DB call fails (e.g. no internet), we might want to handle it.
    if (!email || !password) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    setLoading(true);
    try {
      const isValid = await checkCredentials(email, password);
      if (isValid) {
        router.push('/dashboard');
      } else {
        Alert.alert('Access Denied', 'Invalid credentials');
      }
    } catch (e) {
      Alert.alert('Error', 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View className="flex-1 justify-center items-center px-6 gap-8">
      <View className="mb-10">
        <GlitchText />
      </View>

      <View className="w-full gap-4">
        {/* Email Input */}
        <BlurView intensity={20} tint="light" className="overflow-hidden rounded-2xl border border-white/20">
          <View className="px-4 py-3">
             <Text className="text-white/60 text-xs font-bold uppercase mb-1">Email</Text>
             <TextInput
               className="text-white text-lg font-bold h-10"
               placeholderTextColor="#ffffff50"
               value={email}
               onChangeText={setEmail}
               autoCapitalize="none"
               keyboardType="email-address"
             />
          </View>
        </BlurView>

        {/* Password Input */}
        <BlurView intensity={20} tint="light" className="overflow-hidden rounded-2xl border border-white/20">
          <View className="px-4 py-3">
             <Text className="text-white/60 text-xs font-bold uppercase mb-1">Password</Text>
             <TextInput
               className="text-white text-lg font-bold h-10"
               placeholderTextColor="#ffffff50"
               value={password}
               onChangeText={setPassword}
               secureTextEntry
             />
          </View>
        </BlurView>
      </View>

      {/* Login Button */}
      <TouchableOpacity
        onPress={handleLogin}
        disabled={loading}
        className="w-full mt-4"
        activeOpacity={0.8}
      >
        <LinearGradient
          colors={['#D500F9', '#651FFF']}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 0 }}
          className="rounded-full py-4 items-center justify-center shadow-lg shadow-purple-500/50"
        >
          {loading ? (
            <ActivityIndicator color="white" />
          ) : (
            <Text className="text-white font-bold text-lg tracking-widest uppercase">
              Log In
            </Text>
          )}
        </LinearGradient>
      </TouchableOpacity>

      <View className="flex-row gap-6 mt-8">
         <View className="w-12 h-12 rounded-full bg-white/10 items-center justify-center border border-white/10">
            <Text className="text-white font-bold"></Text>
         </View>
         <View className="w-12 h-12 rounded-full bg-white/10 items-center justify-center border border-white/10">
            <Text className="text-white font-bold">G</Text>
         </View>
      </View>

      <Text className="text-white/40 mt-4">Don't have an account? <Text className="text-purple-400 font-bold">Sign Up</Text></Text>
    </View>
  );
}
