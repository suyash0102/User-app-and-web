import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderTypeWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final bool isSelected;
  final Function onTap;
  const OrderTypeWidget({@required this.title, @required this.subtitle, @required this.icon, @required this.isSelected, @required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(children: [

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
            boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], blurRadius: 5, spreadRadius: 1)],
          ),
          child: ListTile(
            leading: Image.asset(
              icon, width: 30, height: 30,
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
            ),
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            minLeadingWidth: 0,
            horizontalTitleGap: Dimensions.PADDING_SIZE_EXTRA_SMALL,
            title: Text(
              title,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
            subtitle: Text(
              subtitle,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        isSelected ? Positioned(
          top: 5, right: 5,
          child: Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 15),
        ) : SizedBox(),

      ]),
    );
  }
}
