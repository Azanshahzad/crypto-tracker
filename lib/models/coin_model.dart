class CoinModel {
  final String id;
  final String symbol;
  final String name;
  final String imageUrl;
  final double currentPrice;
  final double marketCap;
  final double high24h;
  final double low24h;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final List<double> sparkline;

  CoinModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    required this.marketCap,
    required this.high24h,
    required this.low24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.sparkline,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    // Safely parse sparkline data if available
    List<double> sparklineData = [];
    if (json['sparkline_in_7d'] != null && json['sparkline_in_7d']['price'] != null) {
      final List<dynamic> priceList = json['sparkline_in_7d']['price'];
      sparklineData = priceList.map((e) => (e as num).toDouble()).toList();
    }

    return CoinModel(
      id: json['id'] as String? ?? '',
      symbol: (json['symbol'] as String? ?? '').toUpperCase(),
      name: json['name'] as String? ?? '',
      imageUrl: json['image'] as String? ?? '',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0.0,
      high24h: (json['high_24h'] as num?)?.toDouble() ?? 0.0,
      low24h: (json['low_24h'] as num?)?.toDouble() ?? 0.0,
      priceChange24h: (json['price_change_24h'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage24h: (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      sparkline: sparklineData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': imageUrl,
      'current_price': currentPrice,
      'market_cap': marketCap,
      'high_24h': high24h,
      'low_24h': low24h,
      'price_change_24h': priceChange24h,
      'price_change_percentage_24h': priceChangePercentage24h,
      'sparkline_in_7d': {
        'price': sparkline,
      },
    };
  }
}
