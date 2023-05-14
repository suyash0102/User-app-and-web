class SubscriptionScheduleModel {
  int id;
  int subscriptionId;
  String type;
  int day;
  String time;
  String createdAt;
  String updatedAt;

  SubscriptionScheduleModel(
      {this.id,
        this.subscriptionId,
        this.type,
        this.day,
        this.time,
        this.createdAt,
        this.updatedAt});

  SubscriptionScheduleModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    subscriptionId = json['subscription_id'];
    type = json['type'];
    day = json['day'];
    time = json['time'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['subscription_id'] = this.subscriptionId;
    data['type'] = this.type;
    data['day'] = this.day;
    data['time'] = this.time;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
