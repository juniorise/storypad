import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

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

  AutoScrollController useAutoScrollController({
    double initialScrollOffset: 0.0,
    bool keepScrollOffset: true,
    double suggestedRowHeight,
    ViewportBoundaryGetter viewportBoundaryGetter:
        defaultViewportBoundaryGetter,
    Axis axis,
    String debugLabel,
    AutoScrollController copyTagsFrom,
  }) {
    var autoScrollController = AutoScrollController(
      initialScrollOffset: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      suggestedRowHeight: suggestedRowHeight,
      viewportBoundaryGetter: viewportBoundaryGetter,
      axis: axis,
      debugLabel: debugLabel,
      copyTagsFrom: copyTagsFrom,
    );

    final controller = useMemoized(() => autoScrollController);
    useEffect(() {
      return controller.dispose;
    }, [controller]);
    return controller;
  }
}
