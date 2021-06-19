import 'package:storypad/notifier/base_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ImageLoadNotifier extends BaseNotifier {
  bool _imageLoading = false;
  bool get imageLoading => this._imageLoading;
  set imageLoading(bool value) {
    if (this._imageLoading == value) return;
    this._imageLoading = value;
    notifyListeners();
  }

  bool _imageRetry = false;
  bool get imageRetry => this._imageRetry;
  set imageRetry(bool value) {
    if (this._imageRetry == value) return;
    this._imageRetry = value;
    notifyListeners();
  }
}

final imageLoadProvider = ChangeNotifierProvider.autoDispose<ImageLoadNotifier>(
  (ref) {
    return ImageLoadNotifier();
  },
);
