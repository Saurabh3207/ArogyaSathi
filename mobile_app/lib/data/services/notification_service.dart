import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../local/database_helper.dart';
import '../models/local_reminder_model.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Schedules all pending reminders from the Local_Reminder table
  Future<void> scheduleReminders() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Local_Reminder',
      where: 'is_triggered = 0',
    );

    List<LocalReminder> reminders = List.generate(maps.length, (i) {
      return LocalReminder.fromMap(maps[i]);
    });

    for (var reminder in reminders) {
      await _scheduleAwesomeNotification(reminder);
    }
  }

  Future<void> _scheduleAwesomeNotification(LocalReminder reminder) async {
    try {
      DateTime scheduledDate = DateTime.parse(reminder.scheduledDate);
      
      // Only schedule if it's in the future
      if (scheduledDate.isBefore(DateTime.now())) return;

      final db = await _dbHelper.database;
      final patientResult = await db.query(
        'Patient',
        columns: ['first_name'],
        where: 'patient_id = ?',
        whereArgs: [reminder.patientId],
      );

      String patientName = patientResult.isNotEmpty 
          ? patientResult.first['first_name'] as String 
          : "Patient";

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: reminder.reminderId.hashCode,
          channelKey: 'alerts',
          title: 'Reminder: ${reminder.reminderType}',
          body: 'Follow-up needed for $patientName on ${DateFormat('dd MMM').format(scheduledDate)}',
          notificationLayout: NotificationLayout.Default,
          payload: {'patientId': reminder.patientId},
        ),
        schedule: NotificationCalendar.fromDate(date: scheduledDate),
      );
    } catch (e) {
      debugPrint("Error scheduling individual notification: $e");
    }
  }

  /// Cancels a specific notification
  Future<void> cancelNotification(String reminderId) async {
    await AwesomeNotifications().cancel(reminderId.hashCode);
  }

  /// Requests notification permissions if not granted
  Future<void> requestPermissions(BuildContext context) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }
}
