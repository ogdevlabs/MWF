import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Shows the 3D model in a DraggableScrollableSheet (D-02, D-03).
/// Opens as a modal bottom sheet — auto-disposes ModelViewer WebView on close.
/// initialChildSize: 0.55, minChildSize: 0.3, maxChildSize: 0.9.
///
/// Anti-pattern avoidance: ModelViewer is ONLY alive while sheet is open.
/// Do NOT keep it in the widget tree when hidden.
Future<void> showModelViewerSheet(
  BuildContext context, {
  required String? modelAssetUrl,
  String? localModelPath,
}) async {
  if (modelAssetUrl == null && localModelPath == null) return;

  String modelSrc;
  if (localModelPath != null) {
    final dir = await getApplicationDocumentsDirectory();
    modelSrc = 'file://${dir.path}/$localModelPath';
  } else {
    modelSrc = modelAssetUrl!;
  }

  if (!context.mounted) return;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Form Reference',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ModelViewer(
                  src: modelSrc,
                  cameraControls: true,
                  autoRotate: true,
                  autoRotateDelay: 1000,
                  ar: false,
                  loading: Loading.eager,
                  backgroundColor: theme.colorScheme.surface,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
