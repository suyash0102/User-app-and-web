class ZoneResponseModel {
  bool _isSuccess;
  List<int> _zoneIds;
  String _message;
  List<ZoneData> _zoneData;
  ZoneResponseModel(this._isSuccess, this._message, this._zoneIds, this._zoneData);

  String get message => _message;
  List<int> get zoneIds => _zoneIds;
  bool get isSuccess => _isSuccess;
  List<ZoneData> get zoneData => _zoneData;
}

class ZoneData {
  int id;
  int status;
  double minimumShippingCharge;
  double increasedDeliveryFee;
  int increasedDeliveryFeeStatus;
  String increaseDeliveryFeeMessage;
  double perKmShippingCharge;
  double maxCodOrderAmount;
  double maximumShippingCharge;

  ZoneData({
    this.id,
    this.status,
    this.minimumShippingCharge,
    this.increasedDeliveryFee,
    this.increasedDeliveryFeeStatus,
    this.increaseDeliveryFeeMessage,
    this.perKmShippingCharge,
    this.maxCodOrderAmount,
    this.maximumShippingCharge,
  });

  ZoneData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    minimumShippingCharge = json['minimum_shipping_charge'] != null ? json['minimum_shipping_charge'].toDouble() : null;
    increasedDeliveryFee = json['increased_delivery_fee'] != null ? json['increased_delivery_fee'].toDouble() : null;
    increasedDeliveryFeeStatus = json['increased_delivery_fee_status'];
    increaseDeliveryFeeMessage = json['increase_delivery_charge_message'];
    perKmShippingCharge = json['per_km_shipping_charge'] != null ? json['per_km_shipping_charge'].toDouble() : null;
    maxCodOrderAmount = json['max_cod_order_amount'] != null ? json['max_cod_order_amount'].toDouble() : null;
    maximumShippingCharge = json['maximum_shipping_charge'] != null ? json['maximum_shipping_charge'].toDouble() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status'] = this.status;
    data['minimum_shipping_charge'] = this.minimumShippingCharge;
    data['increased_delivery_fee'] = this.increasedDeliveryFee;
    data['increased_delivery_fee_status'] = this.increasedDeliveryFeeStatus;
    data['increase_delivery_charge_message'] = this.increaseDeliveryFeeMessage;
    data['per_km_shipping_charge'] = this.perKmShippingCharge;
    data['max_cod_order_amount'] = this.maxCodOrderAmount;
    data['maximum_shipping_charge'] = this.maximumShippingCharge;
    return data;
  }
}

