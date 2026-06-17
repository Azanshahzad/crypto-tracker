import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coin_model.dart';
import '../services/api_service.dart';

class CoinProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<CoinModel> _allCoins = [];
  List<CoinModel> _filteredCoins = [];
  List<String> _favoriteIds = [];
  String _searchQuery = '';
  
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Cache for historical data: Key = "coinId_days", Value = list of [timestamp, price]
  final Map<String, List<List<double>>> _chartDataCache = {};
  bool _isChartLoading = false;
  int _activeChartIntervalDays = 1; // Default to 24H (1 day)

  // Getters
  List<CoinModel> get allCoins => _allCoins;
  List<CoinModel> get filteredCoins => _filteredCoins;
  List<String> get favoriteIds => _favoriteIds;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isUsingMockData => _apiService.isUsingMockData;
  
  bool get isChartLoading => _isChartLoading;
  int get activeChartIntervalDays => _activeChartIntervalDays;
  
  // Watchlist items (allCoins filtered by favorite IDs)
  List<CoinModel> get watchlistCoins {
    return _allCoins.where((coin) => _favoriteIds.contains(coin.id)).toList();
  }

  CoinProvider() {
    _loadFavoritesFromPrefs();
  }

  /// Initialize and fetch coins
  Future<void> refreshCoins() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _allCoins = await _apiService.fetchCoins();
      _applySearch();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update search query and filter coins
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applySearch();
  }

  void _applySearch() {
    if (_searchQuery.trim().isEmpty) {
      _filteredCoins = List.from(_allCoins);
    } else {
      final searchLower = _searchQuery.toLowerCase();
      _filteredCoins = _allCoins.where((coin) {
        return coin.name.toLowerCase().contains(searchLower) ||
            coin.symbol.toLowerCase().contains(searchLower);
      }).toList();
    }
    notifyListeners();
  }

  /// Load favorites list from SharedPreferences
  Future<void> _loadFavoritesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _favoriteIds = prefs.getStringList('favorite_coins') ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  /// Toggle favorite status of a coin
  Future<void> toggleFavorite(String coinId) async {
    if (_favoriteIds.contains(coinId)) {
      _favoriteIds.remove(coinId);
    } else {
      _favoriteIds.add(coinId);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_coins', _favoriteIds);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  /// Check if coin is in favorites
  bool isFavorite(String coinId) {
    return _favoriteIds.contains(coinId);
  }

  /// Fetches historical chart points for a specific coin and active interval
  Future<void> selectChartInterval(String coinId, int days) async {
    _activeChartIntervalDays = days;
    notifyListeners();
    await fetchChartData(coinId, days);
  }

  /// Retrieve chart data from cache or API
  List<List<double>> getChartPoints(String coinId, int days) {
    final cacheKey = '${coinId}_$days';
    return _chartDataCache[cacheKey] ?? [];
  }

  Future<void> fetchChartData(String coinId, int days) async {
    final cacheKey = '${coinId}_$days';
    
    // Find the coin's current price to use as a fallback if the API fails
    final coin = _allCoins.firstWhere(
      (c) => c.id == coinId,
      orElse: () => CoinModel(
        id: coinId,
        symbol: '',
        name: '',
        imageUrl: '',
        currentPrice: 100.0,
        marketCap: 0,
        high24h: 0,
        low24h: 0,
        priceChange24h: 0,
        priceChangePercentage24h: 0,
        sparkline: [],
      ),
    );

    _isChartLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.fetchHistoricalData(coinId, days, coin.currentPrice);
      _chartDataCache[cacheKey] = data;
    } catch (e) {
      debugPrint('Error fetching chart data: $e');
    } finally {
      _isChartLoading = false;
      notifyListeners();
    }
  }
}
