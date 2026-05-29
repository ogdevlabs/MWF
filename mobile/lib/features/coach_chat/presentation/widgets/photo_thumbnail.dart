import 'dart:io';

import 'package:flutter/material.dart';

/// Displays a 160x120 photo thumbnail with tap-to-expand via InteractiveViewer.
///
/// Shows [localPhotoPath] if provided (offline / just-taken photo),
/// otherwise shows [photoUrl] from Supabase Storage.
class PhotoThumbnail extends StatelessWidget {
  const PhotoThumbnail({
    super.key,
    this.photoUrl,
    this.localPhotoPath,
  });

  final String? photoUrl;
  final String? localPhotoPath;

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (localPhotoPath != null) {
      image = Image.file(
        File(localPhotoPath!),
        fit: BoxFit.cover,
        width: 160,
        height: 120,
        errorBuilder: (context, error, stackTrace) =>
            _errorPlaceholder(context),
      );
    } else if (photoUrl != null) {
      image = Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        width: 160,
        height: 120,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _loadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) =>
            _errorPlaceholder(context),
      );
    } else {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: 'Attached photo, tap to view full size',
      child: GestureDetector(
        onTap: () => _showFullSize(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 160,
            height: 120,
            child: image,
          ),
        ),
      ),
    );
  }

  Widget _loadingPlaceholder() {
    return const SizedBox(
      width: 160,
      height: 120,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _errorPlaceholder(BuildContext context) {
    return Container(
      width: 160,
      height: 120,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _showFullSize(BuildContext context) {
    Widget fullImage;
    if (localPhotoPath != null) {
      fullImage = Image.file(File(localPhotoPath!));
    } else if (photoUrl != null) {
      fullImage = Image.network(photoUrl!);
    } else {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Center(child: fullImage),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
