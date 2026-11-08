import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

class InvitationVoiceNote extends StatefulWidget {
  const InvitationVoiceNote({
    super.key,
    required this.audioUrl,
  });

  final String audioUrl;

  @override
  State<InvitationVoiceNote> createState() => _InvitationVoiceNoteState();
}

class _InvitationVoiceNoteState extends State<InvitationVoiceNote> {
  late final AudioPlayer _player;
  PlayerState _playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    try {
      if (_playerState == PlayerState.playing) {
        await _player.pause();
      } else {
        await _player.play(UrlSource(widget.audioUrl));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to play this voice note.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _playerState == PlayerState.playing;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: WorkerColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton.filled(
            onPressed: _togglePlayback,
            style: IconButton.styleFrom(
              backgroundColor: WorkerColors.homePrimary,
              foregroundColor: WorkerColors.white,
            ),
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Voice note',
              style: TextStyle(
                color: WorkerColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(
            isPlaying ? Icons.volume_up_rounded : Icons.graphic_eq_rounded,
            color: WorkerColors.homePrimary,
          ),
        ],
      ),
    );
  }
}