import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/data/model/response/order_cancellation_body.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/screens/checkout/widget/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class SubscriptionPauseDialog extends StatefulWidget {
  final int subscriptionID;
  final bool isPause;
  SubscriptionPauseDialog({@required this.subscriptionID, @required this.isPause});

  @override
  State<SubscriptionPauseDialog> createState() => _SubscriptionPauseDialogState();
}

class _SubscriptionPauseDialogState extends State<SubscriptionPauseDialog> {
  DateTimeRange _range;
  TextEditingController _noteController = TextEditingController();
  List<DropdownMenuItem<int>> _cancelReasons = [];
  List<CancellationData> _reasons = [];
  @override
  void initState() {
    super.initState();


    if(Get.find<OrderController>().orderCancelReasons != null && Get.find<OrderController>().orderCancelReasons.isNotEmpty){

      _reasons.add(CancellationData(reason: 'select_cancel_reason'.tr));
      Get.find<OrderController>().orderCancelReasons.forEach((reason) {
        _reasons.add(reason);
      });

      for(int index=0; index < _reasons.length; index++){
        _cancelReasons.add(DropdownMenuItem<int>(value: index, child: Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: SizedBox(
              height: 30 ,
              child: Center(child: Text(_reasons[index].reason, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)))),
        ),
        ));
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
      insetPadding: EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: SizedBox(width: 500, child: Padding(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
          child: SingleChildScrollView(
            child: GetBuilder<OrderController>(
              builder: (orderController) {
                return Column(mainAxisSize: MainAxisSize.min, children: [

                  Padding(
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                    child: Image.asset(Images.warning, width: 50, height: 50, color: Theme.of(context).primaryColor),
                  ),

                  Padding(
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                    child: Text(
                      widget.isPause ? 'are_you_sure_to_pause_subscription'.tr : 'are_you_sure_to_cancel_subscription'.tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                  !widget.isPause
                      ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        border: Border.all(
                          color: Theme.of(context).textTheme.bodyLarge.color, width: 0.5,
                       )
                    ),
                        child: DropdownButton(
                          value: orderController.cancellationIndex,
                            items: _cancelReasons,
                            itemHeight: 50,
                            underline: SizedBox(),
                            onChanged: (int index){
                              orderController.setCancelIndex(index);
                              orderController.setOrderCancelReason(_reasons[index].reason);
                            },
                        ),
                      ) : SizedBox(),
                  SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                  widget.isPause ? CustomDatePicker(
                    hint: 'choose_subscription_pause_date'.tr,
                    range: _range,
                    isPause: widget.isPause,
                    onDatePicked: (DateTimeRange range) {
                      setState(() {
                        _range = range;
                      });
                    },
                  ) : CustomTextField(
                    hintText: 'write_cancellation_reason'.tr,
                    controller: _noteController,
                    maxLines: 3,
                    inputType: TextInputType.multiline,
                    inputAction: TextInputAction.newline,
                    fillColor: Theme.of(context).disabledColor.withOpacity(0.1),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                  GetBuilder<OrderController>(builder: (orderController) {
                    return !orderController.subscriveLoading ? Row(children: [
                      Expanded(child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).disabledColor.withOpacity(0.3), minimumSize: Size(Dimensions.WEB_MAX_WIDTH, 50), padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
                        ),
                        child: Text(
                          'no'.tr, textAlign: TextAlign.center,
                          style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge.color),
                        ),
                      )),
                      SizedBox(width: Dimensions.PADDING_SIZE_LARGE),

                      Expanded(child: CustomButton(
                        buttonText: 'yes'.tr,
                        onPressed: () {
                          if(widget.isPause && _range == null) {
                            showCustomSnackBar('choose_subscription_pause_date'.tr);
                          }else if(!widget.isPause && orderController.cancellationIndex == 0) {
                            showCustomSnackBar('please_select_cancellation_reason_first'.tr);
                          }else {
                            orderController.updateSubscriptionStatus(
                              widget.subscriptionID, _range != null ? _range.start : null, _range != null ? _range.end : null,
                              widget.isPause ? 'paused' : 'canceled', _noteController.text.trim(), _reasons[orderController.cancellationIndex].reason,
                            );
                          }
                        },
                        radius: Dimensions.RADIUS_SMALL, height: 50,
                      )),
                    ]) : Center(child: CircularProgressIndicator());
                  }),

                ]);
              }
            ),
          ),
        )),
      ),
    );
  }
}
