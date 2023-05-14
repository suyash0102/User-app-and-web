class PaginatedPauseLogModel {
  int totalSize;
  String limit;
  int offset;
  List<PauseLogModel> data;

  PaginatedPauseLogModel({this.totalSize, this.limit, this.offset, this.data});

  PaginatedPauseLogModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'].toString();
    offset = (json['offset'] != null && json['offset'].toString().trim().isNotEmpty) ? int.parse(json['offset'].toString()) : null;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(new PauseLogModel.fromJson(v));
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

class PauseLogModel {
  int id;
  int subscriptionId;
  String from;
  String to;

  PauseLogModel({this.id, this.subscriptionId, this.from, this.to});

  PauseLogModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    subscriptionId = json['subscription_id'];
    from = json['from'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['subscription_id'] = this.subscriptionId;
    data['from'] = this.from;
    data['to'] = this.to;
    return data;
  }
}
