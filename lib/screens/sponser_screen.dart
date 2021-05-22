import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inapp_purchase/modules.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:storypad/constants/config_constant.dart';
import 'package:storypad/notifier/sponser_notifier.dart';
import 'package:storypad/widgets/vt_ontap_effect.dart';
import 'package:storypad/widgets/w_icon_button.dart';
import 'package:url_launcher/url_launcher.dart';

class SponserScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = useProvider(sponserProvider);
    final products = notifier.products;
    final product = products.isNotEmpty ? products.first : null;
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
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
            if (notifier.isProUser)
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
                              const SizedBox(height: 4.0),
                              Text("Thank for your help 🙏📝"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (!notifier.isProUser)
              Column(
                children: [
                  Center(
                    child: Padding(
                      padding: ConfigConstant.layoutPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product != null)
                            VTOnTapEffect(
                              onTap: () async {
                                final productId = product.productId;
                                await notifier
                                    .buyProduct(productId ?? "monthly_sponsor");
                              },
                              child: buildProductItem(context, product),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 18,
                  left: 48,
                  right: 48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedCrossFade(
                      crossFadeState: notifier.error != null
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: ConfigConstant.fadeDuration,
                      firstChild: Text(
                        notifier.error ?? "",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption?.copyWith(
                            color: Theme.of(context).colorScheme.error),
                      ),
                      secondChild: const SizedBox(),
                    ),
                    if (notifier.isProUser)
                      TextButton(
                        child: Text("Manage subscriptions"),
                        onPressed: () {
                          launch(
                            "https://play.google.com/store/apps/details?id=com.tc.writestory",
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Material buildProductItem(BuildContext context, IAPItem? product) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 4.0,
      borderRadius: ConfigConstant.circlarRadius2,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Monthly",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Text(
                  product?.description ?? "",
                  style: Theme.of(context).textTheme.subtitle2,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
            Expanded(
              child: Text(
                (product?.price ?? "") + " " + (product?.currency ?? ""),
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ),
    );
  }
}
