import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, Platform, PermissionsAndroid } from 'react-native';
import { BleManager, Device } from 'react-native-ble-plx';
import { BlurView } from 'expo-blur';
import { SafeAreaView } from 'react-native-safe-area-context';

// Initialize BleManager
// Note: In a production app, you might want to use a Context or a singleton pattern properly.
const manager = Platform.OS === 'web' ? null : new BleManager();

export default function Dashboard() {
  const [devices, setDevices] = useState<Device[]>([]);
  const [isScanning, setIsScanning] = useState(false);

  useEffect(() => {
    if (!manager) return;

    const subscription = manager.onStateChange((state) => {
        if (state === 'PoweredOn') {
            scanAndConnect();
        }
    }, true);

    return () => {
      subscription.remove();
      manager.stopDeviceScan();
    };
  }, []);

  const requestPermissions = async () => {
    if (Platform.OS === 'android') {
       if (Platform.Version >= 31) {
          const result = await PermissionsAndroid.requestMultiple([
            PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN,
            PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT,
            PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
          ]);
          return (
             result['android.permission.BLUETOOTH_SCAN'] === PermissionsAndroid.RESULTS.GRANTED &&
             result['android.permission.BLUETOOTH_CONNECT'] === PermissionsAndroid.RESULTS.GRANTED &&
             result['android.permission.ACCESS_FINE_LOCATION'] === PermissionsAndroid.RESULTS.GRANTED
          );
       } else {
          const granted = await PermissionsAndroid.request(
            PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION
          );
          return granted === PermissionsAndroid.RESULTS.GRANTED;
       }
    }
    return true;
  };

  const scanAndConnect = async () => {
    if (!manager) return;
    const permission = await requestPermissions();
    if (permission) {
      setIsScanning(true);
      manager.startDeviceScan(null, null, (error, device) => {
        if (error) {
          console.log('BLE Scan Error:', error);
          // Don't stop scanning on error immediately in loop, but here it's a callback.
          return;
        }
        if (device) {
           setDevices(prev => {
             // Avoid duplicates based on ID
             if (!prev.find(d => d.id === device.id)) {
               return [...prev, device];
             }
             // Optional: Update RSSI if device already exists
             return prev.map(d => d.id === device.id ? device : d);
           });
        }
      });
    }
  };

  const renderItem = ({ item }: { item: Device }) => (
    <BlurView intensity={20} tint="light" className="mb-4 mx-4 rounded-xl overflow-hidden border border-white/20">
      <View className="p-4">
        <View className="flex-row justify-between items-center mb-2">
           <Text className="text-white font-bold text-lg">{item.name || 'Unknown Device'}</Text>
           <Text className="text-purple-300 font-bold text-xs">{item.rssi} dBm</Text>
        </View>
        <Text className="text-white/60 text-xs font-mono">{item.id}</Text>
      </View>
    </BlurView>
  );

  return (
    <SafeAreaView className="flex-1" edges={['top']}>
      <View className="px-6 py-4">
         <Text className="text-3xl font-bold text-white mb-2 shadow-neon">SCANNER</Text>
         <View className="flex-row items-center gap-2">
            <View className={`w-2 h-2 rounded-full ${isScanning ? 'bg-green-400' : 'bg-red-400'} animate-pulse`} />
            <Text className="text-white/50 text-sm uppercase tracking-widest">
                {isScanning ? 'Scanning for signals...' : 'Scanner Offline'}
            </Text>
         </View>
      </View>
      <FlatList
        data={devices}
        keyExtractor={item => item.id}
        renderItem={renderItem}
        contentContainerStyle={{ paddingBottom: 100, paddingTop: 10 }}
        ListEmptyComponent={
            <Text className="text-white/30 text-center mt-20">No devices found nearby.</Text>
        }
      />
    </SafeAreaView>
  );
}
