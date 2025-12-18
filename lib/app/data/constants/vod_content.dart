import '../helper_widgets/content_card.dart';
import 'app_images.dart';

class VodContent {
  final String title;
  final String description;
  final bool showVideoPlayer;
  final String? imagePath;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? thumbnailImage;

  const VodContent({
    required this.title,
    required this.description,
    this.showVideoPlayer = false,
    this.imagePath,
    this.videoUrl,
    this.thumbnailUrl,
    this.thumbnailImage,
  });

  ContentCard toContentCard() {
    return ContentCard(
      title: title,
      description: description,
      showVideoPlayer: showVideoPlayer,
      imagePath: imagePath,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      thumbnailImage: thumbnailImage,
    );
  }
}

class VodContentConstants {
  static const List<VodContent> contentList = [
    VodContent(
      title: 'vodLuxuryStores',
      description: 'vodLoramDescription',
      showVideoPlayer: true,
      thumbnailImage: AppImages.eventRegisteration,
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    ),
    VodContent(
      title: 'vodLuxuryStores',
      description: 'vodLoramDescription',
      showVideoPlayer: true,
      thumbnailImage: AppImages.eventRegisteration,
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    ),
    VodContent(
      title: 'vodLuxuryStores',
      description: 'vodLoramDescription',
      showVideoPlayer: false,
      imagePath: AppImages.eventRegisteration,
    ),
  ];
}
