import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../../core/database/app_database.dart';
import '../domain/session_model.dart';

/// Wraps Chewie for exercise video playback.
/// Handles local file fallback vs HLS stream (per RESEARCH.md Pattern 1).
/// Must be used inside a StatefulWidget that manages lifecycle.
class ExerciseVideoPlayer extends StatefulWidget {
  const ExerciseVideoPlayer({
    super.key,
    required this.exercise,
    required this.db,
    this.overlay,
  });

  final ExerciseModel exercise;
  final AppDatabase db;
  final Widget? overlay;

  @override
  State<ExerciseVideoPlayer> createState() => ExerciseVideoPlayerState();
}

class ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  VideoPlayerController? _vpc;
  ChewieController? _chewieController;
  bool _isInitializing = false;
  bool _videoAvailable = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(ExerciseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id) {
      _disposeControllers();
      _initPlayer();
    }
  }

  Future<void> _initPlayer() async {
    if (_isInitializing) return;
    _isInitializing = true;

    final exercise = widget.exercise;

    // Prefer local file if downloaded (Phase 5 populates this)
    final Uri videoUri;
    if (exercise.localVideoPath != null) {
      final dir = await getApplicationDocumentsDirectory();
      videoUri = Uri.file('${dir.path}/${exercise.localVideoPath}');
    } else if (exercise.muxPlaybackId != null) {
      videoUri = Uri.parse(
          'https://stream.mux.com/${exercise.muxPlaybackId}.m3u8');
    } else {
      // Also check download_manifest for video path
      final manifest = await widget.db.downloadManifestDao
          .getByExerciseId(exercise.id);
      if (manifest?.videoLocalPath != null &&
          manifest!.downloadStatus == 'complete') {
        final dir = await getApplicationDocumentsDirectory();
        videoUri = Uri.file('${dir.path}/${manifest.videoLocalPath}');
      } else {
        if (mounted) setState(() => _videoAvailable = false);
        _isInitializing = false;
        return;
      }
    }

    _vpc = VideoPlayerController.networkUrl(videoUri);
    await _vpc!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _vpc!,
      autoPlay: true,
      looping: true,
      allowFullScreen: false,
      showControls: true,
    );
    _isInitializing = false;
    if (mounted) setState(() {});
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _chewieController = null;
    _vpc?.dispose();
    _vpc = null;
    _videoAvailable = true;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_videoAvailable) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off, color: Colors.white54, size: 48),
              SizedBox(height: 8),
              Text('Video not available',
                  style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      );
    }

    if (_chewieController == null) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        Chewie(controller: _chewieController!),
        if (widget.overlay != null)
          Positioned.fill(child: widget.overlay!),
      ],
    );
  }
}
