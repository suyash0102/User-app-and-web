import 'dart:async';

import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/api/api_checker.dart';
import 'package:efood_multivendor/data/model/body/place_order_body.dart';
import 'package:efood_multivendor/data/model/response/cart_model.dart' as cartModel;
import 'package:efood_multivendor/data/model/response/cart_model.dart';
import 'package:efood_multivendor/data/model/response/delivery_log_model.dart';
import 'package:efood_multivendor/data/model/response/distance_model.dart';
import 'package:efood_multivendor/data/model/response/order_cancellation_body.dart';
import 'package:efood_multivendor/data/model/response/order_details_model.dart';
import 'package:efood_multivendor/data/model/response/order_model.dart';
import 'package:efood_multivendor/data/model/response/pause_log_model.dart';
import 'package:efood_multivendor/data/model/response/product_model.dart';
import 'package:efood_multivendor/data/model/response/refund_model.dart';
import 'package:efood_multivendor/data/model/response/response_model.dart';
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';
import 'package:efood_multivendor/data/model/response/subscription_schedule_model.dart';
import 'package:efood_multivendor/data/model/response/timeslote_model.dart';
import 'package:efood_multivendor/data/repository/order_repo.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class OrderController extends GetxController implements GetxService {
  final OrderRepo orderRepo;
  OrderController({@required this.orderRepo});

  List<OrderModel> _runningOrderList;
  List<OrderModel> _runningSubscriptionOrderList;
  List<OrderModel> _historyOrderList;
  List<OrderDetailsModel> _orderDetails;
  int _paymentMethodIndex = 0;
  OrderModel _trackModel;
  ResponseModel _responseModel;
  bool _isLoading = false;
  bool _subscriveLoading = false;
  bool _showCancelled = false;
  String _orderType = 'delivery';
  List<TimeSlotModel> _timeSlots;
  List<TimeSlotModel> _allTimeSlots;
  List<int> _slotIndexList;
  int _selectedDateSlot = 0;
  int _selectedTimeSlot = 0;
  int _selectedTips = -1;
  double _distance;
  bool _runningPaginate = false;
  int _runningPageSize;
  List<int> _runningOffsetList = [];
  int _runningOffset = 1;
  bool _runningSubscriptionPaginate = false;
  int _runningSubscriptionPageSize;
  List<int> _runningSubscriptionOffsetList = [];
  int _runningSubscriptionOffset = 1;
  bool _historyPaginate = false;
  int _historyPageSize;
  List<int> _historyOffsetList = [];
  int _historyOffset = 1;
  int _addressIndex = 0;
  double _tips = 0.0;
  int _deliverySelectIndex = 0;
  Timer _timer;
  List<String> _refundReasons;
  int _selectedReasonIndex = 0;
  XFile _refundImage;
  bool _showBottomSheet = true;
  bool _showOneOrder = true;
  List<CancellationData> _orderCancelReasons;
  String _cancelReason;
  double _extraCharge;
  PaginatedOrderModel _subscriptionOrderModel;
  bool _subscriptionOrder = false;
  DateTimeRange _subscriptionRange;
  String _subscriptionType = 'daily';
  List<DateTime> _selectedDays = [null];
  List<SubscriptionScheduleModel> _schedules;
  PaginatedDeliveryLogModel _deliverLogs;
  PaginatedPauseLogModel _pauseLogs;
  int _cancellationIndex = 0;

  bool _canReorder = true;
  String _reorderMessage = '';

  List<OrderModel> get runningOrderList => _runningOrderList;
  List<OrderModel> get runningSubscriptionOrderList => _runningSubscriptionOrderList;
  List<OrderModel> get historyOrderList => _historyOrderList;
  List<OrderDetailsModel> get orderDetails => _orderDetails;
  int get paymentMethodIndex => _paymentMethodIndex;
  OrderModel get trackModel => _trackModel;
  ResponseModel get responseModel => _responseModel;
  bool get isLoading => _isLoading;
  bool get subscriveLoading => _subscriveLoading;
  bool get showCancelled => _showCancelled;
  String get orderType => _orderType;
  List<TimeSlotModel> get timeSlots => _timeSlots;
  List<TimeSlotModel> get allTimeSlots => _allTimeSlots;
  List<int> get slotIndexList => _slotIndexList;
  int get selectedDateSlot => _selectedDateSlot;
  int get selectedTimeSlot => _selectedTimeSlot;
  int get selectedTips => _selectedTips;
  double get distance => _distance;
  bool get runningPaginate => _runningPaginate;
  int get runningPageSize => _runningPageSize;
  int get runningOffset => _runningOffset;
  bool get runningSubscriptionPaginate => _runningSubscriptionPaginate;
  int get runningSubscriptionPageSize => _runningSubscriptionPageSize;
  int get runningSubscriptionOffset => _runningSubscriptionOffset;
  bool get historyPaginate => _historyPaginate;
  int get historyPageSize => _historyPageSize;
  int get historyOffset => _historyOffset;
  int get addressIndex => _addressIndex;
  double get tips => _tips;
  int get deliverySelectIndex => _deliverySelectIndex;
  int get selectedReasonIndex => _selectedReasonIndex;
  XFile get refundImage => _refundImage;
  List<String> get refundReasons => _refundReasons;
  bool get showBottomSheet => _showBottomSheet;
  bool get showOneOrder => _showOneOrder;
  List<CancellationData> get orderCancelReasons => _orderCancelReasons;
  String get cancelReason => _cancelReason;
  double get extraCharge => _extraCharge;
  bool get subscriptionOrder => _subscriptionOrder;
  DateTimeRange get subscriptionRange => _subscriptionRange;
  String get subscriptionType => _subscriptionType;
  List<DateTime> get selectedDays => _selectedDays;
  PaginatedOrderModel get subscriptionOrderModel => _subscriptionOrderModel;
  List<SubscriptionScheduleModel> get schedules => _schedules;
  PaginatedDeliveryLogModel get deliveryLogs => _deliverLogs;
  PaginatedPauseLogModel get pauseLogs => _pauseLogs;
  int get cancellationIndex => _cancellationIndex;

  void setCancelIndex(int index) {
    _cancellationIndex = index;
    update();
  }

  Future<void> reOrder(List<OrderDetailsModel> orderedFoods, int restaurantZoneId) async {
    _isLoading = true;
    update();

    List<int> _foodIds = [];
    for(int i=0; i<orderedFoods.length; i++){
      _foodIds.add(orderedFoods[i].foodDetails.id);
    }
    Response response = await orderRepo.getFoodsWithFoodIds(_foodIds);
    if (response.statusCode == 200) {
      _canReorder = true;
      List<Product> _foods = [];
      response.body.forEach((food) => _foods.add(Product.fromJson(food)));

      List<CartModel> _cartList = [];

      if(Get.find<LocationController>().getUserAddress().zoneIds.contains(restaurantZoneId)){

        for(int i=0; i < orderedFoods.length; i++){
          for(int j=0; j<_foods.length; j++){
            if(orderedFoods[i].foodDetails.id == _foods[j].id){
              _cartList.add(_sortOutProductAddToCard(orderedFoods[i].variation, _foods[j], orderedFoods[i]));
            }
          }
        }

      } else{
        _canReorder = false;
        _reorderMessage = 'you_are_not_in_the_order_zone';
      }

      if(_canReorder) {
        _checkProductVariationHasChanged(_cartList);
      }

      _isLoading = false;
      update();

      if(_canReorder) {
        Get.find<CartController>().reorderAddToCart(_cartList);
        Get.toNamed(RouteHelper.getCartRoute());
      }else{
        showCustomSnackBar(_reorderMessage.tr);
      }

    }else{
      ApiChecker.checkApi(response);
    }

  }


  CartModel _sortOutProductAddToCard(List<Variation> orderedVariation, Product currentFood, OrderDetailsModel orderDetailsModel){
    List<List<bool>> _selectedVariations = [];

    double _price = currentFood.price;
    double _variationPrice = 0;
    int quantity = orderDetailsModel.quantity;
    List<int> _addOnIdList = [];
    List<cartModel.AddOn> _addOnIdWithQtnList = [];
    List<bool> _addOnActiveList = [];
    List<int> _addOnQtyList = [];
    List<AddOns> _addOnsList = [];

    if(currentFood.variations != null && currentFood.variations.isNotEmpty){
      for(int i=0; i<currentFood.variations.length; i++){
        _selectedVariations.add([]);
        for(int j=0; j<orderedVariation.length; j++){
          if(currentFood.variations[i].name == orderedVariation[j].name){
            for(int x=0; x<currentFood.variations[i].variationValues.length; x++){
              _selectedVariations[i].add(false);
              for(int y=0; y<orderedVariation[j].variationValues.length; y++){
                if(currentFood.variations[i].variationValues[x].level == orderedVariation[j].variationValues[y].level){
                  _selectedVariations[i][x] = true;
                }
              }
            }
          }
        }
      }
    }

    print('--------------selected variations :> $_selectedVariations');

    if(currentFood.variations != null){
      for(int index = 0; index< currentFood.variations.length; index++) {
        for(int i=0; i<currentFood.variations[index].variationValues.length; i++) {
          if(_selectedVariations[index].isNotEmpty && _selectedVariations[index][i]) {
            _variationPrice += currentFood.variations[index].variationValues[i].optionPrice;
          }
        }
      }
    }
    print('--------------variation price : $_variationPrice');

    currentFood.addOns.forEach((addon) {
      for(int i=0; i<orderDetailsModel.addOns.length; i++){
        if(orderDetailsModel.addOns[i].id == addon.id){
          _addOnIdList.add(addon.id);
          _addOnIdWithQtnList.add(cartModel.AddOn(id: addon.id, quantity: orderDetailsModel.addOns[i].quantity));
        }
      }
      _addOnsList.add(addon);
    });


    currentFood.addOns.forEach((addOn) {
      if(_addOnIdList.contains(addOn.id)) {
        _addOnActiveList.add(true);
        _addOnQtyList.add(orderDetailsModel.addOns[_addOnIdList.indexOf(addOn.id)].quantity);
      }else {
        _addOnActiveList.add(false);
        _addOnQtyList.add(1);
      }
    });
    // orderDetailsModel.addOns
    print('------------addons ids : $_addOnIdList');
    print('------------addons active : $_addOnActiveList');
    print('------------addons quantity : $_addOnQtyList');

    double _discount = (currentFood.restaurantDiscount == 0) ? currentFood.discount : currentFood.restaurantDiscount;
    String _discountType = (currentFood.restaurantDiscount == 0) ? currentFood.discountType : 'percent';
    double priceWithDiscount = PriceConverter.convertWithDiscount(_price, _discount, _discountType);

    double priceWithVariation = _price + _variationPrice;


    CartModel _cartModel = CartModel(
      priceWithVariation, priceWithDiscount, (_price - PriceConverter.convertWithDiscount(_price, _discount, _discountType)),
      quantity, _addOnIdWithQtnList, _addOnsList, false, currentFood, _selectedVariations,
    );
    print('--------------!!!!!> $_selectedVariations');
    return _cartModel;
  }

  void _checkProductVariationHasChanged(List<CartModel> _cartList){

    for(CartModel cart in _cartList){
      if(cart.product.variations != null && cart.product.variations.isNotEmpty){
        cart.product.variations.forEach((pv) {
          int _selectedValues = 0;

          if(pv.required){
            cart.variations[cart.product.variations.indexOf(pv)].forEach((selected) {
              if(selected){
                _selectedValues = _selectedValues + 1;
              }
            });

            if(_selectedValues >= pv.min && _selectedValues<= pv.max || (pv.min==0 && pv.max==0)){
              _canReorder = true;
            }else{
              _canReorder = false;
              _reorderMessage = 'this_ordered_products_are_updated_so_can_not_reorder_this_order';
            }

          }else{
            cart.variations[cart.product.variations.indexOf(pv)].forEach((selected) {
              if(selected){
                _selectedValues = _selectedValues + 1;
              }
            });

            if(_selectedValues == 0){
              _canReorder = true;
            }else{
              if(_selectedValues >= pv.min && _selectedValues<= pv.max){
                _canReorder = true;
              }else{
                _canReorder = false;
                _reorderMessage = 'this_ordered_products_are_updated_so_can_not_reorder_this_order';
              }
            }
          }
        });
      }

    }
  }

  Future<void> getDeliveryLogs(int subscriptionID, int offset) async {
    if(offset == 1) {
      _deliverLogs = null;
    }
    Response response = await orderRepo.getSubscriptionDeliveryLog(subscriptionID, offset);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _deliverLogs = PaginatedDeliveryLogModel.fromJson(response.body);
      }else {
        _deliverLogs.data.addAll(PaginatedDeliveryLogModel.fromJson(response.body).data);
        _deliverLogs.offset = PaginatedDeliveryLogModel.fromJson(response.body).offset;
        _deliverLogs.totalSize = PaginatedDeliveryLogModel.fromJson(response.body).totalSize;
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> getPauseLogs(int subscriptionID, int offset) async {
    if(offset == 1) {
      _pauseLogs = null;
    }
    Response response = await orderRepo.getSubscriptionPauseLog(subscriptionID, offset);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _pauseLogs = PaginatedPauseLogModel.fromJson(response.body);
      }else {
        _pauseLogs.data.addAll(PaginatedPauseLogModel.fromJson(response.body).data);
        _pauseLogs.offset = PaginatedPauseLogModel.fromJson(response.body).offset;
        _pauseLogs.totalSize = PaginatedPauseLogModel.fromJson(response.body).totalSize;
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<void> getSubscriptions(int offset, {bool notify = true}) async {
    if(offset == 1) {
      _subscriptionOrderModel = null;
      if(notify) {
        update();
      }
    }
    Response response = await orderRepo.getSubscriptionList(offset);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _subscriptionOrderModel = PaginatedOrderModel.fromJson(response.body);
      }else {
        _subscriptionOrderModel.orders.addAll(PaginatedOrderModel.fromJson(response.body).orders);
        _subscriptionOrderModel.offset = PaginatedOrderModel.fromJson(response.body).offset;
        _subscriptionOrderModel.totalSize = PaginatedOrderModel.fromJson(response.body).totalSize;
      }
      update();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  void setOrderCancelReason(String reason){
    _cancelReason = reason;
    update();
  }

  Future<double> getExtraCharge(double distance) async {
    _extraCharge = null;
    Response response = await orderRepo.getExtraCharge(distance);
    if (response.statusCode == 200) {
      _extraCharge = double.parse(response.body.toString());
    } else {
      _extraCharge = 0;
    }
    return _extraCharge;
  }

  Future<void> getOrderCancelReasons()async {
    Response response = await orderRepo.getCancelReasons();
    if (response.statusCode == 200) {
      OrderCancellationBody orderCancellationBody = OrderCancellationBody.fromJson(response.body);
      _orderCancelReasons = [];
      if(orderCancellationBody != null){
        orderCancellationBody.reasons.forEach((element) {
          _orderCancelReasons.add(element);
        });
      }

    }else{
      ApiChecker.checkApi(response);
    }
    update();
  }

  void callTrackOrderApi({@required OrderModel orderModel, @required String orderId}){
    if(orderModel.orderStatus != 'delivered' && orderModel.orderStatus != 'failed' && orderModel.orderStatus != 'canceled') {
      print('start api call------------');

      Get.find<OrderController>().timerTrackOrder(orderId.toString());
      _timer?.cancel();
      _timer = Timer.periodic(Duration(seconds: 10), (timer) {
        Get.find<OrderController>().timerTrackOrder(orderId.toString());
      });
    }else{
      Get.find<OrderController>().timerTrackOrder(orderId.toString());
    }
  }

  void showOrders(){
    _showOneOrder = !_showOneOrder;
    update();
  }

  void showRunningOrders(){
    _showBottomSheet = !_showBottomSheet;
    update();
  }

  void selectReason(int index,{bool isUpdate = true}){
    _selectedReasonIndex = index;
    if(isUpdate) {
      update();
    }
  }

  void cancelTimer() {
    _timer?.cancel();
  }

  void selectDelivery(int index){
    _deliverySelectIndex = index;
    update();
  }


  // void closeRunningOrder(bool isUpdate){
  //   _isRunningOrderViewShow = !_isRunningOrderViewShow;
  //   if(isUpdate){
  //     update();
  //   }
  // }

  void addTips(double tips, {bool notify = true}) {
    _tips = tips;
    if(notify) {
      update();
    }
  }

  void pickRefundImage(bool isRemove) async {
    if(isRemove) {
      _refundImage = null;
    }else {
      _refundImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      update();
    }
  }

  Future<void> getRefundReasons()async {
    Response response = await orderRepo.getRefundReasons();
    if (response.statusCode == 200) {
      RefundModel _refundModel = RefundModel.fromJson(response.body);
      _refundReasons = [];
      _refundReasons.insert(0, 'select_an_option');
      _refundModel.refundReasons.forEach((element) {
        _refundReasons.add(element.reason);
      });
    }else{
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> submitRefundRequest(String note, String orderId)async {
    if(_selectedReasonIndex == 0){
      showCustomSnackBar('please_select_reason'.tr);
    }else{
      _isLoading = true;
      update();
      Map<String, String> _body = Map();
      _body.addAll(<String, String>{
        'customer_reason': _refundReasons[selectedReasonIndex],
        'order_id': orderId,
        'customer_note': note,
      });
      Response response = await orderRepo.submitRefundRequest(_body, _refundImage);
      if (response.statusCode == 200) {
        showCustomSnackBar(response.body['message'], isError: false);
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }else {
        ApiChecker.checkApi(response);
      }
      _isLoading = false;
      update();
    }
  }

  Future<void> getRunningOrders(int offset, {bool notify = true}) async {
    if(offset == 1) {
      _runningOffsetList = [];
      _runningOffset = 1;
      _runningOrderList = null;
      if(notify) {
        update();
      }
    }
    if (!_runningOffsetList.contains(offset)) {
      _runningOffsetList.add(offset);
      Response response = await orderRepo.getRunningOrderList(offset);
      if (response.statusCode == 200) {
        if (offset == 1) {
          _runningOrderList = [];
        }
        _runningOrderList.addAll(PaginatedOrderModel.fromJson(response.body).orders);
        _runningPageSize = PaginatedOrderModel.fromJson(response.body).totalSize;
        _runningPaginate = false;
        // if(fromHome && _isRunningOrderViewShow){
        //   canActiveOrder();
        // }
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      if(_runningPaginate) {
        _runningPaginate = false;
        update();
      }
    }
  }

  Future<void> getRunningSubscriptionOrders(int offset, {bool notify = true}) async {
    if(offset == 1) {
      _runningSubscriptionOffsetList = [];
      _runningSubscriptionOffset = 1;
      _runningSubscriptionOrderList = null;
      if(notify) {
        update();
      }
    }
    if (!_runningSubscriptionOffsetList.contains(offset)) {
      _runningSubscriptionOffsetList.add(offset);
      Response response = await orderRepo.getRunningSubscriptionOrderList(offset);
      if (response.statusCode == 200) {
        if (offset == 1) {
          _runningSubscriptionOrderList = [];
        }
        _runningSubscriptionOrderList.addAll(PaginatedOrderModel.fromJson(response.body).orders);
        _runningSubscriptionPageSize = PaginatedOrderModel.fromJson(response.body).totalSize;
        _runningSubscriptionPaginate = false;
        // if(fromHome && _isRunningOrderViewShow){
        //   canActiveOrder();
        // }
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      if(_runningSubscriptionPaginate) {
        _runningSubscriptionPaginate = false;
        update();
      }
    }
  }

  /*void canActiveOrder(){
    if(_runningOrderList.isNotEmpty){
      _reversRunningOrderList = List.from(_runningOrderList.reversed);

      for(int i = 0; i < _reversRunningOrderList.length; i++){
        if(_reversRunningOrderList[i].orderStatus == AppConstants.PENDING || _reversRunningOrderList[i].orderStatus == AppConstants.ACCEPTED
            || _reversRunningOrderList[i].orderStatus == AppConstants.PROCESSING || _reversRunningOrderList[i].orderStatus == AppConstants.CONFIRMED
            || _reversRunningOrderList[i].orderStatus == AppConstants.HANDOVER || _reversRunningOrderList[i].orderStatus == AppConstants.PICKED_UP){

          _isRunningOrderViewShow = true;
          _runningOrderIndex = i;
          print(_runningOrderIndex);
          break;
        }else{
          _isRunningOrderViewShow = false;
          print('not found any ongoing order');
        }
      }
      update();
    }
  }*/

  Future<void> getHistoryOrders(int offset, {bool notify = true}) async {
    if(offset == 1) {
      _historyOffsetList = [];
      _historyOrderList = null;
      if(notify) {
        update();
      }
    }
    _historyOffset = offset;
    if (!_historyOffsetList.contains(offset)) {
      _historyOffsetList.add(offset);
      Response response = await orderRepo.getHistoryOrderList(offset);
      if (response.statusCode == 200) {
        if (offset == 1) {
          _historyOrderList = [];
        }
        _historyOrderList.addAll(PaginatedOrderModel.fromJson(response.body).orders);
        _historyPageSize = PaginatedOrderModel.fromJson(response.body).totalSize;
        _historyPaginate = false;
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      if(_historyPaginate) {
        _historyPaginate = false;
        update();
      }
    }
  }

  void showBottomLoader(bool isRunning) {
    if(isRunning) {
      _runningPaginate = true;
    }else {
      _historyPaginate = true;
    }
    update();
  }

  void setOffset(int offset, bool isRunning) {
    if(isRunning) {
      _runningOffset = offset;
    }else {
      _historyOffset = offset;
    }
  }

  Future<List<OrderDetailsModel>> getOrderDetails(String orderID) async {
    _isLoading = true;
    _showCancelled = false;

    Response response = await orderRepo.getOrderDetails(orderID);
    if (response.statusCode == 200) {
      _orderDetails = [];
      _schedules = [];
      response.body['details'].forEach((orderDetail) => _orderDetails.add(OrderDetailsModel.fromJson(orderDetail)));
      response.body['subscription_schedules'].forEach((schedule) => _schedules.add(SubscriptionScheduleModel.fromJson(schedule)));

    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
    return _orderDetails;
  }

  void setPaymentMethod(int index, {bool isUpdate = true}) {
    _paymentMethodIndex = index;
    if(isUpdate) {
      update();
    }
  }

  Future<ResponseModel> trackOrder(String orderID, OrderModel orderModel, bool fromTracking) async {
    _trackModel = null;
    _responseModel = null;
    if(!fromTracking) {
      _orderDetails = null;
    }
    _showCancelled = false;
    if(orderModel == null) {
      _isLoading = true;
      Response response = await orderRepo.trackOrder(orderID);
      if (response.statusCode == 200) {
        _trackModel = OrderModel.fromJson(response.body);
        _responseModel = ResponseModel(true, response.body.toString());
        // callTrackOrderApi(orderModel: _trackModel, orderId: orderID);
      } else {
        _responseModel = ResponseModel(false, response.statusText);
        ApiChecker.checkApi(response);
      }
      _isLoading = false;
      update();
    }else {
      _trackModel = orderModel;
      _responseModel = ResponseModel(true, 'Successful');
      // callTrackOrderApi(orderModel: _trackModel, orderId: orderID);
    }
    return _responseModel;
  }

  Future<ResponseModel> timerTrackOrder(String orderID) async {
    _showCancelled = false;

    Response response = await orderRepo.trackOrder(orderID);
    if (response.statusCode == 200) {
      _trackModel = OrderModel.fromJson(response.body);
      _responseModel = ResponseModel(true, response.body.toString());
    } else {
      _responseModel = ResponseModel(false, response.statusText);
      ApiChecker.checkApi(response);
    }
    update();

    return _responseModel;
  }

  Future<void> placeOrder(PlaceOrderBody placeOrderBody, Function callback, double amount, double maximumCodOrderAmount) async {
    _isLoading = true;
    update();
    Response response = await orderRepo.placeOrder(placeOrderBody);
    _isLoading = false;
    if (response.statusCode == 200) {
      String message = response.body['message'];
      String orderID = response.body['order_id'].toString();
      orderRepo.sendNotificationRequest(orderID);
      callback(true, message, orderID, amount, maximumCodOrderAmount);
      print('-------- Order placed successfully $orderID ----------');
    } else {
      callback(false, response.statusText, '-1', amount, maximumCodOrderAmount);
    }
    update();
  }

  void stopLoader({bool isUpdate = true}) {
    _isLoading = false;
    if(isUpdate) {
      update();
    }
  }

  void clearPrevData() {
    _addressIndex = 0;
    _paymentMethodIndex = Get.find<SplashController>().configModel.cashOnDelivery ? 0
        : Get.find<SplashController>().configModel.digitalPayment ? 1
        : Get.find<SplashController>().configModel.customerWalletStatus == 1 ? 2 : 0;
    _selectedDateSlot = 0;
    _selectedTimeSlot = 0;
    _distance = null;
    _subscriptionOrder = false;
    _selectedDays = [null];
    _subscriptionType = 'daily';
    _subscriptionRange = null;
  }

  void setAddressIndex(int index) {
    _addressIndex = index;
    update();
  }

  Future<bool> cancelOrder(int orderID, String cancelReason) async {
    bool success = false;
    _isLoading = true;
    update();
    Response response = await orderRepo.cancelOrder(orderID.toString(), cancelReason);
    _isLoading = false;
    Get.back();
    if (response.statusCode == 200) {
      success = true;
      OrderModel orderModel;
      for(OrderModel order in _runningOrderList) {
        if(order.id == orderID) {
          orderModel = order;
          break;
        }
      }
      _runningOrderList.remove(orderModel);
      _showCancelled = true;
      showCustomSnackBar(response.body['message'], isError: false);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return success;
  }

  void setOrderType(String type, {bool notify = true}) {
    _orderType = type;
    if(notify) {
      update();
    }
  }

  Future<void> initializeTimeSlot(Restaurant restaurant) async {
    _timeSlots = [];
    _allTimeSlots = [];
    int _minutes = 0;
    DateTime _now = DateTime.now();
    for(int index=0; index<restaurant.schedules.length; index++) {
      DateTime _openTime = DateTime(
        _now.year, _now.month, _now.day, DateConverter.convertStringTimeToDate(restaurant.schedules[index].openingTime).hour,
        DateConverter.convertStringTimeToDate(restaurant.schedules[index].openingTime).minute,
      );
      DateTime _closeTime = DateTime(
        _now.year, _now.month, _now.day, DateConverter.convertStringTimeToDate(restaurant.schedules[index].closingTime).hour,
        DateConverter.convertStringTimeToDate(restaurant.schedules[index].closingTime).minute,
      );
      if(_closeTime.difference(_openTime).isNegative) {
        _minutes = _openTime.difference(_closeTime).inMinutes;
      }else {
        _minutes = _closeTime.difference(_openTime).inMinutes;
      }
      if(_minutes > Get.find<SplashController>().configModel.scheduleOrderSlotDuration) {
        DateTime _time = _openTime;
        for(;;) {
          if(_time.isBefore(_closeTime)) {
            DateTime _start = _time;
            DateTime _end = _start.add(Duration(minutes: Get.find<SplashController>().configModel.scheduleOrderSlotDuration));
            if(_end.isAfter(_closeTime)) {
              _end = _closeTime;
            }
            _timeSlots.add(TimeSlotModel(day: restaurant.schedules[index].day, startTime: _start, endTime: _end));
            _allTimeSlots.add(TimeSlotModel(day: restaurant.schedules[index].day, startTime: _start, endTime: _end));
            _time = _time.add(Duration(minutes: Get.find<SplashController>().configModel.scheduleOrderSlotDuration));
          }else {
            break;
          }
        }
      }else {
        _timeSlots.add(TimeSlotModel(day: restaurant.schedules[index].day, startTime: _openTime, endTime: _closeTime));
        _allTimeSlots.add(TimeSlotModel(day: restaurant.schedules[index].day, startTime: _openTime, endTime: _closeTime));
      }
    }
    validateSlot(_allTimeSlots, 0, notify: false);
  }

  void updateTimeSlot(int index, {bool notify = true}) {
    _selectedTimeSlot = index;
    if(notify) {
      update();
    }
  }

  void updateTips(int index, {bool notify = true}) {
    _selectedTips = index;
    if(notify) {
      update();
    }
  }

  void updateDateSlot(int index) {
    _selectedDateSlot = index;
    _selectedTimeSlot = 0;
    if(_allTimeSlots != null) {
      validateSlot(_allTimeSlots, index);
    }
    update();
  }

  void validateSlot(List<TimeSlotModel> slots, int dateIndex, {bool notify = true}) {
    _timeSlots = [];
    int _day = 0;
    if(dateIndex == 0) {
      _day = DateTime.now().weekday;
    }else {
      _day = DateTime.now().add(Duration(days: 1)).weekday;
    }
    if(_day == 7) {
      _day = 0;
    }
    _slotIndexList = [];
    int _index = 0;
    for(int index=0; index<slots.length; index++) {
      if (_day == slots[index].day && (dateIndex == 0 ? slots[index].endTime.isAfter(DateTime.now()) : true)) {
        _timeSlots.add(slots[index]);
        _slotIndexList.add(_index);
        _index ++;
      }
    }
    if(notify) {
      update();
    }
  }

  Future<bool> switchToCOD(String orderID) async {
    _isLoading = true;
    update();
    Response response = await orderRepo.switchToCOD(orderID);
    bool _isSuccess;
    if (response.statusCode == 200) {
      await Get.offAllNamed(RouteHelper.getInitialRoute());
      showCustomSnackBar(response.body['message'], isError: false);
      _isSuccess = true;
    } else {
      ApiChecker.checkApi(response);
      _isSuccess = false;
    }
    _isLoading = false;
    update();
    return _isSuccess;
  }

  Future<double> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {
    _distance = -1;
    Response response = await orderRepo.getDistanceInMeter(originLatLng, destinationLatLng);
    try {
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        _distance = DistanceModel.fromJson(response.body).rows[0].elements[0].distance.value / 1000;
      } else {
        _distance = Geolocator.distanceBetween(
          originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude,
        ) / 1000;
      }
    } catch (e) {
      _distance = Geolocator.distanceBetween(
        originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude,
      ) / 1000;
    }
    await getExtraCharge(_distance);

    update();
    return _distance;
  }


  void setSubscription(bool isSubscribed) {
    _subscriptionOrder = isSubscribed;
    _orderType = 'delivery';
    update();
  }

  void setSubscriptionRange(DateTimeRange range) {
    _subscriptionRange = range;
    update();
  }

  void setSubscriptionType(String type) {
    _subscriptionType = type;
    _selectedDays = [];
    for(int index=0; index < (type == 'weekly' ? 7 : type == 'monthly' ? 31 : 1); index++) {
      _selectedDays.add(null);
    }
    update();
  }

  void addDay(int index, TimeOfDay time) {
    if(time != null) {
      _selectedDays[index] = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, time.hour, time.minute);
    }else {
      _selectedDays[index] = null;
    }
    update();
  }

  Future<bool> updateSubscriptionStatus(int subscriptionID, DateTime startDate, DateTime endDate, String status, String note, String reason) async {
    _subscriveLoading = true;
    update();
    Response response = await orderRepo.updateSubscriptionStatus(
      subscriptionID, startDate != null ? DateConverter.dateToDateAndTime(startDate) : null,
      endDate != null ? DateConverter.dateToDateAndTime(endDate) : null, status, note, reason,
    );
    bool _isSuccess;
    if (response.statusCode == 200) {
      Get.back();
      if(status == 'canceled' || startDate.isAtSameMomentAs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
        _trackModel.subscription.status = status;
      }
      showCustomSnackBar(
        status == 'paused' ? 'subscription_paused_successfully'.tr : 'subscription_cancelled_successfully'.tr, isError: false,
      );
      _isSuccess = true;
    } else {
      ApiChecker.checkApi(response);
      _isSuccess = false;
    }
    _subscriveLoading = false;
    update();
    return _isSuccess;
  }
}