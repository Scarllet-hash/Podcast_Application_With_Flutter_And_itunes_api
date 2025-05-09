import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'pages/home_page.dart';
//modified

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
