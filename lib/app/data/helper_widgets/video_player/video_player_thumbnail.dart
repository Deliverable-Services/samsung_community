import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../common/services/video_thumbnail_service.dart';

class VideoPlayerThumbnail extends StatefulWidget {
  final String? thumbnailUrl;
  final String? thumbnailImage;
  final String? videoUrl;

  const VideoPlayerThumbnail({
    super.key,
    this.thumbnailUrl,
    this.thumbnailImage,
    this.videoUrl,
  });

  @override
  State<VideoPlayerThumbnail> createState() => _VideoPlayerThumbnailState();
}

class _VideoPlayerThumbnailState extends State<VideoPlayerThumbnail> {
  String? _generatedThumbnailPath;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    if (_shouldGenerateThumbnail()) {
      _generateThumbnail();
    }
  }

  bool _shouldGenerateThumbnail() {
    return (widget.thumbnailUrl == null && widget.thumbnailImage == null) &&
        widget.videoUrl != null &&
        widget.videoUrl!.isNotEmpty;
  }

  Future<void> _generateThumbnail() async {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final thumbnailPath = await VideoThumbnailService.generateThumbnail(
        videoUrl: widget.videoUrl!,
        timeMs: 1000,
        quality: 75,
      );

      if (mounted && thumbnailPath != null) {
        setState(() {
          _generatedThumbnailPath = thumbnailPath;
          _isGenerating = false;
        });
      } else if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    } catch (e) {
      print('Error generating thumbnail: $e');
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Widget _buildThumbnailImage(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: const Color(0xFF2A2A2A),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) {
          return Container(color: const Color(0xFF2A2A2A));
        },
      );
    } else if (url.startsWith('/') || url.contains('\\')) {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: const Color(0xFF2A2A2A));
        },
      );
    } else {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: const Color(0xFF2A2A2A));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.thumbnailUrl != null) {
      return _buildThumbnailImage(widget.thumbnailUrl!);
    }

    if (widget.thumbnailImage != null) {
      return _buildThumbnailImage(widget.thumbnailImage!);
    }

    if (_generatedThumbnailPath != null) {
      return _buildThumbnailImage(_generatedThumbnailPath!);
    }

    if (_isGenerating) {
      return Container(
        color: const Color(0xFF2A2A2A),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(color: const Color(0xFF2A2A2A));
  }
}

