import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/coin_provider.dart';
import '../widgets/coin_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controller with whatever query is current in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = Provider.of<CoinProvider>(context, listen: false).searchQuery;
      _searchController.text = query;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coinProvider = Provider.of<CoinProvider>(context);

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
                  'Search Markets',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Premium Search Bar Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B), // Slate 800
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF334155), // Slate 700
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    coinProvider.updateSearchQuery(value);
                  },
                  style: GoogleFonts.outfit(color: Colors.white),
                  cursorColor: const Color(0xFF818CF8), // Indigo 400
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                            onPressed: () {
                              _searchController.clear();
                              coinProvider.updateSearchQuery('');
                            },
                          )
                        : null,
                    hintText: 'Search coin name or symbol (e.g. BTC)...',
                    hintStyle: GoogleFonts.outfit(color: const Color(0xFF64748B)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Filtered Coin List
            Expanded(
              child: coinProvider.filteredCoins.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            color: const Color(0xFF475569), // Slate 600
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Coins Found',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try searching for another name or symbol',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: coinProvider.filteredCoins.length,
                      itemBuilder: (context, index) {
                        final coin = coinProvider.filteredCoins[index];
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
