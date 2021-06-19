import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/notifier/base_notifier.dart';

class AppBarNotifier extends BaseNotifier {
  double headlineWidth = 0;
  double headerHeight = 0;

  setHeadlineWidth(double width) {
    this.headlineWidth = width;
    notifyListeners();
  }

  void setHeaderHeight(double height) {
    this.headerHeight = height;
    notifyListeners();
  }
}

final appBarProvider = ChangeNotifierProvider<AppBarNotifier>((ref) {
  return AppBarNotifier();
});
