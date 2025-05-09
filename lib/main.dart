// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'pages/category_page.dart';

// void main() {
//   runApp(const CoStudyApp());
// }

// class CoStudyApp extends StatelessWidget {
//   const CoStudyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'CoStudy',
//       theme: ThemeData(
//         textTheme: GoogleFonts.ralewayTextTheme(),
//         scaffoldBackgroundColor: const Color(0xFFF4F4F4),
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const HomePage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// lib/main.dart

// import 'package:flutter/material.dart';
// import 'local_notifications.dart';

// void main() async {
//   // Assurez-vous que les liaisons Flutter sont initialisées
//   WidgetsFlutterBinding.ensureInitialized();

//   // Exécutez l'application
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Test Notifications',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const NotificationPage(),
//     );
//   }
// }

// class NotificationPage extends StatefulWidget {
//   const NotificationPage({Key? key}) : super(key: key);

//   @override
//   State<NotificationPage> createState() => _NotificationPageState();
// }

// class _NotificationPageState extends State<NotificationPage> {
//   final NotificationService _notificationService = NotificationService();
//   bool _notificationsInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeNotifications();
//   }

//   // Initialiser les notifications
//   Future<void> _initializeNotifications() async {
//     try {
//       await _notificationService.initializeNotifications();

//       setState(() {
//         _notificationsInitialized = true;
//       });

//       print('Notifications initialized successfully');
//     } catch (e) {
//       print('Error initializing notifications: $e');
//     }
//   }

//   // Afficher une notification
//   Future<void> _showNotification() async {
//     try {
//       print('Attempting to show notification');

//       await _notificationService.showNotification(
//         title: 'You Win',
//         body: 'hi safae',
//         payload: 'test_payload',
//       );

//       print('Notification shown successfully');

//       // Ajouter un retour visuel dans l'application
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'Notification envoyée ! Vérifiez la barre de notification',
//             ),
//             duration: Duration(seconds: 5),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error showing notification: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Test Notifications')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               _notificationsInitialized
//                   ? 'Les notifications sont initialisées'
//                   : 'Initialisation des notifications...',
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _notificationsInitialized ? _showNotification : null,
//               child: const Text('Afficher une notification'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/main.dart
import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser le service de notification
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Costudy',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
