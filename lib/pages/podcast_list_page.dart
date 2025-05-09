import 'package:flutter/material.dart';
import '../models/podcast.dart';
import '../services/itunes_api_service.dart';
import 'podcast_player_page.dart';

class PodcastListPage extends StatefulWidget {
  final String category;
  const PodcastListPage({super.key, required this.category});

  @override
  State<PodcastListPage> createState() => _PodcastListPageState();
}

class _PodcastListPageState extends State<PodcastListPage> {
  final ItunesApiService apiService = ItunesApiService();
  late Future<List<Podcast>> futurePodcasts;
  List<Podcast> allPodcasts = [];
  List<Podcast> filteredPodcasts = [];
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    futurePodcasts = _fetchAndStorePodcasts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<List<Podcast>> _fetchAndStorePodcasts() async {
    final podcasts = await apiService.fetchPodcasts(widget.category);
    if (mounted) {
      setState(() {
        allPodcasts = podcasts;
        filteredPodcasts = podcasts;
      });
    }
    return podcasts;
  }

  void _filterPodcasts(String query) {
    if (!mounted) return;

    setState(() {
      if (query.isEmpty) {
        filteredPodcasts = allPodcasts;
      } else {
        filteredPodcasts =
            allPodcasts
                .where(
                  (podcast) =>
                      podcast.title.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      podcast.author.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (isSearching) {
        // Retarder pour laisser l'UI se construire avant de montrer le clavier
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            FocusScope.of(context).requestFocus(_searchFocusNode);
          }
        });
      } else {
        _searchController.clear();
        filteredPodcasts = allPodcasts;
        FocusScope.of(context).unfocus();
      }
    });
  }

  // Fonction pour calculer le pourcentage aléatoire d'écoute
  int getRandomProgress() {
    return DateTime.now().millisecond % 101; // Un nombre entre 0 et 100
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: _toggleSearch,
          ),
        ],
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          // Header avec titre ou barre de recherche
          _buildHeader(),

          // Liste des podcasts
          Expanded(
            child: FutureBuilder<List<Podcast>>(
              future: futurePodcasts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF5E35B1)),
                  );
                } else if (snapshot.hasError) {
                  return _buildErrorView(snapshot.error);
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyView();
                }

                // Les données sont là mais peuvent être filtrées
                final podcastsToShow =
                    isSearching ? filteredPodcasts : snapshot.data!;

                if (isSearching && podcastsToShow.isEmpty) {
                  return _buildNoResultsView();
                }

                return _buildPodcastList(podcastsToShow);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 70, 20, isSearching ? 10 : 25),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 150, 8, 239),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: DecorationImage(
          image: AssetImage('lib/assets/fonts/img1.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          opacity: 0.75,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          isSearching
              ? _buildSearchBar()
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text(
                        "PODCASTS",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${getRandomProgress()}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Rechercher un podcast...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      _filterPodcasts('');
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onChanged: (value) {
          // Optimisation: Retarder la filtration pour réduire les rebuilds
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_searchController.text == value) {
              _filterPodcasts(value);
            }
          });
        },
      ),
    );
  }

  Widget _buildErrorView(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFF5E35B1), size: 60),
          const SizedBox(height: 16),
          Text('Error: ${error}', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.podcasts, color: Color(0xFF5E35B1), size: 60),
          SizedBox(height: 16),
          Text(
            'No podcasts found in this category',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, color: Color(0xFF5E35B1), size: 60),
          const SizedBox(height: 16),
          Text(
            'No podcasts match "${_searchController.text}"',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPodcastList(List<Podcast> podcasts) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      itemCount: podcasts.length,
      itemBuilder: (context, index) {
        return _buildPodcastItem(podcasts[index], index % 2 == 0);
      },
    );
  }

  Widget _buildPodcastItem(Podcast podcast, bool isEven) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isEven ? const Color(0xFF5E35B1) : const Color(0xFFB280E4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PodcastPlayerPage(feedUrl: podcast.audioUrl),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image du podcast
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    podcast.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),

                // Informations du podcast
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          podcast.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          podcast.author,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.headphones,
                              color: Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Listen now",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${getRandomProgress()}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Icône de lecture
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
