import 'package:flutter/material.dart';

class SliverWidgetDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  SliverWidgetDelegate({
    required this.child,
    required this.height,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
