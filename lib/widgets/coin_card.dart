import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/coin_model.dart';
import '../providers/coin_provider.dart';
import '../screens/detail_screen.dart';

class CoinCard extends StatelessWidget {
  final CoinModel coin;

  const CoinCard({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    final isFavorite = Provider.of<CoinProvider>(context).isFavorite(coin.id);
    
    final priceFormat = NumberFormat.currency(symbol: '\$', decimalDigits: coin.currentPrice >= 1.0 ? 2 : 6);
    final percentChange = coin.priceChangePercentage24h;
    final isPositive = percentChange >= 0;
    
    final accentColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFF43F5E);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Slate 800
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF334155), // Slate 700
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(coin: coin),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Coin Image / Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    coin.imageUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 44,
                      height: 44,
                      color: const Color(0xFF334155),
                      child: const Icon(
                        Icons.monetization_on_outlined,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Name & Symbol
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.name,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coin.symbol,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8), // Slate 400
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Mini Sparkline (Premium Touch!)
                if (coin.sparkline.isNotEmpty)
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 32,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: coin.sparkline.length.toDouble() - 1,
                          minY: coin.sparkline.reduce((a, b) => a < b ? a : b),
                          maxY: coin.sparkline.reduce((a, b) => a > b ? a : b),
                          lineBarsData: [
                            LineChartBarData(
                              spots: coin.sparkline.asMap().entries.map((entry) {
                                return FlSpot(entry.key.toDouble(), entry.value);
                              }).toList(),
                              isCurved: true,
                              color: accentColor,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(flex: 2),

                const SizedBox(width: 12),

                // Price & Percentage Change
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        priceFormat.format(coin.currentPrice),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            isPositive ? Icons.trending_up : Icons.trending_down,
                            size: 14,
                            color: accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPositive ? '+' : ''}${percentChange.toStringAsFixed(2)}%',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Star Watchlist Toggle Icon
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border_outlined,
                    color: isFavorite ? const Color(0xFFFBBF24) : const Color(0xFF64748B), // Gold or Slate 500
                    size: 20,
                  ),
                  onPressed: () {
                    coinProvider.toggleFavorite(coin.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
