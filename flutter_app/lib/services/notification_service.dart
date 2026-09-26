import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/medication_model.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    tz.initializeTimeZones();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(settings);
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  Future<void> scheduleForMedications(List<Medication> medications) async {
    if (!_initialized) await initialize();
    if (!_initialized) return;

    await _notifications.cancelAll();
    for (final medication in medications) {
      for (var index = 0; index < medication.doseTimes.length; index++) {
        final doseTime = _parseDoseTime(medication.doseTimes[index]);
        if (doseTime == null) continue;

        final notificationId = _notificationId(medication, index);
        await _schedule(
          notificationId,
          medication,
          doseTime,
          title: 'Medication reminder',
          body: 'Time to take ${medication.name} (${medication.dosage}).',
        );
        await _schedule(
          notificationId + 1,
          medication,
          doseTime.add(const Duration(minutes: 30)),
          title: 'Missed medication reminder',
          body:
              'You may have missed ${medication.name}. Please take it if appropriate.',
        );
      }
    }
  }

  Future<void> _schedule(
    int id,
    Medication medication,
    tz.TZDateTime time, {
    required String title,
    required String body,
  }) {
    return _notifications.zonedSchedule(
      id,
      title,
      body,
      time,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders',
          'Medication reminders',
          channelDescription: 'Reminders for scheduled medication doses',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: medication.id,
    );
  }

  tz.TZDateTime? _parseDoseTime(String value) {
    final parts = value.trim().toUpperCase().split(' ');
    if (parts.length != 2) return null;
    final clock = parts[0].split(':');
    if (clock.length != 2) return null;

    final hour = int.tryParse(clock[0]);
    final minute = int.tryParse(clock[1]);
    if (hour == null ||
        minute == null ||
        hour < 1 ||
        hour > 12 ||
        minute > 59) {
      return null;
    }

    var hour24 = hour % 12;
    if (parts[1] == 'PM') hour24 += 12;
    if (parts[1] != 'AM' && parts[1] != 'PM') return null;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour24,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  int _notificationId(Medication medication, int doseIndex) {
    final key = '${medication.id ?? medication.name}:$doseIndex';
    return key.codeUnits.fold(17, (value, code) => value * 31 + code) &
        0x7fffffff;
  }
}
