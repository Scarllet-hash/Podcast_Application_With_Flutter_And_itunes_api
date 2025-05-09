import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class PodcastPlayerPage extends StatefulWidget {
  final String feedUrl; // URL du flux RSS du podcast
  const PodcastPlayerPage({super.key, required this.feedUrl});

  @override
  _PodcastPlayerPageState createState() => _PodcastPlayerPageState();
}

class _PodcastPlayerPageState extends State<PodcastPlayerPage>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _player;
  String? _audioUrl;
  String? _podcastTitle;
  String? _podcastAuthor;
  String? _podcastImageUrl;
  bool _isPlaying = false; // État de lecture initial

  // Liste des épisodes et index courant
  List<Map<String, dynamic>> _episodesList = [];
  int _currentEpisodeIndex = 0;

  // Pour les animations
  late AnimationController _animationController;
  late Animation<double> _playPauseAnimation;

  // Couleurs du thème
  final Color _primaryColor = Color(0xFF9C27B0); // Violet
  final Color _accentColor = Color(0xFFE040FB); // Magenta
  final Color _darkColor = Color(0xFF1E1E2E); // Fond sombre

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    // Configuration de l'animation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _playPauseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    // Écouter les changements d'état de lecture
    _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      // Mettre à jour l'état uniquement s'il a changé
      if (isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = isPlaying;
          if (_isPlaying) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        });
      }
    });

    _loadPodcast();
  }

  Future<void> _loadPodcast() async {
    try {
      final response = await http.get(Uri.parse(widget.feedUrl));

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final items = document.findAllElements('item');

        // Stocke tous les épisodes
        List<Map<String, dynamic>> episodes = [];

        for (var item in items) {
          final audioUrl =
              item.findElements('enclosure').isNotEmpty
                  ? item.findElements('enclosure').first.getAttribute('url')
                  : null;
          final title =
              item.findElements('title').isNotEmpty
                  ? item.findElements('title').first.text
                  : 'Unknown Title';
          final author =
              item.findElements('itunes:author').isNotEmpty
                  ? item.findElements('itunes:author').first.text
                  : 'Unknown Author';
          final imageUrl =
              item.findElements('itunes:image').isNotEmpty
                  ? item.findElements('itunes:image').first.getAttribute('href')
                  : null;

          if (audioUrl != null) {
            episodes.add({
              'audioUrl': audioUrl,
              'title': title,
              'author': author,
              'imageUrl': imageUrl,
            });
          }
        }

        if (episodes.isNotEmpty) {
          setState(() {
            _episodesList = episodes;
            _loadEpisode(0); // Charge le premier épisode par défaut
          });
        } else {
          throw Exception('No podcasts found in the RSS feed.');
        }
      } else {
        throw Exception('Failed to load RSS feed.');
      }
    } catch (e) {
      print('Error loading podcast: $e');
      setState(() {
        _podcastTitle = 'Error loading podcast';
        _podcastAuthor = '';
        _audioUrl = '';
        _podcastImageUrl = '';
      });
    }
  }

  // Charge un épisode spécifique par son index
  Future<void> _loadEpisode(int index) async {
    if (index < 0 || index >= _episodesList.length) return;

    setState(() {
      _currentEpisodeIndex = index;
      _audioUrl = _episodesList[index]['audioUrl'];
      _podcastTitle = _episodesList[index]['title'];
      _podcastAuthor = _episodesList[index]['author'];
      _podcastImageUrl = _episodesList[index]['imageUrl'];
    });

    await _player.stop();
    await _player.setUrl(_audioUrl!);
    _player.play();
  }

  // Passe à l'épisode suivant s'il existe
  void _nextEpisode() {
    if (_currentEpisodeIndex < _episodesList.length - 1) {
      _loadEpisode(_currentEpisodeIndex + 1);
    }
  }

  // Passe à l'épisode précédent s'il existe
  void _previousEpisode() {
    if (_currentEpisodeIndex > 0) {
      _loadEpisode(_currentEpisodeIndex - 1);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  void _forward10Seconds() {
    final newPosition = _player.position + Duration(seconds: 10);
    _player.seek(newPosition);
  }

  void _rewind10Seconds() {
    final newPosition = _player.position - Duration(seconds: 10);
    _player.seek(newPosition);
  }

  // Affiche la liste des épisodes dans une bottom sheet
  void _showEpisodesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: _darkColor.withOpacity(0.95),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Barre de poignée
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Titre
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Liste des épisodes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Nombre d'épisodes
              Text(
                '${_episodesList.length} épisodes disponibles',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),

              SizedBox(height: 16),

              // Liste des épisodes
              Expanded(
                child: ListView.builder(
                  itemCount: _episodesList.length,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final episode = _episodesList[index];
                    final isCurrentEpisode = index == _currentEpisodeIndex;

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        if (index != _currentEpisodeIndex) {
                          _loadEpisode(index);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isCurrentEpisode
                                  ? _primaryColor.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              isCurrentEpisode
                                  ? Border.all(color: _accentColor, width: 1)
                                  : null,
                        ),
                        child: Row(
                          children: [
                            // Miniature épisode ou numéro
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child:
                                    isCurrentEpisode
                                        ? Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        )
                                        : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                              ),
                            ),

                            SizedBox(width: 12),

                            // Informations sur l'épisode
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    episode['title'] ?? 'Sans titre',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          isCurrentEpisode
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    episode['author'] ?? 'Auteur inconnu',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_darkColor, _primaryColor, _accentColor],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar personnalisée
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Podcast',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.playlist_play, color: Colors.white),
                      onPressed: () => _showEpisodesBottomSheet(context),
                    ),
                  ],
                ),
              ),

              // Contenu principal avec effet d'ombre
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Image du podcast avec animation d'apparition (taille réduite)
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 800),
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: child,
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'podcast_image',
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.25,
                            width: MediaQuery.of(context).size.height * 0.25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _accentColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child:
                                  _podcastImageUrl != null
                                      ? Image.network(
                                        _podcastImageUrl!,
                                        fit: BoxFit.cover,
                                      )
                                      : Container(
                                        color: _primaryColor.withOpacity(0.5),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Texte: indice de l'épisode dans la liste
                      if (_episodesList.isNotEmpty)
                        Text(
                          "Épisode ${_currentEpisodeIndex + 1}/${_episodesList.length}",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),

                      SizedBox(height: 16),

                      // Détails du podcast avec animation
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              _podcastTitle ?? 'Loading...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _podcastAuthor ?? 'Unknown Author',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // Slider de progression
                      StreamBuilder<Duration>(
                        stream: _player.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final total =
                              _player.duration ?? Duration(seconds: 1);

                          double positionInSeconds =
                              position.inSeconds.toDouble();
                          double maxInSeconds = total.inSeconds.toDouble();

                          if (positionInSeconds < 0.0) positionInSeconds = 0.0;
                          if (positionInSeconds > maxInSeconds)
                            positionInSeconds = maxInSeconds;

                          return Column(
                            children: [
                              SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: _accentColor,
                                  inactiveTrackColor: Colors.white30,
                                  thumbColor: Colors.white,
                                  trackHeight: 4,
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayColor: _accentColor.withOpacity(0.3),
                                ),
                                child: Slider(
                                  value: positionInSeconds,
                                  min: 0.0,
                                  max: maxInSeconds,
                                  onChanged: (value) {
                                    _player.seek(
                                      Duration(seconds: value.toInt()),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      "${total.inMinutes}:${(total.inSeconds % 60).toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: 16),

                      // Boutons de contrôle avec navigation entre épisodes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Bouton précédent
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap:
                                  _currentEpisodeIndex > 0
                                      ? _previousEpisode
                                      : null,
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _currentEpisodeIndex > 0
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.white.withOpacity(0.05),
                                ),
                                child: Icon(
                                  Icons.skip_previous,
                                  color:
                                      _currentEpisodeIndex > 0
                                          ? Colors.white
                                          : Colors.white30,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // Bouton rewind
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: _rewind10Seconds,
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.replay_10,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // Bouton Play/Pause avec animation
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [_primaryColor, _accentColor],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _accentColor.withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: AnimatedBuilder(
                                animation: _playPauseAnimation,
                                builder: (context, child) {
                                  return Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 36,
                                  );
                                },
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // Bouton forward
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: _forward10Seconds,
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.forward_10,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // Bouton suivant
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap:
                                  _currentEpisodeIndex <
                                          _episodesList.length - 1
                                      ? _nextEpisode
                                      : null,
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _currentEpisodeIndex <
                                              _episodesList.length - 1
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.white.withOpacity(0.05),
                                ),
                                child: Icon(
                                  Icons.skip_next,
                                  color:
                                      _currentEpisodeIndex <
                                              _episodesList.length - 1
                                          ? Colors.white
                                          : Colors.white30,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
