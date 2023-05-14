import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/data/model/response/delivery_log_model.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/paginated_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class LogDialog extends StatefulWidget {
  final int subscriptionID;
  final bool isDelivery;
  LogDialog({@required this.subscriptionID, @required this.isDelivery});

  @override
  State<LogDialog> createState() => _LogDialogState();
}

class _LogDialogState extends State<LogDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if(widget.isDelivery) {
      Get.find<OrderController>().getDeliveryLogs(widget.subscriptionID, 1);
    }else {
      Get.find<OrderController>().getPauseLogs(widget.subscriptionID, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
      insetPadding: EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: SizedBox(width: 500, child: Stack(children: [

          Padding(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
                child: Text(
                  widget.isDelivery ? 'delivery_log'.tr : 'pause_log'.tr, textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
                ),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

              Expanded(child: GetBuilder<OrderController>(builder: (orderController) {
                bool _notNull = widget.isDelivery ? orderController.deliveryLogs != null : orderController.pauseLogs != null;
                int _length;
                int _total;
                int _offset;
                if(_notNull) {
                  _length = widget.isDelivery ? orderController.deliveryLogs.data.length : orderController.pauseLogs.data.length;
                  _total = widget.isDelivery ? orderController.deliveryLogs.totalSize : orderController.pauseLogs.totalSize;
                  _offset = widget.isDelivery ? orderController.deliveryLogs.offset : orderController.pauseLogs.offset;
                }

                return _notNull ? _length > 0 ? PaginatedListView(
                  scrollController: _scrollController,
                  onPaginate: (int offset) {
                    if(widget.isDelivery) {
                      orderController.getDeliveryLogs(widget.subscriptionID, offset);
                    }else {
                      orderController.getPauseLogs(widget.subscriptionID, offset);
                    }
                  },
                  totalSize: _total,
                  offset: _offset,
                  productView: ListView.builder(
                    controller: _scrollController,
                    itemCount: _length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DeliveryLogModel logData = orderController.deliveryLogs.data[index];

                      return Column(children: [

                        Row(children: [

                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Row(children: [
                              Text('${index + 1})  ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

                              widget.isDelivery ? Text(
                                DateConverter.dateTimeStringToDateTime(
                                    logData.orderStatus == 'pending' ? logData.scheduleAt : logData.orderStatus == 'accepted' ? logData.accepted
                                    : logData.orderStatus == 'confirmed' ? logData.confirmed : logData.orderStatus == 'processing' ? logData.processing
                                        : logData.orderStatus == 'handover' ? logData.handover
                                    : logData.orderStatus == 'picked_up' ? logData.pickedUp : logData.orderStatus == 'delivered' ? logData.delivered
                                    : logData.orderStatus == 'canceled' ? logData.canceled : logData.failed
                                ),
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              ) : Text(
                                '${DateConverter.stringDateTimeToDate(orderController.pauseLogs.data[index].from)} '
                                    '- ${DateConverter.stringDateTimeToDate(orderController.pauseLogs.data[index].to)}',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                              ),
                            ]),

                          ])),
                          SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                          widget.isDelivery ? Container(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                            ),
                            child: Text(
                              orderController.deliveryLogs.data[index].orderStatus.tr,
                              style: robotoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeExtraSmall),
                            ),
                          ) : SizedBox(),

                        ]),

                        index != _length-1 ? Divider(
                          color: Theme.of(context).disabledColor, height: Dimensions.PADDING_SIZE_LARGE,
                        ) : SizedBox(),

                      ]);
                    },
                  ),
                ) : Center(child: Text('no_log_found'.tr)) : Center(child: CircularProgressIndicator());
              })),

            ]),
          ),

          Positioned(top: 0, right: 0, child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.cancel),
          )),

        ])),
      ),
    );
  }
}
