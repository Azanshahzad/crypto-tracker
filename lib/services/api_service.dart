import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/coin_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';
  
  // Track if we are running in mock fallback mode
  bool isUsingMockData = false;

  /// Fetches the list of coins. Falls back to mock data if the API fails or is rate-limited.
  Future<List<CoinModel>> fetchCoins() async {
    try {
      final url = Uri.parse(
        '$baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=true&price_change_percentage=24h',
      );
      
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.statusCode == 200 ? response.body : '');
        isUsingMockData = false;
        return data.map((json) => CoinModel.fromJson(json)).toList();
      } else {
        // Log status code (e.g. 429 Rate Limit) and activate mock fallback
        debugPrint('API Error: ${response.statusCode} - ${response.reasonPhrase}. Activating mock data fallback.');
        isUsingMockData = true;
        return _getMockCoins();
      }
    } catch (e) {
      debugPrint('Network Exception: $e. Activating mock data fallback.');
      isUsingMockData = true;
      return _getMockCoins();
    }
  }

  /// Fetches historical chart data. Falls back to simulated chart data if the API fails.
  Future<List<List<double>>> fetchHistoricalData(String coinId, int days, double currentPrice) async {
    try {
      if (isUsingMockData) {
        return _getMockHistoricalData(days, currentPrice);
      }

      final url = Uri.parse('$baseUrl/coins/$coinId/market_chart?vs_currency=usd&days=$days');
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> prices = data['prices'] ?? [];
        
        // Output is a list of [timestamp, price] pairs. Convert to list of List<double>.
        return prices.map((point) {
          final List<dynamic> inner = point;
          return [
            (inner[0] as num).toDouble(),
            (inner[1] as num).toDouble(),
          ];
        }).toList();
      } else {
        debugPrint('Chart API Error: ${response.statusCode}. Falling back to mock chart data.');
        return _getMockHistoricalData(days, currentPrice);
      }
    } catch (e) {
      debugPrint('Chart Network Exception: $e. Falling back to mock chart data.');
      return _getMockHistoricalData(days, currentPrice);
    }
  }

  // --- MOCK DATA GENERATORS ---

  List<CoinModel> _getMockCoins() {
    final List<Map<String, dynamic>> rawMockData = [
      {
        'id': 'bitcoin',
        'symbol': 'btc',
        'name': 'Bitcoin',
        'image': 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png',
        'current_price': 117250.00,
        'market_cap': 2310000000000.0,
        'high_24h': 118450.00,
        'low_24h': 115200.00,
        'price_change_24h': -1005.12,
        'price_change_percentage_24h': -0.85,
      },
      {
        'id': 'ethereum',
        'symbol': 'eth',
        'name': 'Ethereum',
        'image': 'https://assets.coingecko.com/coins/images/279/large/ethereum.png',
        'current_price': 4210.50,
        'market_cap': 505000000000.0,
        'high_24h': 4280.00,
        'low_24h': 4150.25,
        'price_change_24h': 60.18,
        'price_change_percentage_24h': 1.45,
      },
      {
        'id': 'solana',
        'symbol': 'sol',
        'name': 'Solana',
        'image': 'https://assets.coingecko.com/coins/images/4128/large/solana.png',
        'current_price': 182.40,
        'market_cap': 82500000000.0,
        'high_24h': 185.60,
        'low_24h': 178.20,
        'price_change_24h': 5.75,
        'price_change_percentage_24h': 3.25,
      },
      {
        'id': 'ripple',
        'symbol': 'xrp',
        'name': 'Ripple',
        'image': 'https://assets.coingecko.com/coins/images/44/large/xrp-symbol-white-branded.png',
        'current_price': 0.625,
        'market_cap': 34500000000.0,
        'high_24h': 0.641,
        'low_24h': 0.608,
        'price_change_24h': 0.003,
        'price_change_percentage_24h': 0.48,
      },
      {
        'id': 'dogecoin',
        'symbol': 'doge',
        'name': 'Dogecoin',
        'image': 'https://assets.coingecko.com/coins/images/325/large/dogecoin.png',
        'current_price': 0.142,
        'market_cap': 20500000000.0,
        'high_24h': 0.149,
        'low_24h': 0.136,
        'price_change_24h': -0.0036,
        'price_change_percentage_24h': -2.48,
      },
      {
        'id': 'cardano',
        'symbol': 'ada',
        'name': 'Cardano',
        'image': 'https://assets.coingecko.com/coins/images/975/large/cardano.png',
        'current_price': 0.528,
        'market_cap': 18800000000.0,
        'high_24h': 0.545,
        'low_24h': 0.518,
        'price_change_24h': -0.006,
        'price_change_percentage_24h': -1.12,
      },
      {
        'id': 'polkadot',
        'symbol': 'dot',
        'name': 'Polkadot',
        'image': 'https://assets.coingecko.com/coins/images/12171/large/polkadot.png',
        'current_price': 6.45,
        'market_cap': 9200000000.0,
        'high_24h': 6.68,
        'low_24h': 6.32,
        'price_change_24h': -0.052,
        'price_change_percentage_24h': -0.80,
      },
      {
        'id': 'avalanche-2',
        'symbol': 'avax',
        'name': 'Avalanche',
        'image': 'https://assets.coingecko.com/coins/images/12559/large/Avalanche_Circle_RedWhite_Trans.png',
        'current_price': 34.20,
        'market_cap': 13500000000.0,
        'high_24h': 35.80,
        'low_24h': 33.15,
        'price_change_24h': 0.70,
        'price_change_percentage_24h': 2.10,
      },
      {
        'id': 'chainlink',
        'symbol': 'link',
        'name': 'Chainlink',
        'image': 'https://assets.coingecko.com/coins/images/877/large/chainlink-link-logo.png',
        'current_price': 15.30,
        'market_cap': 9100000000.0,
        'high_24h': 15.92,
        'low_24h': 14.85,
        'price_change_24h': 0.17,
        'price_change_percentage_24h': 1.15,
      },
      {
        'id': 'polygon',
        'symbol': 'matic',
        'name': 'Polygon',
        'image': 'https://assets.coingecko.com/coins/images/4713/large/polygon.png',
        'current_price': 0.685,
        'market_cap': 6800000000.0,
        'high_24h': 0.708,
        'low_24h': 0.665,
        'price_change_24h': -0.010,
        'price_change_percentage_24h': -1.44,
      },
    ];

    final random = Random();
    return rawMockData.map((data) {
      // Create a randomized 7-day sparkline list of prices
      final double price = data['current_price'];
      final double percentChange = data['price_change_percentage_24h'];
      
      final List<double> sparklinePrices = [];
      double currentPriceWalker = price - (price * (percentChange / 100)); // start from 24h ago price
      
      for (int i = 0; i < 24; i++) {
        // Generate random walk
        final double fluctuation = (random.nextDouble() - 0.49) * 0.015; // -0.7% to +0.8%
        currentPriceWalker = currentPriceWalker * (1.0 + fluctuation);
        sparklinePrices.add(currentPriceWalker);
      }
      sparklinePrices.add(price); // end with current price

      final Map<String, dynamic> completeData = Map<String, dynamic>.from(data);
      completeData['sparkline_in_7d'] = {
        'price': sparklinePrices,
      };

      return CoinModel.fromJson(completeData);
    }).toList();
  }

  List<List<double>> _getMockHistoricalData(int days, double currentPrice) {
    final random = Random();
    final List<List<double>> chartData = [];
    
    // Determine data points count based on duration
    int pointsCount = 24; // 24H -> 24 points
    if (days == 7) pointsCount = 35; // 7D -> 35 points
    if (days == 30) pointsCount = 30; // 30D -> 30 points
    if (days == 365) pointsCount = 60; // 1Y -> 60 points

    final DateTime now = DateTime.now();
    
    // Create random walk moving backwards from currentPrice
    double walker = currentPrice;
    final double volatility = days == 1 ? 0.006 : (days == 7 ? 0.015 : (days == 30 ? 0.03 : 0.08));

    for (int i = pointsCount - 1; i >= 0; i--) {
      final DateTime pointTime = now.subtract(Duration(minutes: (days * 24 * 60 ~/ pointsCount) * i));
      final double timestamp = pointTime.millisecondsSinceEpoch.toDouble();
      
      chartData.add([timestamp, walker]);
      
      // Move price randomly for the next step back
      final double drift = (random.nextDouble() - 0.5) * volatility;
      walker = walker * (1.0 - drift); // backwards movement
    }
    
    // Sort chronological (by timestamp)
    chartData.sort((a, b) => a[0].compareTo(b[0]));
    
    // Make sure the last point matches current price exactly
    chartData[chartData.length - 1][1] = currentPrice;

    return chartData;
  }
}
