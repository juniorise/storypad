import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:storypad/mixins/snakbar_mixin.dart';

class PaymentService with WSnackBar {
  /// We want singelton object of ``PaymentService`` so create private constructor
  ///
  /// Use PaymentService as ``PaymentService.instance``
  PaymentService._internal();
  static final PaymentService instance = PaymentService._internal();

  /// To listen the status of connection between app and the billing server
  StreamSubscription<ConnectionResult>? _connectionSubscription;

  /// To listen the status of the purchase made inside or outside of the app (App Store / Play Store)
  ///
  /// If status is not error then app will be notied by this stream
  StreamSubscription<PurchasedItem?>? _purchaseUpdatedSubscription;

  /// To listen the errors of the purchase
  StreamSubscription<PurchaseResult?>? _purchaseErrorSubscription;

  /// List of product ids you want to fetch
  final List<String> _productIds = ['monthly_subscription'];

  /// All available products will be store in this list
  List<IAPItem>? _products;

  /// All past purchases will be store in this list
  List<PurchasedItem>? _pastPurchases;

  /// view of the app will subscribe to this to get notified
  /// when premium status of the user changes
  ObserverList<Function> _proStatusChangedListeners = ObserverList<Function>();

  /// view of the app will subscribe to this to get errors of the purchase
  ObserverList<Function(String)> _errorListeners =
      ObserverList<Function(String)>();

  /// logged in user's premium status
  bool _isProUser = false;

  bool get isProUser => _isProUser;

  /// Call this method to notify all the subsctibers of _proStatusChangedListeners
  void _callProStatusChangedListeners() {
    _proStatusChangedListeners.forEach((Function callback) {
      callback();
    });
  }

  /// Call this method to notify all the subsctibers of _errorListeners
  void _callErrorListeners(String? error) {
    _errorListeners.forEach((Function callback) {
      callback(error);
    });
  }

  Future<void> initConnection() async {
    await FlutterInappPurchase.instance.initConnection;
    _connectionSubscription =
        FlutterInappPurchase.connectionUpdated.listen((connected) {});

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen(_handlePurchaseUpdate);

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen(_handlePurchaseError);

    await _getItems();
    await _getPastPurchases();
  }

  Future<List<IAPItem>> get products async {
    if (_products == null) {
      await _getItems();
    }
    return _products as List<IAPItem>;
  }

  Future<void> _getItems() async {
    List<IAPItem> items =
        await FlutterInappPurchase.instance.getSubscriptions(_productIds);
    _products = [];
    for (var item in items) {
      this._products?.add(item);
    }
  }

  Future<void> _getPastPurchases() async {
    // remove this if you want to restore past purchases in iOS
    if (Platform.isIOS) return;

    List<PurchasedItem>? purchasedItems =
        await FlutterInappPurchase.instance.getAvailablePurchases();

    if (purchasedItems == null) return;
    for (var purchasedItem in purchasedItems) {
      bool isValid = false;

      if (Platform.isAndroid) {
        final transactionReceipt = purchasedItem.transactionReceipt;
        if (transactionReceipt == null) return;
        Map map = jsonDecode(transactionReceipt);
        // if your app missed finishTransaction due to network or crash issue
        // finish transactins
        if (!map['acknowledged']) {
          isValid = await _verifyPurchase(purchasedItem);
          if (isValid) {
            FlutterInappPurchase.instance.finishTransaction(purchasedItem);
            _isProUser = true;
            _callProStatusChangedListeners();
          }
        } else {
          _isProUser = true;
          _callProStatusChangedListeners();
        }
      }
    }

    _pastPurchases = [];
    _pastPurchases?.addAll(purchasedItems);
  }

  Future<bool> _verifyPurchase(PurchasedItem purchasedItem) async {
    return true;
  }

  Future<void> buyProduct(String productId, BuildContext context) async {
    try {
      await FlutterInappPurchase.instance.requestSubscription(productId);
    } catch (error) {
      showSnackBar(context: context, title: error.toString());
    }
  }

  void _handlePurchaseError(PurchaseResult? purchaseError) {
    _callErrorListeners(purchaseError?.message);
  }

  /// Called when new updates arrives at ``purchaseUpdated`` stream
  void _handlePurchaseUpdate(PurchasedItem? productItem) async {
    if (Platform.isAndroid) {
      await _handlePurchaseUpdateAndroid(productItem);
    } else {
      await _handlePurchaseUpdateIOS(productItem);
    }
  }

  Future<void> _handlePurchaseUpdateIOS(PurchasedItem? purchasedItem) async {
    if (purchasedItem == null) return;
    switch (purchasedItem.transactionStateIOS) {
      case TransactionState.deferred:
        // Edit: This was a bug that was pointed out here : https://github.com/dooboolab/flutter_inapp_purchase/issues/234
        // FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        break;
      case TransactionState.failed:
        _callErrorListeners("Transaction Failed");
        FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        break;
      case TransactionState.purchased:
        await _verifyAndFinishTransaction(purchasedItem);
        break;
      case TransactionState.purchasing:
        break;
      case TransactionState.restored:
        FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        break;
      default:
    }
  }

  /// three purchase state https://developer.android.com/reference/com/android/billingclient/api/Purchase.PurchaseState
  /// 0 : UNSPECIFIED_STATE
  /// 1 : PURCHASED
  /// 2 : PENDING
  Future<void> _handlePurchaseUpdateAndroid(
    PurchasedItem? purchasedItem,
  ) async {
    if (purchasedItem == null) return;
    switch (purchasedItem.purchaseStateAndroid) {
      case PurchaseState.purchased:
        if (!(purchasedItem.isAcknowledgedAndroid == true)) {
          await _verifyAndFinishTransaction(purchasedItem);
        }
        break;
      default:
        _callErrorListeners("Something went wrong");
    }
  }

  /// Call this method when status of purchase is success
  /// Call API of your back end to verify the reciept
  /// back end has to call billing server's API to verify the purchase token
  _verifyAndFinishTransaction(PurchasedItem purchasedItem) async {
    bool isValid = false;
    try {
      // Call API
      isValid = await _verifyPurchase(purchasedItem);
    } on Exception {
      _callErrorListeners("Something went wrong");
      return;
    }

    if (isValid) {
      FlutterInappPurchase.instance.finishTransaction(purchasedItem);
      _isProUser = true;
      // save in sharedPreference here
      _callProStatusChangedListeners();
    } else {
      _callErrorListeners("Varification failed");
    }
  }

  /// call when user close the app
  void dispose() {
    _connectionSubscription?.cancel();
    _purchaseErrorSubscription?.cancel();
    _purchaseUpdatedSubscription?.cancel();
    FlutterInappPurchase.instance.endConnection;
  }
}
