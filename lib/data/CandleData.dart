class CandleData {
  final DateTime? time;
  var low;
  var high;
  var open;
  var close;
  var volume;

  CandleData({
    required this.time,
    required this.low,
    required this.high,
    required this.open,
    required this.close,
    required this.volume,
  });
}
