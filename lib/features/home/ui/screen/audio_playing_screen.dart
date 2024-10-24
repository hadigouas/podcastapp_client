import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
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
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initAudioPlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _audioPlayer = AudioPlayer();

    // Configure audio session with error handling
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } catch (e) {
      _handleError('Failed to initialize audio session: $e');
      return;
    }

    // Set up error handling
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

    // Handle player state changes
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

    // Set up the audio source with retry mechanism
    await _loadAudioSource();
  }

  Future<void> _loadAudioSource() async {
    try {
      // Add custom headers if needed
      final audioSource = AudioSource.uri(
        Uri.parse(widget.podcast.audioUrl),
        headers: {
          'User-Agent': 'YourApp/1.0',
        },
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

  @override
  Widget build(BuildContext context) {
    Color podcastColor =
        Color(int.parse(widget.podcast.color.replaceAll('#', '0xff')));

    return Scaffold(
      backgroundColor: podcastColor
          .withOpacity(0.15), // Using a light opacity for better readability
      appBar: AppBar(
        title: Text(
          'Now Playing',
          style: AppTextStyles.darkBodyText1,
        ),
        centerTitle: true,
        backgroundColor: podcastColor.withOpacity(0.8),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(podcastColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading audio...',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? _buildErrorWidget(podcastColor)
              : _buildPlayerWidget(podcastColor),
    );
  }

  Widget _buildErrorWidget(Color podcastColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAudioSource,
              style: ElevatedButton.styleFrom(
                backgroundColor: podcastColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerWidget(Color podcastColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Podcast Image
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              widget.podcast.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: podcastColor.withOpacity(0.3),
                  child: const Icon(
                    Icons.audio_file,
                    size: 64,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            widget.podcast.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Progress Slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: podcastColor,
              inactiveTrackColor: podcastColor.withOpacity(0.3),
              thumbColor: podcastColor,
            ),
            child: Slider(
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) {
                _seekTo(Duration(seconds: value.toInt()));
              },
            ),
          ),
        ),

        // Time indicators
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                _formatDuration(_duration),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Playback Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.replay_10,
                color: podcastColor,
                size: 32,
              ),
              onPressed: () => _seekTo(_position - const Duration(seconds: 10)),
            ),
            const SizedBox(width: 20),
            Container(
              decoration: BoxDecoration(
                color: podcastColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: _togglePlayPause,
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: Icon(
                Icons.forward_10,
                color: podcastColor,
                size: 32,
              ),
              onPressed: () => _seekTo(_position + const Duration(seconds: 10)),
            ),
          ],
        ),
      ],
    );
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
}
