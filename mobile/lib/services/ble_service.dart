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

  // 1. Инициализация и запрос прав (ПРИНУДИТЕЛЬНО)
  Future<bool> init() async {
    if (kIsWeb) return false;

    // Сначала запрашиваем права, не глядя на состояние адаптера
    if (Platform.isAndroid) {
       Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ].request();

      // Если что-то не дали - возвращаем false, UI должен обработать
      if (statuses[Permission.location] != PermissionStatus.granted) {
         print("❌ Location Permission Denied");
         return false;
      }
    }

    // Теперь проверяем адаптер
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      print("❌ Bluetooth is OFF");
      // В реальном приложении здесь можно попросить включить
      try {
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOn();
        }
      } catch (e) {
        // Ignored
      }
      return false;
    }
    
    return true;
  }

  // 2. Старт сканирования
  Future<void> startScan() async {
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
