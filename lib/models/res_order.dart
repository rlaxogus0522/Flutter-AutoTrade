class ResOrder {
  String? uuid;
  String? side;
  String? ordType;
  String? price;
  String? avgPrice;
  String? state;
  String? market;
  String? createdAt;
  String? volume;
  String? remainingVolume;
  String? reservedFee;
  String? remainingFee;
  String? paidFee;
  String? locked;
  String? executedVolume;
  int? tradesCount;

  ResOrder(
      {this.uuid,
      this.side,
      this.ordType,
      this.price,
      this.avgPrice,
      this.state,
      this.market,
      this.createdAt,
      this.volume,
      this.remainingVolume,
      this.reservedFee,
      this.remainingFee,
      this.paidFee,
      this.locked,
      this.executedVolume,
      this.tradesCount});

  ResOrder.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    side = json['side'];
    ordType = json['ord_type'];
    price = json['price'];
    avgPrice = json['avg_price'];
    state = json['state'];
    market = json['market'];
    createdAt = json['created_at'];
    volume = json['volume'];
    remainingVolume = json['remaining_volume'];
    reservedFee = json['reserved_fee'];
    remainingFee = json['remaining_fee'];
    paidFee = json['paid_fee'];
    locked = json['locked'];
    executedVolume = json['executed_volume'];
    tradesCount = json['trades_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['side'] = side;
    data['ord_type'] = ordType;
    data['price'] = price;
    data['avg_price'] = avgPrice;
    data['state'] = state;
    data['market'] = market;
    data['created_at'] = createdAt;
    data['volume'] = volume;
    data['remaining_volume'] = remainingVolume;
    data['reserved_fee'] = reservedFee;
    data['remaining_fee'] = remainingFee;
    data['paid_fee'] = paidFee;
    data['locked'] = locked;
    data['executed_volume'] = executedVolume;
    data['trades_count'] = tradesCount;
    return data;
  }
}
