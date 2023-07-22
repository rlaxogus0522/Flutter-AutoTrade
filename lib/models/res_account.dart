class ResAccount {
  final String currency;
  final String balance;
  final String locked;
  final String avg_buy_price;
  final bool avg_buy_price_modified;
  final String unit_currency;

  ResAccount({
    required this.currency,
    required this.balance,
    required this.locked,
    required this.avg_buy_price,
    required this.avg_buy_price_modified,
    required this.unit_currency,
  });

  factory ResAccount.fromJson(Map<String, dynamic> json) {
    return ResAccount(
      currency: json['currency'],
      balance: json['balance'],
      locked: json['locked'],
      avg_buy_price: json['avg_buy_price'],
      avg_buy_price_modified: json['avg_buy_price_modified'],
      unit_currency: json['unit_currency'],
    );
  }
}
