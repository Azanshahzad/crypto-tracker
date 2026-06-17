import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/coin_model.dart';
import '../providers/coin_provider.dart';

class DetailScreen extends StatefulWidget {
  final CoinModel coin;

  const DetailScreen({super.key, required this.coin});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _selectedIntervalDays = 1; // Default to 24H

  @override
  void initState() {
    super.initState();
    // Load historical chart data on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CoinProvider>(context, listen: false)
          .fetchChartData(widget.coin.id, _selectedIntervalDays);
    });
  }

  void _onIntervalChanged(int days) {
    setState(() {
      _selectedIntervalDays = days;
    });
    Provider.of<CoinProvider>(context, listen: false)
        .fetchChartData(widget.coin.id, days);
  }

  @override
  Widget build(BuildContext context) {
    final coinProvider = Provider.of<CoinProvider>(context);
    final isFavorite = coinProvider.isFavorite(widget.coin.id);
    final chartPoints = coinProvider.getChartPoints(widget.coin.id, _selectedIntervalDays);
    
    final priceFormat = NumberFormat.currency(symbol: '\$', decimalDigits: widget.coin.currentPrice >= 1.0 ? 2 : 6);
    final largeNumberFormat = NumberFormat.compactSimpleCurrency(locale: 'en_US');
    
    final percentChange = widget.coin.priceChangePercentage24h;
    final isPositive = percentChange >= 0;
    final accentColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFF43F5E);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Favorite Star Toggle
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border_outlined,
              color: isFavorite ? const Color(0xFFFBBF24) : Colors.white,
            ),
            onPressed: () => coinProvider.toggleFavorite(widget.coin.id),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Coin Basic Title Block
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        widget.coin.imageUrl,
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 50,
                          color: const Color(0xFF1E293B),
                          child: const Icon(Icons.monetization_on_outlined, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.coin.name,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.coin.symbol,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Price and 24h Change Block
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priceFormat.format(widget.coin.currentPrice),
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          size: 18,
                          color: accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${isPositive ? '+' : ''}${percentChange.toStringAsFixed(2)}% (24h)',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Interactive Chart
              Container(
                height: 280,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B), // Slate 800
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: coinProvider.isChartLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                        ),
                      )
                    : chartPoints.isEmpty
                        ? Center(
                            child: Text(
                              'Failed to load chart data',
                              style: GoogleFonts.outfit(color: const Color(0xFF64748B)),
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipColor: (spot) => const Color(0xFF0F172A),
                                  tooltipRoundedRadius: 8,
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                                      String dateFormatPattern = 'hh:mm a';
                                      if (_selectedIntervalDays > 1) {
                                        dateFormatPattern = 'MMM dd, hh:mm a';
                                      }
                                      final formattedDate = DateFormat(dateFormatPattern).format(date);
                                      return LineTooltipItem(
                                        '${priceFormat.format(spot.y)}\n',
                                        GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: formattedDate,
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF94A3B8),
                                              fontSize: 10,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              minX: chartPoints.first[0],
                              maxX: chartPoints.last[0],
                              minY: chartPoints.map((p) => p[1]).reduce((a, b) => a < b ? a : b) * 0.999,
                              maxY: chartPoints.map((p) => p[1]).reduce((a, b) => a > b ? a : b) * 1.001,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: chartPoints.map((p) => FlSpot(p[0], p[1])).toList(),
                                  isCurved: true,
                                  color: accentColor,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        accentColor.withValues(alpha: 0.3),
                                        accentColor.withValues(alpha: 0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
              const SizedBox(height: 16),

              // 4. Interval Selector Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIntervalButton(label: '24H', days: 1),
                    _buildIntervalButton(label: '7D', days: 7),
                    _buildIntervalButton(label: '30D', days: 30),
                    _buildIntervalButton(label: '1Y', days: 365),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Coin Statistics Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Market Statistics',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      label: 'Market Cap',
                      value: largeNumberFormat.format(widget.coin.marketCap),
                    ),
                    _buildStatCard(
                      label: '24h High',
                      value: priceFormat.format(widget.coin.high24h),
                    ),
                    _buildStatCard(
                      label: '24h Low',
                      value: priceFormat.format(widget.coin.low24h),
                    ),
                    _buildStatCard(
                      label: '24h Change',
                      value: priceFormat.format(widget.coin.priceChange24h),
                      valueColor: accentColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntervalButton({required String label, required int days}) {
    final isSelected = _selectedIntervalDays == days;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: isSelected ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF334155),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => _onIntervalChanged(days),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required String label, required String value, Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Slate 800
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: const Color(0xFF94A3B8), // Slate 400
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
