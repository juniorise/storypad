import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';

mixin HookController {
  PageController usePageController({
    int initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
  }) {
    var pageController = PageController(
      initialPage: initialPage,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
    );
    final controller = useMemoized(() => pageController);
    useEffect(() {
      return controller.dispose;
    }, [controller]);
    return controller;
  }

  TransformationController useTransformationController([Matrix4 value]) {
    var transformationController = TransformationController(value);
    final controller = useMemoized(() => transformationController);
    useEffect(() {
      return controller.dispose;
    }, [controller]);
    return controller;
  }

  QuillController useQuillController({
    Document document,
    TextSelection selection,
    bool isBasic = false,
  }) {
    QuillController quillController;
    if (!isBasic) {
      quillController = QuillController(
        document: document,
        selection: selection,
      );
    } else {
      quillController = QuillController.basic();
    }

    final controller = useMemoized(() => quillController);
    useEffect(() {
      return controller.dispose;
    }, [controller]);
    return controller;
  }
}
