class OldCandleData {
  String? market;
  String? candleDateTimeUtc;
  String? candleDateTimeKst;
  var openingPrice;
  var highPrice;
  var lowPrice;
  var tradePrice;
  var timestamp;
  var candleAccTradePrice;
  var candleAccTradeVolume;
  var unit;

  OldCandleData(
      {this.market,
      this.candleDateTimeUtc,
      this.candleDateTimeKst,
      this.openingPrice,
      this.highPrice,
      this.lowPrice,
      this.tradePrice,
      this.timestamp,
      this.candleAccTradePrice,
      this.candleAccTradeVolume,
      this.unit});

  factory OldCandleData.fromJson(Map<String, dynamic> json) {
    return OldCandleData(
      market: json['market'],
      candleDateTimeUtc: json['candle_date_time_utc'],
      candleDateTimeKst: json['candle_date_time_kst'],
      openingPrice: json['opening_price'],
      highPrice: json['high_price'],
      lowPrice: json['low_price'],
      tradePrice: json['trade_price'],
      timestamp: json['timestamp'],
      candleAccTradePrice: json['candle_acc_trade_price'],
      candleAccTradeVolume: json['candle_acc_trade_volume'],
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['market'] = market;
    data['candle_date_time_utc'] = candleDateTimeUtc;
    data['candle_date_time_kst'] = candleDateTimeKst;
    data['opening_price'] = openingPrice;
    data['high_price'] = highPrice;
    data['low_price'] = lowPrice;
    data['trade_price'] = tradePrice;
    data['timestamp'] = timestamp;
    data['candle_acc_trade_price'] = candleAccTradePrice;
    data['candle_acc_trade_volume'] = candleAccTradeVolume;
    data['unit'] = unit;
    return data;
  }
}
