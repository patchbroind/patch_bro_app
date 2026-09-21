import 'package:flutter/material.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/employer_job_audio_player.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_section_card.dart';

class JobDetailVoiceDescriptionCard
    extends StatelessWidget {
  const JobDetailVoiceDescriptionCard({super.key,
    required this.audioUrl,
  });

  final String audioUrl;

  @override
  Widget build(BuildContext context) {
    return JobDetailSectionCard(
      title: 'Voice Description',
      icon: Icons.mic_none_rounded,
      child: EmployerJobAudioPlayer(
        audioUrl: audioUrl,
      ),
    );
  }
}