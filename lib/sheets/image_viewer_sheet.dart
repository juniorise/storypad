import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:photo_view/photo_view.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/mixins/snakbar_mixin.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/w_icon_button.dart';

class ImageViewer extends HookWidget with WSnackBar {
  const ImageViewer({
    Key? key,
    required this.imageChild,
    required this.onSaveImage,
    required this.screenPadding,
    required this.onShareImage,
  }) : super(key: key);

  final Widget imageChild;
  final EdgeInsets screenPadding;
  final Future<void> Function() onSaveImage;
  final Future<void> Function() onShareImage;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = screenPadding.top;
    final animationController = useAnimationController(
      duration: ConfigConstant.duration * 3,
    )..drive(CurveTween(curve: Curves.bounceIn));
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
          floatingActionButton: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              VTOnTapEffect(
                onTap: () async {
                  await onShareImage();
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
              ),
              const SizedBox(height: ConfigConstant.margin2),
              GestureDetector(
                onTapDown: (_) async {
                  animationController.forward().then((value) async {
                    onTapVibrate();
                    animationController.reset();
                    await onSaveImage();
                  });
                },
                onTapUp: (_) {
                  animationController.reset();
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedBuilder(
                      animation: animationController,
                      builder: (context, child) {
                        return AnimatedOpacity(
                          opacity: animationController.isAnimating ? 1 : 0,
                          duration: ConfigConstant.fadeDuration,
                          child: Material(
                            elevation: 0.5,
                            borderRadius: BorderRadius.circular(2.0),
                            child: Text(" Saving image... "),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: ConfigConstant.margin2),
                    Material(
                      borderRadius: BorderRadius.circular(kToolbarHeight),
                      elevation: 6.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: animationController,
                            builder: (context, child) {
                              return AnimatedOpacity(
                                opacity:
                                    animationController.isAnimating ? 1 : 0,
                                duration: ConfigConstant.fadeDuration,
                                child: Container(
                                  height: 48,
                                  width: 48,
                                  child: CircularProgressIndicator(
                                    value: animationController.value,
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.get_app,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: PhotoView.customChild(
                  backgroundDecoration:
                      BoxDecoration(color: Colors.transparent),
                  minScale: 0.99,
                  maxScale: 1.99,
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
