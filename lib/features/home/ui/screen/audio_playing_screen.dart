import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:flutter_application_3/navigation_bar.dart';
import 'package:just_audio/just_audio.dart';

class PodcastPlayerScreen extends StatefulWidget {
  final Podcast podcast;

  const PodcastPlayerScreen({
    super.key,
    required this.podcast,
  });

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } catch (e) {
      _handleError('Failed to initialize audio session: $e');
      return;
    }

    _audioPlayer.playbackEventStream.listen(
      (event) {
        if (mounted) {
          setState(() {
            _position = event.bufferedPosition;
            _duration = event.duration ?? Duration.zero;
            _isPlaying = event.processingState == ProcessingState.ready &&
                _audioPlayer.playing;
          });
        }
      },
      onError: (Object e, StackTrace st) {
        _handleError('Playback error: $e');
      },
    );

    _audioPlayer.processingStateStream.listen((state) {
      if (mounted) {
        setState(() {
          if (state == ProcessingState.completed) {
            _isPlaying = false;
            _position = _duration;
          }
        });
      }
    });

    await _loadAudioSource();
  }

  Future<void> _loadAudioSource() async {
    try {
      final audioSource = AudioSource.uri(
        Uri.parse(widget.podcast.audioUrl),
        headers: {'User-Agent': 'YourApp/1.0'},
      );

      await _audioPlayer.setAudioSource(
        audioSource,
        initialPosition: Duration.zero,
        preload: true,
      );

      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (e) {
      _handleError('Failed to load audio: $e');
    }
  }

  void _handleError(String message) {
    debugPrint(message);
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _isLoading = false;
        _isInitialized = false;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    if (!_isInitialized) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      _handleError('Playback control error: $e');
    }
  }

  Future<void> _seekTo(Duration position) async {
    if (!_isInitialized) return;

    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      _handleError('Seek error: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  void _navigateToNavigationBar() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyNavigationBar(
          audioPlayer: _audioPlayer,
          podcast: widget.podcast,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color podcastColor =
        Color(int.parse(widget.podcast.color.replaceAll('#', '0xff')));

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _navigateToNavigationBar();
        }
      },
      child: Scaffold(
        backgroundColor: podcastColor.withOpacity(0.15),
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyNavigationBar(
                    audioPlayer: _audioPlayer,
                    podcast: widget.podcast,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            'Now Playing',
            style: AppTextStyles.darkBodyText1,
          ),
          centerTitle: true,
          backgroundColor: podcastColor.withOpacity(0.8),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: podcastColor,
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildPlayerWidget(podcastColor),
      ),
    );
  }

  Widget _buildPlayerWidget(Color podcastColor) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Podcast Cover Art
                Container(
                  width: 280,
                  height: 280,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: podcastColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(widget.podcast.thumbnailUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Podcast Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    widget.podcast.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),

                // Author
                Text(
                  widget.podcast.author,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Player Controls
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: podcastColor.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress Bar
                Slider(
                  value: _position.inSeconds.toDouble(),
                  min: 0,
                  max: _duration.inSeconds.toDouble(),
                  activeColor: podcastColor,
                  inactiveColor: podcastColor.withOpacity(0.3),
                  onChanged: (value) =>
                      _seekTo(Duration(seconds: value.toInt())),
                ),

                // Duration Labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position)),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      iconSize: 32,
                      onPressed: () =>
                          _seekTo(_position - const Duration(seconds: 10)),
                    ),
                    const SizedBox(width: 32),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: podcastColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: podcastColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 42,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      icon: const Icon(Icons.forward_30),
                      iconSize: 32,
                      onPressed: () =>
                          _seekTo(_position + const Duration(seconds: 30)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
