import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:photo_view/photo_view.dart';
import 'package:storypad/mixins/w_snakbar_mixin.dart';
import 'package:storypad/widgets/vt_ontap_effect.dart';
import 'package:storypad/widgets/w_icon_button.dart';

class ImageViewer extends HookWidget with WSnackBarMixin {
  const ImageViewer({
    Key? key,
    required this.imageChild,
    required this.screenPadding,
    required this.onShareImage,
  }) : super(key: key);

  final Widget imageChild;
  final EdgeInsets screenPadding;
  final Future<void> Function()? onShareImage;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = screenPadding.top;
    final height = MediaQuery.of(context).size.height;
    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: (height - statusBarHeight) / height,
      maxChildSize: (height - statusBarHeight) / height,
      minChildSize: (height - statusBarHeight) / height - 0.1,
      builder: (context, _) {
        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            leading: WIconButton(
              iconData: Icons.clear,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          floatingActionButton: onShareImage != null
              ? VTOnTapEffect(
                  onTap: () async {
                    await onShareImage!();
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.share),
                  ),
                )
              : null,
          body: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: PhotoView.customChild(
                  backgroundDecoration: BoxDecoration(color: Colors.transparent),
                  minScale: 0.99,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: imageChild,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
