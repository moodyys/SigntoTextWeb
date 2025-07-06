import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'assets/theme.dart';
import 'assets/backbutton.dart';

class LearningVideoScreen extends StatefulWidget {
  final String title;
  final String videoPath;
  final bool isNetwork;
  const LearningVideoScreen({super.key, required this.title, required this.videoPath, this.isNetwork = false});

  @override
  State<LearningVideoScreen> createState() => _LearningVideoScreenState();
}

class _LearningVideoScreenState extends State<LearningVideoScreen> {
  VideoPlayerController? _controller;
  Timer? _positionTimer;
  bool _initialized = false;
  bool _isDragging = false;
  double _currentPosition = 0.0;
  double _totalDuration = 0.0;
  String? _errorMessage;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    try {
      if (widget.isNetwork) {
        _controller = VideoPlayerController.network(widget.videoPath);
      } else {
        _controller = VideoPlayerController.asset(widget.videoPath);
      }

      _controller!.initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
            _totalDuration = _controller!.value.duration.inMilliseconds.toDouble();
          });
          _startPositionListener();
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'خطأ في تحميل الفيديو';
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تهيئة الفيديو';
      });
    }
  }

  void _startPositionListener() {
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_controller != null && mounted && !_isDragging && _initialized) {
        setState(() {
          _currentPosition = _controller!.value.position.inMilliseconds.toDouble();
          _isPlaying = _controller!.value.isPlaying;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_initialized && _controller != null) {
      setState(() {
        if (_isPlaying) {
          _controller!.pause();
        } else {
          _controller!.play();
        }
      });
    }
  }

  String _formatDuration(double milliseconds) {
    final duration = Duration(milliseconds: milliseconds.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _errorMessage != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            color: Colors.red[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _errorMessage = null;
                              _initialized = false;
                            });
                            _initializeVideo();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'إعادة المحاولة',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : _initialized
                      ? AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(_controller!),
                              // Play/Pause overlay
                              GestureDetector(
                                onTap: _togglePlayPause,
                                child: Container(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: AnimatedOpacity(
                                      opacity: _isPlaying ? 0.0 : 1.0,
                                      duration: const Duration(milliseconds: 300),
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _isPlaying ? Icons.pause : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 50.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'جاري تحميل الفيديو...',
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
            ),
          ),
          if (_initialized) _buildVideoControls(),
        ],
      ),
      floatingActionButton: _initialized
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: _togglePlayPause,
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 30,
              ),
            )
          : null,
    );
  }

  Widget _buildVideoControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black87,
      child: Column(
        children: [
          // Progress Bar with Time
          Row(
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: Colors.grey[600],
                    thumbColor: AppColors.primary,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _currentPosition.clamp(0.0, _totalDuration),
                    max: _totalDuration,
                    onChanged: (value) {
                      setState(() {
                        _isDragging = true;
                        _currentPosition = value;
                      });
                    },
                    onChangeEnd: (value) {
                      if (_controller != null) {
                        try {
                          _controller!.seekTo(Duration(milliseconds: value.toInt()));
                        } catch (e) {
                          print('Error seeking in slider: $e');
                        }
                      }
                      setState(() {
                        _isDragging = false;
                      });
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}