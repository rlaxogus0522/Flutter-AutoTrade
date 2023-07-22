class Socket_NowPrice {
  String? type;
  String? code;
  var openingPrice;
  var highPrice;
  var lowPrice;
  var tradePrice;
  var prevClosingPrice;
  var accTradePrice;
  String? change;
  var changePrice;
  var signedChangePrice;
  var changeRate;
  var signedChangeRate;
  String? askBid;
  var tradeVolume;
  var accTradeVolume;
  String? tradeDate;
  String? tradeTime;
  var tradeTimestamp;
  var accAskVolume;
  var accBidVolume;
  var highest52WeekPrice;
  String? highest52WeekDate;
  var lowest52WeekPrice;
  String? lowest52WeekDate;
  String? marketState;
  bool? isTradingSuspended;
  DateTime? delistingDate;
  String? marketWarning;
  DateTime? timestamp;
  var accTradePrice24h;
  var accTradeVolume24h;
  String? streamType;

  Socket_NowPrice(
      {this.type,
      this.code,
      this.openingPrice,
      this.highPrice,
      this.lowPrice,
      this.tradePrice,
      this.prevClosingPrice,
      this.accTradePrice,
      this.change,
      this.changePrice,
      this.signedChangePrice,
      this.changeRate,
      this.signedChangeRate,
      this.askBid,
      this.tradeVolume,
      this.accTradeVolume,
      this.tradeDate,
      this.tradeTime,
      this.tradeTimestamp,
      this.accAskVolume,
      this.accBidVolume,
      this.highest52WeekPrice,
      this.highest52WeekDate,
      this.lowest52WeekPrice,
      this.lowest52WeekDate,
      this.marketState,
      this.isTradingSuspended,
      this.delistingDate,
      this.marketWarning,
      this.timestamp,
      this.accTradePrice24h,
      this.accTradeVolume24h,
      this.streamType});

  // DateTime getDate() {
  //   return DateTime.fromMillisecondsSinceEpoch(
  //       (int.parse(timestamp.toString()) * 1000));
  // }

  Socket_NowPrice.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    code = json['code'];
    openingPrice = json['opening_price'];
    highPrice = json['high_price'];
    lowPrice = json['low_price'];
    tradePrice = json['trade_price'];
    prevClosingPrice = json['prev_closing_price'];
    accTradePrice = json['acc_trade_price'];
    change = json['change'];
    changePrice = json['change_price'];
    signedChangePrice = json['signed_change_price'];
    changeRate = json['change_rate'];
    signedChangeRate = json['signed_change_rate'];
    askBid = json['ask_bid'];
    tradeVolume = json['trade_volume'];
    accTradeVolume = json['acc_trade_volume'];
    tradeDate = json['trade_date'];
    tradeTime = json['trade_time'];
    tradeTimestamp = json['trade_timestamp'];
    accAskVolume = json['acc_ask_volume'];
    accBidVolume = json['acc_bid_volume'];
    highest52WeekPrice = json['highest_52_week_price'];
    highest52WeekDate = json['highest_52_week_date'];
    lowest52WeekPrice = json['lowest_52_week_price'];
    lowest52WeekDate = json['lowest_52_week_date'];
    marketState = json['market_state'];
    isTradingSuspended = json['is_trading_suspended'];
    delistingDate = json['delisting_date'];
    marketWarning = json['market_warning'];
    timestamp = toTime(DateTime.fromMillisecondsSinceEpoch(json['timestamp']));
    accTradePrice24h = json['acc_trade_price_24h'];
    accTradeVolume24h = json['acc_trade_volume_24h'];
    streamType = json['stream_type'];
  }

  DateTime toTime(DateTime time) {
    return DateTime(time.year, time.month, time.day, time.hour, time.minute);
  }

  int to5Minute(int minute) {
    var min5 = (minute ~/ 5 * 5);
    return min5;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['code'] = code;
    data['opening_price'] = openingPrice;
    data['high_price'] = highPrice;
    data['low_price'] = lowPrice;
    data['trade_price'] = tradePrice;
    data['prev_closing_price'] = prevClosingPrice;
    data['acc_trade_price'] = accTradePrice;
    data['change'] = change;
    data['change_price'] = changePrice;
    data['signed_change_price'] = signedChangePrice;
    data['change_rate'] = changeRate;
    data['signed_change_rate'] = signedChangeRate;
    data['ask_bid'] = askBid;
    data['trade_volume'] = tradeVolume;
    data['acc_trade_volume'] = accTradeVolume;
    data['trade_date'] = tradeDate;
    data['trade_time'] = tradeTime;
    data['trade_timestamp'] = tradeTimestamp;
    data['acc_ask_volume'] = accAskVolume;
    data['acc_bid_volume'] = accBidVolume;
    data['highest_52_week_price'] = highest52WeekPrice;
    data['highest_52_week_date'] = highest52WeekDate;
    data['lowest_52_week_price'] = lowest52WeekPrice;
    data['lowest_52_week_date'] = lowest52WeekDate;
    data['market_state'] = marketState;
    data['is_trading_suspended'] = isTradingSuspended;
    data['delisting_date'] = delistingDate;
    data['market_warning'] = marketWarning;
    data['timestamp'] = timestamp;
    data['acc_trade_price_24h'] = accTradePrice24h;
    data['acc_trade_volume_24h'] = accTradeVolume24h;
    data['stream_type'] = streamType;
    return data;
  }
}
