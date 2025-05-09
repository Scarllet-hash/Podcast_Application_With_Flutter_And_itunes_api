// lib/data/motivation_data.dart
import '../models/motivation_tip.dart';

class MotivationData {
  static List<MotivationTip> getMotivationTips() {
    return [
      MotivationTip(
        title: "Restez concentré",
        body: "Prenez 5 minutes pour respirer profondément avant chaque session d'étude.",
        timestamp: null, // Ajout du paramètre timestamp
      ),
      MotivationTip(
        title: "Hydratez-vous",
        body: "Boire suffisamment d'eau améliore la concentration et réduit la fatigue mentale.",
        timestamp: null,
      ),
      MotivationTip(
        title: "Technique Pomodoro",
        body: "Étudiez pendant 25 minutes, puis prenez une pause de 5 minutes. Votre cerveau vous remerciera!",
        timestamp: null,
      ),
      MotivationTip(
        title: "Exercice rapide",
        body: "Faites quelques étirements pour réduire la tension et améliorer la circulation sanguine.",
        timestamp: null,
      ),
      MotivationTip(
        title: "Visualisez votre réussite",
        body: "Imaginez-vous réussir vos examens avec confiance et compétence.",
        timestamp: null,
      ),
      MotivationTip(
        title: "Organisez votre espace",
        body: "Un espace de travail bien rangé aide à maintenir un esprit clair et concentré.",
        timestamp: null,
      ),
      MotivationTip(
        title: "Célébrez vos progrès",
        body: "Prenez un moment pour apprécier ce que vous avez déjà accompli aujourd'hui.",
        timestamp: null,
      ),
      MotivationTip(
        title: "Routine énergisante",
        body: "Tournez vos épaules en cercles pendant 30 secondes pour soulager la tension du cou.",
        timestamp: null,
      ),
      MotivationTip(
        title: "Pause méditative",
        body: "Fermez les yeux et concentrez-vous uniquement sur votre respiration pendant 1 minute.",
        timestamp: null,
      ),
      MotivationTip(
        title: "Pensée positive",
        body: "Les défis d'aujourd'hui sont les compétences de demain. Vous progressez à chaque étape.",
        timestamp: null,
      ),
    ];
  }
}