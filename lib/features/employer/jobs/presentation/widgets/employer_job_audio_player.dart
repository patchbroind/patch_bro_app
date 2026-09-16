import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class EmployerJobAudioPlayer extends StatefulWidget {
  const EmployerJobAudioPlayer({
    super.key,
    required this.audioUrl,
  });

  final String audioUrl;

  @override
  State<EmployerJobAudioPlayer> createState() =>
      _EmployerJobAudioPlayerState();
}

class _EmployerJobAudioPlayerState
    extends State<EmployerJobAudioPlayer> {
  late final AudioPlayer _player;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();

    _player.onDurationChanged.listen(
      (duration) {
        if (!mounted) {
          return;
        }

        setState(() {
          _duration = duration;
        });
      },
    );

    _player.onPositionChanged.listen(
      (position) {
        if (!mounted) {
          return;
        }

        setState(() {
          _position = position;
        });
      },
    );

    _player.onPlayerStateChanged.listen(
      (state) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isPlaying =
              state == PlayerState.playing;
        });
      },
    );

    _player.onPlayerComplete.listen(
      (_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _position = Duration.zero;
          _isPlaying = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isLoading) {
      return;
    }

    try {
      if (_isPlaying) {
        await _player.pause();
        return;
      }

      setState(() {
        _isLoading = true;
      });

      await _player.play(
        UrlSource(widget.audioUrl),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to play the voice description.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _seekTo(
    double value,
  ) async {
    if (_duration == Duration.zero) {
      return;
    }

    final position =
        Duration(
      milliseconds:
          (value * _duration.inMilliseconds)
              .round(),
    );

    await _player.seek(position);
  }

  String _formatDuration(
    Duration duration,
  ) {
    final minutes =
        duration.inMinutes
            .remainder(60)
            .toString()
            .padLeft(2, '0');

    final seconds =
        duration.inSeconds
            .remainder(60)
            .toString()
            .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final maxMilliseconds =
        _duration.inMilliseconds
            .toDouble();

    final currentMilliseconds =
        _position.inMilliseconds
            .clamp(
              0,
              _duration.inMilliseconds,
            )
            .toDouble();

    final progress =
        maxMilliseconds <= 0
            ? 0.0
            : currentMilliseconds /
                maxMilliseconds;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.employerLight,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.employerPrimary
              .withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          _PlayButton(
            isPlaying: _isPlaying,
            isLoading: _isLoading,
            onPressed: _togglePlayback,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice description',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color:
                            AppColors.textPrimary,
                        fontWeight:
                            FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 5),
                SliderTheme(
                  data: SliderTheme.of(context)
                      .copyWith(
                    activeTrackColor:
                        AppColors.employerPrimary,
                    inactiveTrackColor:
                        AppColors.employerPrimary
                            .withValues(
                              alpha: 0.18,
                            ),
                    thumbColor:
                        AppColors.employerPrimary,
                    overlayColor:
                        AppColors.employerPrimary
                            .withValues(
                              alpha: 0.08,
                            ),
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
                    ),
                  ),
                  child: Slider(
                    value: progress,
                    min: 0,
                    max: 1,
                    onChanged:
                        maxMilliseconds <= 0
                            ? null
                            : _seekTo,
                  ),
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(
                        _position,
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color:
                                AppColors.textSecondary,
                          ),
                    ),
                    Text(
                      _formatDuration(
                        _duration,
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color:
                                AppColors.textSecondary,
                          ),
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

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.employerPrimary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap:
            isLoading ? null : onPressed,
        customBorder:
            const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.white,
                    size: 25,
                  ),
          ),
        ),
      ),
    );
  }
}