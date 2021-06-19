import 'package:storypad/notifier/base_notifier.dart';
import 'package:flutter_inapp_purchase/modules.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/services/payment_service.dart';

class SponserNotifier extends BaseNotifier {
  PaymentService instance = PaymentService.instance;

  List<IAPItem>? _products;
  List<IAPItem> get products => this._products ?? [];

  bool _isProUser = false;
  bool get isProUser => this._isProUser;
  set isProUser(bool value) {
    if (value == _isProUser) return;
    _isProUser = value;
    notifyListeners();
  }

  String? _error;
  String? get error => this._error;
  set error(String? value) {
    if (value == _error) return;
    _error = value;
    notifyListeners();
  }

  SponserNotifier() {
    instance.addToErrorListeners((String? _error) {
      error = _error;
    });
    instance.addToProStatusChangedListeners(() {
      isProUser = instance.isProUser;
    });
  }

  Future<void> load() async {
    await instance.initConnection();
    _products = await instance.products.then((value) => value);
    notifyListeners();
  }

  Future<void> buyProduct(String productId) async {
    error = null;
    await instance.buyProduct(productId);
  }

  @override
  void dispose() {
    instance.dispose();
    super.dispose();
  }
}

final sponserProvider = ChangeNotifierProvider.autoDispose<SponserNotifier>((ref) {
  return SponserNotifier()..load();
});
