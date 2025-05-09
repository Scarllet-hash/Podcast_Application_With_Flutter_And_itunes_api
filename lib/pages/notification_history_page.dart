// lib/pages/notification_history_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../models/motivation_tip.dart';

class NotificationHistoryPage extends StatefulWidget {
  const NotificationHistoryPage({Key? key}) : super(key: key);

  @override
  State<NotificationHistoryPage> createState() =>
      _NotificationHistoryPageState();
}

class _NotificationHistoryPageState extends State<NotificationHistoryPage> {
  final NotificationService _notificationService = NotificationService();

  // Définition du thème de couleur inspiré de l'image
  final Color primaryColor = const Color(0xFF5F31F2);
  final Color secondaryColor = const Color(0xFF9D54F9);
  final Color accentColor = const Color(0xFF5436F4);
  final Color backgroundColor = Colors.white;
  final Color cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final notificationHistory = _notificationService.notificationHistory;
    final reversedHistory = notificationHistory.reversed.toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Historique des notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          // Bouton pour envoyer une notification test
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              _notificationService.showMotivationNotification();
              setState(() {});
            },
            tooltip: 'Envoyer une notification test',
          ),

          // Bouton pour effacer l'historique (visible uniquement si l'historique n'est pas vide)
          if (notificationHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                await _notificationService.clearNotificationHistory();
                setState(() {});
              },
              tooltip: 'Effacer tout l\'historique',
            ),
        ],
      ),
      body: Column(
        children: [
          // Section de contrôle des notifications avec design amélioré
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Toggle pour activer/désactiver les notifications
                SwitchListTile(
                  title: const Text(
                    'Notifications de motivation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    _notificationService.notificationsEnabled
                        ? 'Activées - Vous recevrez des conseils de motivation régulièrement'
                        : 'Désactivées - Aucune notification ne sera envoyée',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  value: _notificationService.notificationsEnabled,
                  onChanged: (value) async {
                    await _notificationService.toggleNotifications();
                    setState(() {});
                  },
                  secondary: Icon(
                    _notificationService.notificationsEnabled
                        ? Icons.notifications_on
                        : Icons.notifications_off,
                    color: Colors.white,
                    size: 28,
                  ),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.white.withOpacity(0.5),
                  inactiveThumbColor: Colors.white.withOpacity(0.8),
                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),

          // Titre de la section historique avec style amélioré
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.history, size: 20, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Historique des notifications (${notificationHistory.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                ),
                const Spacer(),
                // Indicateur de progression comme dans l'image
                if (notificationHistory.isNotEmpty)
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Text(
                        "${(notificationHistory.length > 10 ? 100 : notificationHistory.length * 10)}%",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Liste des notifications
          Expanded(
            child:
                reversedHistory.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: primaryColor.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune notification dans l\'historique',
                            style: TextStyle(
                              fontSize: 16,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Les notifications que vous recevrez apparaîtront ici',
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: reversedHistory.length,
                      itemBuilder: (context, index) {
                        final tip = reversedHistory[index];
                        // Alterner les couleurs des cartes pour un design plus varié
                        final cardGradient =
                            index % 2 == 0
                                ? [primaryColor, secondaryColor]
                                : [secondaryColor, accentColor];
                        return NotificationHistoryTile(
                          tip: tip,
                          gradientColors: cardGradient,
                        );
                      },
                    ),
          ),
        ],
      ),
      // Bouton flottant pour ajouter une notification test avec design amélioré
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _notificationService.showMotivationNotification();
          setState(() {});
        },
        tooltip: 'Envoyer une notification test',
        backgroundColor: primaryColor,
        child: const Icon(Icons.add_alert, color: Colors.white),
        elevation: 4,
      ),
    );
  }
}

class NotificationHistoryTile extends StatelessWidget {
  final MotivationTip tip;
  final List<Color> gradientColors;

  const NotificationHistoryTile({
    Key? key,
    required this.tip,
    required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate =
        tip.timestamp != null
            ? dateFormatter.format(tip.timestamp!)
            : 'Date inconnue';

    return Hero(
      tag: 'notification_${tip.timestamp?.millisecondsSinceEpoch ?? 0}',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: gradientColors[0].withOpacity(0.2),
              child: Icon(Icons.notifications_active, color: gradientColors[0]),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    tip.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: gradientColors[0],
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: gradientColors[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 10,
                      color: gradientColors[0],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                tip.body,
                style: const TextStyle(fontSize: 14, height: 1.3),
              ),
            ),
            isThreeLine: true,
            onTap: () {
              // Animation à l'appui sur la tuile
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notification du ${formattedDate}'),
                  backgroundColor: gradientColors[0],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
