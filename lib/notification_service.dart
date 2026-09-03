import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  // ==========================================================
  // CONSTANT
  // ==========================================================

  static const String channelId =
      'aquamass_water_reminder';

  static const String channelName =
      'AquaMass Water Reminder';

  static const String channelDescription =
      'Pengingat minum air putih dari AquaMass';

  static const int baseNotificationId = 10000;

  // ==========================================================
  // INITIALIZE
  // ==========================================================

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    final timezone =
    await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(
      tz.getLocation(timezone.identifier),
    );

    // Android
    const androidSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS / macOS
    const darwinSettings =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings =
    InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notifications.initialize(
      settings: initializationSettings,
    );

    await _requestPermissions();
  }

  // ==========================================================
  // REQUEST PERMISSION
  // ==========================================================

  Future<void> _requestPermissions() async {
    // Android 13+
    final android =
    _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();

    // iOS
    final ios =
    _notifications
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // macOS
    final macOS =
    _notifications
        .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();

    await macOS?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ==========================================================
  // TEST NOTIFICATION
  // ==========================================================

  Future<void> showTestNotification() async {
    const notificationDetails =
    NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Untuk TEST kita gunakan show() langsung.
    // Ini memastikan permission + notification channel
    // benar-benar bekerja tanpa dipengaruhi scheduling Android.
    await _notifications.show(
      id: 999999,
      title: 'AquaMass Test 💧🦆',
      body: 'Quack! Notifikasi AquaMass berhasil! 🎉',
      notificationDetails: notificationDetails,
      payload: 'test_notification',
    );
  }

  // ==========================================================
  // CANCEL ALL
  // ==========================================================

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  // ==========================================================
  // NOTIFICATION ID
  // ==========================================================

  int _getNotificationId(
      DateTime date,
      int drinkIndex,
      ) {
    final dateNumber =
        date.year * 10000 +
            date.month * 100 +
            date.day;

    return baseNotificationId +
        (dateNumber * 100) +
        drinkIndex;
  }

  // ==========================================================
  // CALCULATE DRINK TIME
  // ==========================================================

  DateTime _calculateDrinkTime({
    required DateTime date,
    required int drinkIndex,
    required int targetDrinks,
  }) {
    const int startMinutes = 7 * 60;
    const int endMinutes = 21 * 60;

    if (targetDrinks <= 1) {
      return DateTime(
        date.year,
        date.month,
        date.day,
        14,
        0,
      );
    }

    final totalMinutes =
        endMinutes - startMinutes;

    final interval =
        totalMinutes / (targetDrinks - 1);

    final minutes =
    (startMinutes +
        (drinkIndex * interval))
        .round();

    return DateTime(
      date.year,
      date.month,
      date.day,
      minutes ~/ 60,
      minutes % 60,
    );
  }

  // ==========================================================
  // SCHEDULE DAILY REMINDERS
  // ==========================================================

  Future<void> scheduleDailyReminders({
    required int targetDrinks,
    required int currentDrinkCount,
  }) async {
    // Hapus jadwal lama.
    await cancelAllReminders();

    if (targetDrinks <= 0) {
      return;
    }

    final now =
    tz.TZDateTime.now(tz.local);

    const int scheduleDays = 7;

    for (
    int dayOffset = 0;
    dayOffset < scheduleDays;
    dayOffset++
    ) {
      final currentDate =
      now.add(
        Duration(days: dayOffset),
      );

      // ======================================================
      // HARI INI
      // ======================================================

      if (dayOffset == 0) {
        // Kalau hari ini sudah mencapai target,
        // tidak perlu membuat reminder hari ini.
        if (currentDrinkCount >= targetDrinks) {
          continue;
        }
      }

      // Hari ini dimulai dari jumlah minum sekarang.
      //
      // Contoh:
      // target = 8
      // sudah minum = 3
      //
      // reminder dimulai dari index 3.
      //
      // Besok dan seterusnya selalu mulai dari index 0.

      final firstDrinkIndex =
      dayOffset == 0
          ? currentDrinkCount
          : 0;

      for (
      int drinkIndex = firstDrinkIndex;
      drinkIndex < targetDrinks;
      drinkIndex++
      ) {
        final calculatedTime =
        _calculateDrinkTime(
          date: currentDate,
          drinkIndex: drinkIndex,
          targetDrinks: targetDrinks,
        );

        final scheduledDate =
        tz.TZDateTime(
          tz.local,
          calculatedTime.year,
          calculatedTime.month,
          calculatedTime.day,
          calculatedTime.hour,
          calculatedTime.minute,
        );

        // Jangan schedule waktu yang sudah lewat.
        if (scheduledDate.isBefore(now)) {
          continue;
        }

        final notificationId =
        _getNotificationId(
          calculatedTime,
          drinkIndex,
        );

        const notificationDetails =
        NotificationDetails(
          android:
          AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription:
            channelDescription,
            importance:
            Importance.high,
            priority:
            Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS:
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS:
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );

        await _notifications.zonedSchedule(
          id: notificationId,
          title:
          'Waktunya minum! 💧🦆',
          body:
          'Quack! Jangan lupa minum air putih agar tetap terhidrasi.',
          scheduledDate:
          scheduledDate,
          notificationDetails:
          notificationDetails,
          androidScheduleMode:
          AndroidScheduleMode
              .inexactAllowWhileIdle,
          payload:
          'water_reminder',
        );
      }
    }
  }

  // ==========================================================
  // RESCHEDULE
  // ==========================================================

  Future<void> updateReminderSchedule({
    required int targetDrinks,
    required int currentDrinkCount,
  }) async {
    await scheduleDailyReminders(
      targetDrinks: targetDrinks,
      currentDrinkCount: currentDrinkCount,
    );
  }
}