class FeedContent {
  final String authorName;
  final String? authorAvatar;
  final bool isVerified;
  final String publishedDate;
  final String title;
  final String description;
  final bool isLiked;
  final int likesCount;
  final String? likedByUsername;
  final int commentsCount;

  const FeedContent({
    required this.authorName,
    this.authorAvatar,
    this.isVerified = false,
    required this.publishedDate,
    required this.title,
    required this.description,
    this.isLiked = false,
    this.likesCount = 0,
    this.likedByUsername,
    this.commentsCount = 0,
  });
}

class FeedContentConstants {
  static const List<FeedContent> contentList = [
    FeedContent(
      authorName: 'May bouzo',
      isVerified: true,
      publishedDate: '09/10/25',
      title: 'Lorem ipsum dolor sit',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris...',
      isLiked: true,
      likesCount: 123,
      likedByUsername: 'username',
      commentsCount: 123,
    ),
    FeedContent(
      authorName: 'John Doe',
      isVerified: false,
      publishedDate: '08/10/25',
      title: 'Another post title',
      description:
          'This is another example post description with some content that will be displayed in the feed card. Yet another example of a feed post with different content and styling...',
      isLiked: false,
      likesCount: 456,
      likedByUsername: 'anotheruser',
      commentsCount: 89,
    ),
    FeedContent(
      authorName: 'Jane Smith',
      isVerified: true,
      publishedDate: '07/10/25',
      title: 'Third post example',
      description:
          'Yet another example of a feed post with different content and styling...',
      isLiked: false,
      likesCount: 789,
      commentsCount: 234,
    ),
  ];
}
