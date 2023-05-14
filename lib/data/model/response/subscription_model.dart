
import 'package:efood_multivendor/data/model/response/restaurant_model.dart';

class SubscriptionModel {
  int id;
  String status;
  String startAt;
  String endAt;
  String note;
  String type;
  int quantity;
  int userId;
  int restaurantId;
  double billingAmount;
  double paidAmount;
  String createdAt;
  String updatedAt;
  bool isPausedToday;
  Restaurant restaurant;

  SubscriptionModel(
      {this.id,
        this.status,
        this.startAt,
        this.endAt,
        this.note,
        this.type,
        this.quantity,
        this.userId,
        this.restaurantId,
        this.billingAmount,
        this.paidAmount,
        this.createdAt,
        this.updatedAt,
        this.isPausedToday,
        this.restaurant,
      });

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    startAt = json['start_at'];
    endAt = json['end_at'];
    note = json['note'];
    type = json['type'];
    quantity = json['quantity'];
    userId = json['user_id'];
    restaurantId = json['restaurant_id'];
    billingAmount = json['billing_amount'].toDouble();
    paidAmount = json['paid_amount'].toDouble();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isPausedToday = json['is_paused_today'];
    restaurant = json['restaurant'] != null ? new Restaurant.fromJson(json['store']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status'] = this.status;
    data['start_at'] = this.startAt;
    data['end_at'] = this.endAt;
    data['note'] = this.note;
    data['type'] = this.type;
    data['quantity'] = this.quantity;
    data['user_id'] = this.userId;
    data['restaurant_id'] = this.restaurantId;
    data['billing_amount'] = this.billingAmount;
    data['paid_amount'] = this.paidAmount;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_paused_today'] = this.isPausedToday;
    if (this.restaurant != null) {
      data['restaurant'] = this.restaurant.toJson();
    }
    return data;
  }
}