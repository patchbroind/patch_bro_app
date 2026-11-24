
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:material_ui/material_ui.dart';

import 'package:patch_bro/core/theme/worker/worker_colors.dart';
import 'package:patch_bro/features/worker/jobs/presentation/widgets/worker_job_detail_section.dart';

class WorkerJobVoicePlayer extends StatefulWidget {
  const WorkerJobVoicePlayer({
    super.key,
    required this.audioUrl,
  });

  final String audioUrl;

  @override
  State<WorkerJobVoicePlayer> createState() =>
      _WorkerJobVoicePlayerState();
}

class _WorkerJobVoicePlayerState extends State<WorkerJobVoicePlayer> {
  late final AudioPlayer _player;

  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<void>? _completeSubscription;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();

    _durationSubscription = _player.onDurationChanged.listen((value) {
      if (!mounted) return;
      setState(() => _duration = value);
    });

    _positionSubscription = _player.onPositionChanged.listen((value) {
      if (!mounted) return;
      setState(() => _position = value);
    });

    _stateSubscription = _player.onPlayerStateChanged.listen((value) {
      if (!mounted) return;
      setState(() => _isPlaying = value == PlayerState.playing);
    });

    _completeSubscription = _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _position = Duration.zero;
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    _completeSubscription?.cancel();
    _player.dispose();

    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isLoading) return;

    try {
      if (_isPlaying) {
        await _player.pause();
        return;
      }

      setState(() => _isLoading = true);

      if (_position > Duration.zero &&
          _position >= _duration &&
          _duration > Duration.zero) {
        await _player.seek(Duration.zero);
      }

      await _player.play(UrlSource(widget.audioUrl));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to play the voice note.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _seekTo(double value) async {
    if (_duration == Duration.zero) return;

    final position = Duration(
      milliseconds: (value * _duration.inMilliseconds).round(),
    );

    await _player.seek(position);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final maxMilliseconds = _duration.inMilliseconds.toDouble();

    final currentMilliseconds = _position.inMilliseconds
        .clamp(0, _duration.inMilliseconds)
        .toDouble();

    final progress = maxMilliseconds <= 0
        ? 0.0
        : currentMilliseconds / maxMilliseconds;

    return WorkerJobDetailSection(
      title: 'Voice Description',
      icon: Icons.mic_none_rounded,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: WorkerColors.homePrimaryLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Material(
              color: WorkerColors.homePrimary,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _togglePlayback,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employer voice note',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: WorkerColors.textPrimary,
                        ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: WorkerColors.homePrimary,
                      inactiveTrackColor:
                          WorkerColors.homePrimary.withValues(alpha: 0.18),
                      thumbColor: WorkerColors.homePrimary,
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5,
                      ),
                    ),
                    child: Slider(
                      value: progress,
                      min: 0,
                      max: 1,
                      onChanged: maxMilliseconds <= 0 ? null : _seekTo,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: WorkerColors.textSecondary,
                            ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: WorkerColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}