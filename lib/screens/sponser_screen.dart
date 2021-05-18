import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inapp_purchase/modules.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/mixins/change_notifier_mixin.dart';
import 'package:storypad/services/payment_service.dart';
import 'package:storypad/widgets/vt_ontap_effect.dart';
import 'package:storypad/widgets/w_icon_button.dart';

class SponserNotifier extends ChangeNotifier with ChangeNotifierMixin {
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

  Future<void> load() async {
    await instance.initConnection();
    _products = await instance.products.then((value) => value);
    _isProUser = instance.isProUser;
  }

  Future<void> buyProduct(IAPItem item) async {
    await instance.buyProduct(item);
    _isProUser = instance.isProUser;
    notifyListeners();
  }

  @override
  void dispose() {
    instance.dispose();
    super.dispose();
  }
}

final sponserProvider = ChangeNotifierProvider<SponserNotifier>((ref) {
  return SponserNotifier();
});

class SponserScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = useProvider(sponserProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.surface,
        textTheme: Theme.of(context).textTheme,
        leading: WIconButton(
          iconData: Icons.clear,
          onPressed: () {
            ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          // if (notifier.isProUser)
          Column(
            children: [
              Center(
                child: Padding(
                  padding: ConfigConstant.layoutPadding,
                  child: Material(
                    elevation: 1.0,
                    borderRadius: ConfigConstant.circlarRadius1,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: ConfigConstant.circlarRadius1,
                      ),
                      child: Column(
                        children: [
                          ImageIcon(
                            AssetImage("assets/icons/sponsor.png"),
                            size: ConfigConstant.iconSize4,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          Text("Thank for your help"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!notifier.isProUser)
            ListView(
              padding: ConfigConstant.layoutPadding,
              children: List.generate(
                notifier.products.length,
                (index) {
                  final product = notifier.products[index];
                  return VTOnTapEffect(
                    onTap: () async {
                      await notifier.buyProduct(product);
                    },
                    child: buildProductItem(context, product),
                  );
                },
              ),
            ),
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Padding(
          //     padding: EdgeInsets.only(
          //       bottom: MediaQuery.of(context).padding.bottom,
          //     ),
          //     child: TextButton(
          //       child: Text("Restore Purchases"),
          //       onPressed: () {},
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Material buildProductItem(BuildContext context, IAPItem product) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 4.0,
      borderRadius: ConfigConstant.circlarRadius2,
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title ?? "",
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Text(
                  product.description ?? "",
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
            Text(
              product.price ?? "",
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  ?.copyWith(fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }
}
