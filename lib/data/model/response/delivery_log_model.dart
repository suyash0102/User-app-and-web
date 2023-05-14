class PaginatedDeliveryLogModel {
  int totalSize;
  String limit;
  int offset;
  List<DeliveryLogModel> data;

  PaginatedDeliveryLogModel({this.totalSize, this.limit, this.offset, this.data});

  PaginatedDeliveryLogModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(new DeliveryLogModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_size'] = this.totalSize;
    data['limit'] = this.limit;
    data['offset'] = this.offset;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }

}

class DeliveryLogModel {
  int id;
  int orderId;
  int deliveryManId;
  int subscriptionId;
  String orderStatus;
  String accepted;
  String scheduleAt;
  String confirmed;
  String processing;
  String handover;
  String pickedUp;
  String delivered;
  String canceled;
  String failed;
  String createdAt;
  String updatedAt;

  DeliveryLogModel(
      {this.id,
        this.orderId,
        this.deliveryManId,
        this.subscriptionId,
        this.orderStatus,
        this.accepted,
        this.scheduleAt,
        this.confirmed,
        this.processing,
        this.handover,
        this.pickedUp,
        this.delivered,
        this.canceled,
        this.failed,
        this.createdAt,
        this.updatedAt});

  DeliveryLogModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    deliveryManId = json['delivery_man_id'];
    subscriptionId = json['subscription_id'];
    orderStatus = json['order_status'];
    accepted = json['accepted'];
    scheduleAt = json['schedule_at'];
    confirmed = json['confirmed'];
    processing = json['processing'];
    handover = json['handover'];
    pickedUp = json['picked_up'];
    delivered = json['delivered'];
    canceled = json['canceled'];
    failed = json['failed'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['delivery_man_id'] = this.deliveryManId;
    data['subscription_id'] = this.subscriptionId;
    data['order_status'] = this.orderStatus;
    data['accepted'] = this.accepted;
    data['schedule_at'] = this.scheduleAt;
    data['confirmed'] = this.confirmed;
    data['processing'] = this.processing;
    data['handover'] = this.handover;
    data['picked_up'] = this.pickedUp;
    data['delivered'] = this.delivered;
    data['canceled'] = this.canceled;
    data['failed'] = this.failed;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
