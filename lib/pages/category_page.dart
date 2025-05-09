import 'package:flutter/material.dart';
import 'podcast_list_page.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      'title': 'Motivation',
      'imagePath': 'lib/assets/fonts/motivation.jpg',
      'progress': 72,
    },
    {
      'title': 'Study',
      'imagePath': 'lib/assets/fonts/study.jpg',
      'progress': 58,
    },
    {
      'title': 'IT & Dev',
      'imagePath': 'lib/assets/fonts/IT.jpg',
      'progress': 45,
    },
    {
      'title': 'Fitness',
      'imagePath': 'lib/assets/fonts/fitness.jpg',
      'progress': 30,
    },
    {
      'title': 'Politics',
      'imagePath': 'lib/assets/fonts/Politics.jpg',
      'progress': 25,
    },
    {
      'title': 'Health care',
      'imagePath': 'lib/assets/fonts/health.jpg',
      'progress': 15,
    },
    {
      'title': 'Podcasts marocains',
      'imagePath': 'lib/assets/fonts/morocain.jpg',
      'progress': 8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Elegant color scheme inspired by the reference design
    const Color primaryPurple = Color.fromARGB(255, 168, 8, 241);
    const Color accentPurple = Color.fromARGB(255, 183, 12, 160);
    const Color lightPurple = Color.fromARGB(255, 205, 206, 253);
    const Color backgroundPurple = Color.fromARGB(255, 235, 143, 249);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section avec image étendue (style similaire à l'image partagée)
          Container(
            padding: EdgeInsets.only(
              top:
                  MediaQuery.of(
                    context,
                  ).padding.top, // Pour respecter la safe area
              bottom: 20,
              left: 16,
              right: 16,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color.fromARGB(
                255,
                150,
                8,
                239,
              ), // Couleur violette de la première image
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              image: DecorationImage(
                image: AssetImage('lib/assets/fonts/img1.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                opacity: 0.75, // Augmenté pour mieux voir l'image
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bar de navigation en haut
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),

                // Titres superposés sur l'image
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ENGLISH',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'MAIN UNITS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main content area with elegant cards
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  top: 30,
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? primaryPurple : backgroundPurple,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PodcastListPage(
                                    category: categories[index]['title'],
                                  ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              // Images au lieu d'icônes
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color:
                                      index % 2 == 0
                                          ? Colors.white.withOpacity(0.2)
                                          : accentPurple.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    categories[index]['imagePath'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Middle section with title and progress
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'UNIT ${index + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            index % 2 == 0
                                                ? lightPurple
                                                : accentPurple,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      categories[index]['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            index % 2 == 0
                                                ? Colors.white
                                                : primaryPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
