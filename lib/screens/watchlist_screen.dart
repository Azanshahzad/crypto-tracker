import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/coin_provider.dart';
import '../widgets/coin_card.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final coinProvider = Provider.of<CoinProvider>(context);
    final watchlist = coinProvider.watchlistCoins;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      body: SafeArea(
        child: Column(
          children: [
            // Header Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Watchlist',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Watchlist Content
            Expanded(
              child: watchlist.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1E293B),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              child: const Icon(
                                Icons.star_border_rounded,
                                color: Color(0xFFFBBF24), // Gold Star
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Your Watchlist is Empty',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the star icon on any coin card to save it here for quick access.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: watchlist.length,
                      itemBuilder: (context, index) {
                        final coin = watchlist[index];
                        return CoinCard(coin: coin);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
