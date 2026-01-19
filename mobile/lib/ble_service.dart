import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Для проверки kIsWeb
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleService {
  // Наш уникальный ID сервиса (как секретное рукопожатие)
  // UUID можно сгенерировать онлайн, пока возьмем тестовый
  static const String SERVICE_UUID = "12345678-1234-1234-1234-1234567890ab";

  // Список найденных устройств
  final List<ScanResult> _scanResults = [];

  // Поток данных, чтобы UI обновлялся сам
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  // 1. Инициализация и запрос прав
  Future<bool> init() async {
    if (kIsWeb) {
      print("⚠️ Bluetooth disabled on Web (Emulator mode)");
      return false;
    }

    // Проверяем, включен ли Bluetooth адаптер
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      print("❌ Bluetooth is OFF");
      return false;
    }

    // Запрашиваем права (особенно важно для Android 12+)
    if (Platform.isAndroid) {
      await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location, // Для старых Android
      ].request();
    }
    
    return true;
  }

  // 2. Старт сканирования
  void startScan() async {
    if (kIsWeb) return;

    print("🔵 Starting BLE Scan...");
    
    // Сканируем только устройства, которые рекламируют НАШ сервис
    // (чтобы не видеть чайники и наушники соседей)
    // Пока уберем фильтр, чтобы видеть хоть что-то для теста
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      // withServices: [Guid(SERVICE_UUID)], // Включим позже
    );
  }

  // 3. Стоп
  void stopScan() {
    if (kIsWeb) return;
    FlutterBluePlus.stopScan();
  }
}
