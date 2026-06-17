import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/coin_provider.dart';
import '../widgets/coin_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with App Title and Date
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crypto Markets',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Live Price Updates',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: const Color(0xFF94A3B8), // Slate 400
                        ),
                      ),
                    ],
                  ),
                  
                  // Simple refresh circle indicator/button
                  Consumer<CoinProvider>(
                    builder: (context, provider, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: IconButton(
                          icon: provider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded, color: Colors.white70),
                          onPressed: provider.isLoading ? null : () => provider.refreshCoins(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Fallback Mock Data Notice Banner (Recruiter friendly!)
            Consumer<CoinProvider>(
              builder: (context, provider, child) {
                if (provider.isUsingMockData) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B4B), // Indigo 950
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF312E81)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFF818CF8), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Demo Mode: Showing offline simulated live data (API rate limit exceeded).',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFC7D2FE), // Indigo 200
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 8),

            // Markets List
            Expanded(
              child: Consumer<CoinProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.allCoins.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      ),
                    );
                  }

                  if (provider.errorMessage.isNotEmpty && provider.allCoins.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFF43F5E),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to fetch data',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.errorMessage,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                              label: Text(
                                'Retry Connection',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              onPressed: () => provider.refreshCoins(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF6366F1),
                    backgroundColor: const Color(0xFF1E293B),
                    onRefresh: () => provider.refreshCoins(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: provider.allCoins.length,
                      itemBuilder: (context, index) {
                        final coin = provider.allCoins[index];
                        return CoinCard(coin: coin);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
