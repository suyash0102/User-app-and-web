import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/data/model/response/zone_response_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class BadWeatherWidget extends StatefulWidget {
  const BadWeatherWidget({Key key}) : super(key: key);

  @override
  State<BadWeatherWidget> createState() => _BadWeatherWidgetState();
}

class _BadWeatherWidgetState extends State<BadWeatherWidget> {
  bool _showAlert = true;
  String _message;
  @override
  void initState() {
    super.initState();

    ZoneData _zoneData;
    Get.find<LocationController>().getUserAddress().zoneData.forEach((zoneData) {
      Get.find<LocationController>().getUserAddress().zoneIds.forEach((zoneId) {
        if(zoneData.id == zoneId){
          if(zoneData.increasedDeliveryFeeStatus == 1 && zoneData.increaseDeliveryFeeMessage != null){
            _zoneData = zoneData;
          }
        }
      });
    });
    if(_zoneData != null){
      _showAlert = _zoneData.increasedDeliveryFeeStatus == 1;
      _message = _zoneData.increaseDeliveryFeeMessage;
    }else{
      _showAlert = false;
    }

  }

  @override
  Widget build(BuildContext context) {

    return _showAlert && _message != null && _message.isNotEmpty ? Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
        color: Theme.of(context).primaryColor.withOpacity(0.5),
      ),
      padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT, vertical: Dimensions.PADDING_SIZE_SMALL),
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.PADDING_SIZE_DEFAULT, vertical: Dimensions.PADDING_SIZE_SMALL),
      child: Row(
        children: [
          Image.asset(Images.weather, height: 50, width: 50),
          SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

          Expanded(child: Text(
              _message,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).cardColor),
          )),
        ],
      ),
    ) : SizedBox();
  }
}
