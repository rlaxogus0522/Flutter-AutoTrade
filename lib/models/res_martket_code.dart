class ItemMarketCode {
  String? market;
  String? koreanName;
  String? englishName;

  ItemMarketCode({this.market, this.koreanName, this.englishName});

  ItemMarketCode.fromJson(Map<String, dynamic> json) {
    market = json['market'];
    koreanName = json['korean_name'];
    englishName = json['english_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['market'] = market;
    data['korean_name'] = koreanName;
    data['english_name'] = englishName;
    return data;
  }
}
