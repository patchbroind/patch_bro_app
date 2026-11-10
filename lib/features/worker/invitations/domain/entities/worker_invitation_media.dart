class WorkerInvitationMedia {
  const WorkerInvitationMedia({
    this.imageUrls = const [],
    this.audioUrl,
  });

  final List<String> imageUrls;
  final String? audioUrl;

  bool get hasImages => imageUrls.isNotEmpty;

  bool get hasVoiceNote => audioUrl?.trim().isNotEmpty == true;

  factory WorkerInvitationMedia.fromMap(Map<String, dynamic> map) {
    final rawImages = map['image_urls'];

    final images = rawImages is List
        ? rawImages
            .map((item) => item?.toString().trim() ?? '')
            .where((url) => url.isNotEmpty)
            .toList(growable: false)
        : <String>[];

    final rawAudioUrl = map['audio_url']?.toString().trim();

    return WorkerInvitationMedia(
      imageUrls: images,
      audioUrl: rawAudioUrl == null || rawAudioUrl.isEmpty
          ? null
          : rawAudioUrl,
    );
  }
}