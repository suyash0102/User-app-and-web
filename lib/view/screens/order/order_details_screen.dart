import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/body/notification_body.dart';
import 'package:efood_multivendor/data/model/response/conversation_model.dart';
import 'package:efood_multivendor/data/model/response/order_details_model.dart';
import 'package:efood_multivendor/data/model/response/order_model.dart';
import 'package:efood_multivendor/data/model/response/review_model.dart';
import 'package:efood_multivendor/data/model/response/subscription_schedule_model.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/helper/price_converter.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/screens/chat/widget/image_dialog.dart';
import 'package:efood_multivendor/view/screens/order/widget/cancellation_dialogue.dart';
import 'package:efood_multivendor/view/screens/order/widget/log_dialog.dart';
import 'package:efood_multivendor/view/screens/order/widget/order_product_widget.dart';
import 'package:efood_multivendor/view/screens/order/widget/subscription_pause_dialog.dart';
import 'package:efood_multivendor/view/screens/restaurant/widget/review_dialog.dart';
import 'package:efood_multivendor/view/screens/review/rate_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel orderModel;
  final int orderId;
  OrderDetailsScreen({@required this.orderModel, @required this.orderId});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> with WidgetsBindingObserver {

  void _loadData() async {
    await Get.find<OrderController>().trackOrder(widget.orderId.toString(), widget.orderModel != null ? widget.orderModel : null, false);
    if(widget.orderModel == null) {
      await Get.find<SplashController>().getConfigData();
    }
    Get.find<OrderController>().getOrderCancelReasons();
    Get.find<OrderController>().getOrderDetails(widget.orderId.toString());
    if(Get.find<OrderController>().trackModel != null){
      Get.find<OrderController>().callTrackOrderApi(orderModel: Get.find<OrderController>().trackModel, orderId: widget.orderId.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadData();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.find<OrderController>().callTrackOrderApi(orderModel: Get.find<OrderController>().trackModel, orderId: widget.orderId.toString());
    }else if(state == AppLifecycleState.paused){
      Get.find<OrderController>().cancelTimer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

    Get.find<OrderController>().cancelTimer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(widget.orderModel == null) {
          return Get.offAllNamed(RouteHelper.getInitialRoute());
        }else {
          return true;
        }
      },
      child: GetBuilder<OrderController>(builder: (orderController) {
          double _deliveryCharge = 0;
          double _itemsPrice = 0;
          double _discount = 0;
          double _couponDiscount = 0;
          double _tax = 0;
          double _addOns = 0;
          double _dmTips = 0;
          bool _showChatPermission = true;
          bool _taxIncluded = false;
          OrderModel _order = orderController.trackModel;
          bool _subscription = false;
          bool _pending, _accepted, _confirmed, _processing, _pickedUp, _delivered, _cancelled, _delivery, _takeAway, _cod, _digitalPay;
          List<String> _schedules = [];
          if(orderController.orderDetails != null && _order != null) {
            _subscription = _order.subscription != null;

            print('---orderStatus---> ${_order.orderStatus}');
            print('---orderType---> ${_order.orderType}');
            _pending = _order.orderStatus == AppConstants.PENDING;
            _accepted = _order.orderStatus == AppConstants.ACCEPTED;
            _confirmed = _order.orderStatus == AppConstants.CONFIRMED;
            _processing = _order.orderStatus == AppConstants.PROCESSING;
            _pickedUp = _order.orderStatus == AppConstants.PICKED_UP;
            _delivered = _order.orderStatus == AppConstants.DELIVERED;
            _cancelled = _order.orderStatus == AppConstants.CANCELLED;
            _delivery = _order.orderType == 'delivery';
            _takeAway = _order.orderType == 'take_away';
            _cod = _order.paymentMethod == 'cash_on_delivery';
            _digitalPay = _order.paymentMethod == 'digital_payment';

            if(_subscription) {
              if(_order.subscription.type == 'weekly') {
                List<String> _weekDays = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
                for(SubscriptionScheduleModel schedule in orderController.schedules) {
                  _schedules.add('${_weekDays[schedule.day].tr} (${DateConverter.convertTimeToTime(schedule.time)})');
                }
              }else if(_order.subscription.type == 'monthly') {
                for(SubscriptionScheduleModel schedule in orderController.schedules) {
                  _schedules.add('${'day_capital'.tr} ${schedule.day} (${DateConverter.convertTimeToTime(schedule.time)})');
                }
              }else {
                _schedules.add(DateConverter.convertTimeToTime(orderController.schedules[0].time));
              }
            }
            if(_delivery) {
              _deliveryCharge = _order.deliveryCharge;
              _dmTips = _order.dmTips;
            }
            _couponDiscount = _order.couponDiscountAmount;
            _discount = _order.restaurantDiscountAmount;
            _tax = _order.totalTaxAmount;
            _taxIncluded = _order.taxStatus;
            for(OrderDetailsModel orderDetails in orderController.orderDetails) {
              for(AddOn addOn in orderDetails.addOns) {
                _addOns = _addOns + (addOn.price * addOn.quantity);
              }
              _itemsPrice = _itemsPrice + (orderDetails.price * orderDetails.quantity);
            }
            if(_order.restaurant != null) {
              if (_order.restaurant.restaurantModel == 'commission') {
                _showChatPermission = true;
              } else if (_order.restaurant.restaurantSubscription != null &&
                  _order.restaurant.restaurantSubscription.chat == 1) {
                _showChatPermission = true;
              } else {
                _showChatPermission = false;
              }
            }
          }
          double _subTotal = _itemsPrice + _addOns;
          double _total = _itemsPrice + _addOns - _discount + (_taxIncluded ? 0 : _tax) + _deliveryCharge - _couponDiscount + _dmTips;

        return Scaffold(
            appBar: CustomAppBar(title: _subscription ? 'subscription_details'.tr : 'order_details'.tr, onBackPressed: () {
              if(widget.orderModel == null) {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              }else {
                Get.back();
              }
            }),
            body: (_order != null && orderController.orderDetails != null) ? Column(children: [

            Expanded(child: Scrollbar(child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              child: Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                DateConverter.isBeforeTime(_order.scheduleAt) ? (_order.orderStatus != 'delivered' && _order.orderStatus != 'failed'
                && !_cancelled && _order.orderStatus != 'refund_requested' && _order.orderStatus != 'refunded'
                && _order.orderStatus != 'refund_request_canceled' && !_subscription) ? Column(children: [

                  ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(Images.animate_delivery_man, fit: BoxFit.contain)),
                  SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

                  Text('your_food_will_delivered_within'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                  Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [

                      Text(
                        DateConverter.differenceInMinute(_order.restaurant.deliveryTime, _order.createdAt, _order.processingTime, _order.scheduleAt) < 5 ? '1 - 5'
                            : '${DateConverter.differenceInMinute(_order.restaurant.deliveryTime, _order.createdAt, _order.processingTime, _order.scheduleAt)-5} '
                            '- ${DateConverter.differenceInMinute(_order.restaurant.deliveryTime, _order.createdAt, _order.processingTime, _order.scheduleAt)}',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                      ),
                      SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                      Text('min'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
                    ]),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),

                ]) : SizedBox() : SizedBox(),

                Row(children: [
                  Text('${_subscription ? 'subscription_id'.tr : 'order_id'.tr}:', style: robotoRegular),
                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Text(_order.id.toString(), style: robotoMedium),
                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Expanded(child: SizedBox()),
                  Icon(Icons.watch_later, size: 17),
                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Text(
                    DateConverter.dateTimeStringToDateTime(_order.createdAt),
                    style: robotoRegular,
                  ),
                ]),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                _order.scheduled == 1 ? Row(children: [
                  Text('${'scheduled_at'.tr}:', style: robotoRegular),
                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Text(DateConverter.dateTimeStringToDateTime(_order.scheduleAt), style: robotoMedium),
                ]) : SizedBox(),
                SizedBox(height: _order.scheduled == 1 ? Dimensions.PADDING_SIZE_SMALL : 0),

                Get.find<SplashController>().configModel.orderDeliveryVerification ? Row(children: [
                  Text('${'delivery_verification_code'.tr}:', style: robotoRegular),
                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Text(_order.otp, style: robotoMedium),
                ]) : SizedBox(),
                SizedBox(height: Get.find<SplashController>().configModel.orderDeliveryVerification ? 10 : 0),

                Row(children: [
                  Text(_order.orderType.tr, style: robotoMedium),
                  Expanded(child: SizedBox()),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    ),
                    child: Text(
                      _cod ? 'cash_on_delivery'.tr : _order.paymentMethod == 'wallet'
                          ? 'wallet_payment'.tr : 'digital_payment'.tr,
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall),
                    ),
                  ),
                ]),
                Divider(height: Dimensions.PADDING_SIZE_LARGE),

                _subscription ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Row(children: [
                    Text('${'subscription_date'.tr}:', style: robotoRegular),
                    SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    Text(
                      '${DateConverter.stringDateTimeToDate(_order.subscription.startAt)} '
                          '- ${DateConverter.stringDateTimeToDate(_order.subscription.endAt)}',
                      style: robotoMedium,
                    ),
                  ]),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Row(children: [
                    Text('${'subscription_type'.tr}:', style: robotoRegular),
                    SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    Text(
                      _order.subscription.type.tr,
                      style: robotoMedium,
                    ),
                  ]),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Text('${'subscription_schedule'.tr}:', style: robotoRegular),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  SizedBox(height: 30, child: ListView.builder(
                    itemCount: _schedules.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                        margin: const EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          border: Border.all(color: Theme.of(context).disabledColor, width: 1),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(
                            _schedules[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular,
                          ),
                        ]),
                      );
                    },
                  )),
                  SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                  Row(children: [
                    Expanded(child: CustomButton(
                      buttonText: 'delivery_log'.tr,
                      height: 35,
                      onPressed: () => Get.dialog(LogDialog(subscriptionID: _order.subscriptionId, isDelivery: true)),
                    )),
                    SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                    Expanded(child: CustomButton(
                      buttonText: 'pause_log'.tr,
                      height: 35,
                      onPressed: () => Get.dialog(LogDialog(subscriptionID: _order.subscriptionId, isDelivery: false)),
                    )),
                  ]),

                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Divider(height: Dimensions.PADDING_SIZE_LARGE),
                ]) : SizedBox(),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  child: Row(children: [
                    Text('${'item'.tr}:', style: robotoRegular),
                    SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    Text(
                      orderController.orderDetails.length.toString(),
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                    ),
                    Expanded(child: SizedBox()),
                    Container(height: 7, width: 7, decoration: BoxDecoration(
                      color: (_subscription ? _order.subscription.status == 'canceled' : (_order.orderStatus == 'failed' || _cancelled || _order.orderStatus == 'refund_request_canceled'))
                          ? Colors.red : _order.orderStatus == 'refund_requested' ? Colors.yellow : Colors.green ,
                      shape: BoxShape.circle,
                    )),
                    SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    Text(
                      _delivered ? '${'delivered_at'.tr} ${DateConverter.dateTimeStringToDateTime(_order.delivered)}'
                          : _subscription ? _order.subscription.status.tr : _order.orderStatus.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                  ]),
                ),

                _cancelled ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Divider(height: Dimensions.PADDING_SIZE_LARGE),
                  Text('${'cancellation_reason'.tr}:', style: robotoMedium),
                  SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                  InkWell(
                    onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: _order.cancellationReason), fromOrderDetails: true)),
                    child: Text(
                      '${_order.cancellationReason != null ? _order.cancellationReason : ''}', maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                    ),
                  ),

                ]) : SizedBox(),

                _cancelled && _order.cancellationNote != null && _order.cancellationNote != '' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Divider(height: Dimensions.PADDING_SIZE_LARGE),
                  Text('${'cancellation_note'.tr}:', style: robotoMedium),
                  SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                  InkWell(
                    onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: _order.cancellationNote), fromOrderDetails: true)),
                    child: Text(
                      '${_order.cancellationNote != null ? _order.cancellationNote : ''}', maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                    ),
                  ),

                ]) : SizedBox(),

                (_order.orderStatus == 'refund_requested' || _order.orderStatus == 'refund_request_canceled') ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Divider(height: Dimensions.PADDING_SIZE_LARGE),
                  _order.orderStatus == 'refund_requested' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    RichText(text: TextSpan(children: [
                      TextSpan(text: '${'refund_note'.tr}:', style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge.color)),
                      TextSpan(text: '(${(_order.refund != null) ? _order.refund.customerReason : ''})', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge.color)),
                    ])),
                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                    (_order.refund != null && _order.refund.customerNote != null) ? InkWell(
                      onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: _order.refund.customerNote), fromOrderDetails: true)),
                      child: Text(
                        '${_order.refund.customerNote}', maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                      ),
                    ) : SizedBox(),
                    SizedBox(height: (_order.refund != null && _order.refund.image != null) ? Dimensions.PADDING_SIZE_SMALL : 0),

                    (_order.refund != null && _order.refund.image != null && _order.refund.image.isNotEmpty) ? InkWell(
                      onTap: () => showDialog(context: context, builder: (context) {
                        return ImageDialog(imageUrl: '${Get.find<SplashController>().configModel.baseUrls.refundImageUrl}/${_order.refund.image.isNotEmpty ? _order.refund.image[0] : ''}');
                      }),
                      child: CustomImage(
                        height: 40, width: 40, fit: BoxFit.cover,
                        image: _order.refund != null ? '${Get.find<SplashController>().configModel.baseUrls.refundImageUrl}/${_order.refund.image.isNotEmpty ? _order.refund.image[0] : ''}' : '',
                      ),
                    ) : SizedBox(),
                  ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${'refund_cancellation_note'.tr}:', style: robotoMedium),
                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                    InkWell(
                      onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: _order.refund.adminNote), fromOrderDetails: true)),
                      child: Text(
                        '${_order.refund != null ? _order.refund.adminNote : ''}', maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                      ),
                    ),

                  ]),

                ]) : SizedBox(),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                Divider(height: Dimensions.PADDING_SIZE_LARGE),

                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: orderController.orderDetails.length,
                  itemBuilder: (context, index) {
                    return OrderProductWidget(order: _order, orderDetails: orderController.orderDetails[index]);
                  },
                ),

                (_order.orderNote  != null && _order.orderNote.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('additional_note'.tr, style: robotoRegular),
                  SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  Container(
                    width: Dimensions.WEB_MAX_WIDTH,
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      border: Border.all(width: 1, color: Theme.of(context).disabledColor),
                    ),
                    child: Text(
                      _order.orderNote,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                ]) : SizedBox(),

                Text('restaurant_details'.tr, style: robotoRegular),
                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                _order.restaurant != null ? Row(children: [
                  ClipOval(child: CustomImage(
                    image: '${Get.find<SplashController>().configModel.baseUrls.restaurantImageUrl}/${_order.restaurant.logo}',
                    height: 35, width: 35, fit: BoxFit.cover,
                  )),
                  SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      _order.restaurant.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                    Text(
                      _order.restaurant.address, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),
                  ])),

                  (_takeAway && (_pending || _accepted || _confirmed || _processing || _order.orderStatus == 'handover'
                  || _pickedUp)) ? TextButton.icon(
                    onPressed: () async {
                      String url ='https://www.google.com/maps/dir/?api=1&destination=${_order.restaurant.latitude}'
                          ',${_order.restaurant.longitude}&mode=d';
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url, mode: LaunchMode.externalApplication);
                      }else {
                        showCustomSnackBar('unable_to_launch_google_map'.tr);
                      }
                    },
                    icon: Icon(Icons.directions), label: Text('direction'.tr),
                  ) : SizedBox(),

                  (_showChatPermission && !_delivered && _order.orderStatus != 'failed' && !_cancelled && _order.orderStatus != 'refunded') ? TextButton.icon(
                    onPressed: () async {
                      orderController.cancelTimer();
                      await Get.toNamed(RouteHelper.getChatRoute(
                        notificationBody: NotificationBody(orderId: _order.id, restaurantId: _order.restaurant.vendorId),
                        user: User(id: _order.restaurant.vendorId, fName: _order.restaurant.name, lName: '', image: _order.restaurant.logo),
                      ));
                      orderController.callTrackOrderApi(orderModel: _order, orderId: _order.id.toString());
                    },
                    icon: Icon(Icons.chat_bubble_outline, color: Theme.of(context).primaryColor, size: 20),
                    label: Text(
                      'chat'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                    ),
                  ) : SizedBox(),

                  (!_subscription && Get.find<SplashController>().configModel.refundStatus && _delivered && orderController.orderDetails[0].itemCampaignId == null)
                  ? InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getRefundRequestRoute(_order.id.toString())),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL, vertical: Dimensions.PADDING_SIZE_SMALL),
                      child: Text('request_for_refund'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                    ),
                  ) : SizedBox(),

                ]) : Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                  child: Text(
                    'no_restaurant_data_found'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                )),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                // Total
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('item_price'.tr, style: robotoRegular),
                  Text(PriceConverter.convertPrice(_itemsPrice), style: robotoRegular),
                ]),
                SizedBox(height: 10),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('addons'.tr, style: robotoRegular),
                  Text('(+) ${PriceConverter.convertPrice(_addOns)}', style: robotoRegular),
                ]),

                Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),

                !_subscription ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('subtotal'.tr + ' ${_taxIncluded ? 'tax_included'.tr : ''}', style: robotoMedium),
                  Text(PriceConverter.convertPrice(_subTotal), style: robotoMedium),
                ]) : SizedBox(),
                SizedBox(height: !_subscription ? Dimensions.PADDING_SIZE_SMALL : 0),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('discount'.tr, style: robotoRegular),
                  Text('(-) ${PriceConverter.convertPrice(_discount)}', style: robotoRegular),
                ]),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                _couponDiscount > 0 ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('coupon_discount'.tr, style: robotoRegular),
                  Text(
                    '(-) ${PriceConverter.convertPrice(_couponDiscount)}',
                    style: robotoRegular,
                  ),
                ]) : SizedBox(),
                SizedBox(height: _couponDiscount > 0 ? Dimensions.PADDING_SIZE_SMALL : 0),

                !_taxIncluded ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('vat_tax'.tr, style: robotoRegular),
                  Text('(+) ${PriceConverter.convertPrice(_tax)}', style: robotoRegular),
                ]) : SizedBox(),
                SizedBox(height: _taxIncluded ? 0 : Dimensions.PADDING_SIZE_SMALL),

                (!_subscription && _order.orderType != 'take_away' && Get.find<SplashController>().configModel.dmTipsStatus == 1) ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('delivery_man_tips'.tr, style: robotoRegular),
                    Text('(+) ${PriceConverter.convertPrice(_dmTips)}', style: robotoRegular),
                  ],
                ) : SizedBox(),
                SizedBox(height: (_order.orderType != 'take_away' && Get.find<SplashController>().configModel.dmTipsStatus == 1) ? 10 : 0),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('delivery_fee'.tr, style: robotoRegular),
                  _deliveryCharge > 0 ? Text(
                    '(+) ${PriceConverter.convertPrice(_deliveryCharge)}', style: robotoRegular,
                  ) : Text('free'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                ]),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                  child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                ),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(_subscription ? 'subtotal'.tr : 'total_amount'.tr, style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor,
                  )),
                  Text(
                    PriceConverter.convertPrice(_total),
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                  ),
                ]),

                _subscription ? Column(children: [
                  SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('subscription_order_count'.tr, style: robotoMedium),
                    Text(_order.subscription.quantity.toString(), style: robotoMedium),
                  ]),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                    child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(
                      'total_amount'.tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                    ),
                    Text(
                      PriceConverter.convertPrice(_total * _order.subscription.quantity),
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                    ),
                  ]),
                ]) : SizedBox(),

              ]))),
            ))),

              !orderController.showCancelled ? Center(
                child: SizedBox(
                  width: Dimensions.WEB_MAX_WIDTH + 20,
                  child: Row(children: [
                    ((!_subscription || (_order.subscription.status != 'canceled' && _order.subscription.status != 'completed')) && ((_pending && !_digitalPay) || _accepted || _confirmed
                        || _processing || _order.orderStatus == 'handover'|| _pickedUp)) ? Expanded(
                      child: CustomButton(
                        buttonText: _subscription ? 'track_subscription'.tr : 'track_order'.tr,
                        margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                        onPressed: () async {
                          orderController.cancelTimer();
                          await Get.toNamed(RouteHelper.getOrderTrackingRoute(_order.id));
                          orderController.callTrackOrderApi(orderModel: _order, orderId: widget.orderId.toString());
                        },
                      ),
                    ) : SizedBox(),

                    (_pending && _order.paymentStatus == 'unpaid' && _digitalPay && Get.find<SplashController>().configModel.cashOnDelivery) ?
                    Expanded(
                      child: CustomButton(
                        buttonText: 'switch_to_cash_on_delivery'.tr,
                        margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                        onPressed: () {
                          Get.dialog(ConfirmationDialog(
                              icon: Images.warning, description: 'are_you_sure_to_switch'.tr,
                              onYesPressed: () {
                                double _maxCodOrderAmount = Get.find<LocationController>().getUserAddress().zoneData.firstWhere((data) => data.id == _order.restaurant.zoneId).maxCodOrderAmount
                                    ?? 0;

                                if(_maxCodOrderAmount > _total){
                                  orderController.switchToCOD(_order.id.toString()).then((isSuccess) {
                                    Get.back();
                                    if(isSuccess) {
                                      Get.back();
                                    }
                                  });
                                }else{
                                  if(Get.isDialogOpen) {
                                    Get.back();
                                  }
                                  showCustomSnackBar('you_cant_order_more_then'.tr + ' ${PriceConverter.convertPrice(_maxCodOrderAmount)} ' + 'in_cash_on_delivery'.tr);
                                }
                              }
                          ));
                        },
                      ),
                    ): SizedBox(),

                    (_subscription ? (_order.subscription.status == 'active' || _order.subscription.status == 'paused')
                        : (_pending)) ? Expanded(child: Padding(
                      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: TextButton(
                        style: TextButton.styleFrom(minimumSize: Size(1, 50), shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          side: BorderSide(width: 2, color: Theme.of(context).disabledColor),
                        )),
                        onPressed: () {
                          if(_subscription) {
                            Get.dialog(SubscriptionPauseDialog(subscriptionID: _order.subscriptionId, isPause: false));
                          }else {
                            orderController.setOrderCancelReason('');
                            Get.dialog(CancellationDialogue(orderId: _order.id));
                          }
                        },
                        child: Text(_subscription ? 'cancel_subscription'.tr : 'cancel_order'.tr, style: robotoBold.copyWith(
                          color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeDefault,
                        )),
                      ),
                    )) : SizedBox(),

                  ]),
                ),
              ) : Center(
                child: Container(
                  width: Dimensions.WEB_MAX_WIDTH,
                  height: 50,
                  margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  ),
                  child: Text('order_cancelled'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                ),
              ),

              !orderController.showCancelled && _subscription && (_order.subscription.status == 'active' || _order.subscription.status == 'paused') ? CustomButton(
                buttonText: 'pause_subscription'.tr,
                margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                onPressed: () async {
                  Get.dialog(SubscriptionPauseDialog(subscriptionID: _order.subscriptionId, isPause: true));
                },
              ) : SizedBox(),

            Center(
              child: SizedBox(
                width: Dimensions.WEB_MAX_WIDTH,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  child: !orderController.isLoading ? Row(
                    children: [
                      (!_subscription && _delivered && orderController.orderDetails[0].itemCampaignId == null) ? Expanded(
                        child: CustomButton(
                          buttonText: 'review'.tr,
                          onPressed: () async {
                            List<OrderDetailsModel> _orderDetailsList = [];
                            List<int> _orderDetailsIdList = [];
                            orderController.orderDetails.forEach((orderDetail) {
                              if(!_orderDetailsIdList.contains(orderDetail.foodDetails.id)) {
                                _orderDetailsList.add(orderDetail);
                                _orderDetailsIdList.add(orderDetail.foodDetails.id);
                              }
                            });
                            orderController.cancelTimer();
                            await Get.toNamed(RouteHelper.getReviewRoute(), arguments: RateReviewScreen(
                              orderDetailsList: _orderDetailsList, deliveryMan: _order.deliveryMan,
                            ));
                            orderController.callTrackOrderApi(orderModel: _order, orderId: widget.orderId.toString());
                          },
                        ),
                      ) : SizedBox(),
                      SizedBox(width: _cancelled || _order.orderStatus == 'failed' ? 0 : Dimensions.PADDING_SIZE_SMALL),

                      !_subscription && (_delivered || _cancelled || _order.orderStatus == 'failed' || _order.orderStatus == 'refund_request_canceled')
                      ? Expanded(
                        child: CustomButton(
                          buttonText: 'reorder'.tr,
                          onPressed: () => orderController.reOrder(orderController.orderDetails, _order.restaurant.zoneId),
                        ),
                      ) : SizedBox(),
                    ],
                  ) : Center(child: CircularProgressIndicator()),
                ),
              ),
            ),


            Builder(
              builder: (context) {
                return ((_order.orderStatus == 'failed' || _cancelled) && !_cod && Get.find<SplashController>().configModel.cashOnDelivery) ? Center(
                  child: Container(
                    width: Dimensions.WEB_MAX_WIDTH,
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    child: CustomButton(
                      buttonText: 'switch_to_cash_on_delivery'.tr,
                      onPressed: () {
                        Get.dialog(ConfirmationDialog(
                          icon: Images.warning, description: 'are_you_sure_to_switch'.tr,
                          onYesPressed: () {
                            double _maxCodOrderAmount = Get.find<LocationController>().getUserAddress().zoneData.firstWhere((data) => data.id == _order.restaurant.zoneId).maxCodOrderAmount;

                            if(_maxCodOrderAmount == null || _maxCodOrderAmount > _total){
                              orderController.switchToCOD(_order.id.toString()).then((isSuccess) {
                                Get.back();
                                if(isSuccess) {
                                  Get.back();
                                }
                              });
                            }else{
                              if(Get.isDialogOpen) {
                                Get.back();
                              }
                              showCustomSnackBar('you_cant_order_more_then'.tr + ' ${PriceConverter.convertPrice(_maxCodOrderAmount)} ' + 'in_cash_on_delivery'.tr);
                            }
                          }
                        ));
                      },
                    ),
                  ),
                ) : SizedBox();
              }
            ),



          ]) : Center(child: CircularProgressIndicator())

        );
      }),
    );
  }
}