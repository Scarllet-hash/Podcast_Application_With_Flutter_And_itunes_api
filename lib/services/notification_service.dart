// lib/services/notification_service.dart
import 'dart:math';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/motivation_tip.dart';
import '../data/motivation_data.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  Timer? _notificationTimer;
  List<MotivationTip> _notificationHistory = [];
  bool _notificationsEnabled = false;
  
  bool get notificationsEnabled => _notificationsEnabled;
  List<MotivationTip> get notificationHistory => _notificationHistory;
  
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Gérer l'action lorsque l'utilisateur clique sur la notification
        print('Notification clicked: ${response.payload}');
      },
    );
    
    // Charger l'historique des notifications
    await _loadNotificationHistory();
    
    // Vérifier si les notifications sont activées
    await _loadNotificationSettings();
    
    // Si les notifications sont activées, les relancer
    if (_notificationsEnabled) {
      await schedulePeriodicNotifications();
    }
  }
  
  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
  }
  
  Future<void> _saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
  }
  
  Future<void> _loadNotificationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('notification_history') ?? [];
    
    _notificationHistory = historyJson
        .map((json) => MotivationTip.fromMap(jsonDecode(json)))
        .toList();
  }
  
  Future<void> _saveNotificationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _notificationHistory
        .map((tip) => jsonEncode(tip.toMap()))
        .toList();
    
    // Limiter l'historique aux 50 dernières notifications
    if (historyJson.length > 50) {
      historyJson.removeRange(0, historyJson.length - 50);
    }
    
    await prefs.setStringList('notification_history', historyJson);
  }
  
  Future<void> requestPermissions() async {
    // Pour iOS
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        
    // Pour Android 13+
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  MotivationTip _getRandomTip() {
    final tips = MotivationData.getMotivationTips();
    final random = Random();
    return tips[random.nextInt(tips.length)];
  }
  
  Future<void> showMotivationNotification() async {
    final tip = _getRandomTip();
    
    // Ajouter un timestamp
    final tipWithTimestamp = MotivationTip(
      title: tip.title, 
      body: tip.body,
      timestamp: DateTime.now(),
    );
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'motivation_channel',
      'Motivation',
      channelDescription: 'Channel for motivational notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await flutterLocalNotificationsPlugin.show(
      0,
      tipWithTimestamp.title,
      tipWithTimestamp.body,
      platformChannelSpecifics,
    );
    
    // Ajouter à l'historique
    _notificationHistory.add(tipWithTimestamp);
    await _saveNotificationHistory();
  }
  
  // Nouvelle méthode pour planifier des notifications avec différents conseils à chaque fois
  Future<void> schedulePeriodicNotifications() async {
    // Annuler d'abord toutes les notifications programmées
    await flutterLocalNotificationsPlugin.cancelAll();
    
    // Annuler le timer existant s'il y en a un
    _notificationTimer?.cancel();
    
    // Mettre à jour l'état
    _notificationsEnabled = true;
    await _saveNotificationSettings();
    
    // Utiliser un timer pour envoyer une notification différente chaque minute
    _notificationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      showMotivationNotification();
    });
    
    // Montrer immédiatement la première notification
    await showMotivationNotification();
  }
  
  Future<void> stopNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    _notificationTimer?.cancel();
    _notificationTimer = null;
    
    _notificationsEnabled = false;
    await _saveNotificationSettings();
  }
  
  Future<void> toggleNotifications() async {
    if (_notificationsEnabled) {
      await stopNotifications();
    } else {
      await schedulePeriodicNotifications();
    }
  }
  
  Future<void> clearNotificationHistory() async {
    _notificationHistory.clear();
    await _saveNotificationHistory();
  }
}

