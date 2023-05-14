import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/helper/date_converter.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDatePicker extends StatelessWidget {
  final String hint;
  final DateTimeRange range;
  final Function(DateTimeRange range) onDatePicked;
  final bool isPause;
  const CustomDatePicker({@required this.hint, @required this.range, @required this.onDatePicked, this.isPause = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        DateTimeRange _range = await showDateRangePicker(
          context: context, firstDate: DateTime.now(), lastDate: isPause ? DateTime.parse(Get.find<OrderController>().trackModel.subscription.endAt) : DateTime.now().add(Duration(days: 365)),
        );
        if(_range != null) {
          if(_range.start == _range.end){
            showCustomSnackBar('start_date_and_end_date_can_not_be_same_for_subscription_order'.tr);
          }else{
            onDatePicked(_range);
          }
        }
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
          boxShadow: [ BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 0.5, blurRadius: 0.5)],
        ),
        child: Text(
          range != null ? DateConverter.dateRangeToDate(range) : hint,
          style: robotoRegular,
        ),
      ),
    );
  }
}
